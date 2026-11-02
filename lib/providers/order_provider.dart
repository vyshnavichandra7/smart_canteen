import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/local_storage_service.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._storage, {Duration statusStep = simulatedStatusInterval})
    : _statusStep = statusStep {
    if (statusStep <= Duration.zero) {
      throw ArgumentError.value(statusStep, 'statusStep', 'Must be positive.');
    }
  }

  final LocalStorageService _storage;
  final Duration _statusStep;
  List<CanteenOrder> _orders = [];
  int _idSequence = 0;
  Timer? _statusTimer;

  List<CanteenOrder> get orders => List.unmodifiable(_orders);
  CanteenOrder? get latestOrder => _orders.isEmpty ? null : _orders.first;
  CanteenOrder? findById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> initialize() async {
    _orders = _storage.loadOrders().map(CanteenOrder.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _updateDueStatuses();
  }

  Future<CanteenOrder> placeOrder(CartProvider cart) async {
    if (cart.isEmpty) {
      throw StateError('Add an item before placing an order.');
    }
    final now = DateTime.now();
    final order = CanteenOrder(
      id: _createOrderId(now),
      items: List<CartItem>.unmodifiable(cart.items),
      createdAt: now,
      status: OrderStatus.placed,
      statusTimes: [now, null, null],
    );
    final nextOrders = [order, ..._orders];
    await _storage.saveOrders(
      nextOrders.map((entry) => entry.toJson()).toList(),
    );
    _orders = nextOrders;
    notifyListeners();
    _scheduleNextTransition();
    await cart.clear();
    return order;
  }

  Future<void> _updateDueStatuses() async {
    final now = DateTime.now();
    var changed = false;
    final nextOrders = _orders.map((order) {
      var updated = order;
      while (!updated.isCancelled && updated.status != OrderStatus.ready) {
        final nextIndex = updated.status.index + 1;
        final dueAt = updated.createdAt.add(_statusStep * nextIndex);
        if (dueAt.isAfter(now)) break;
        final times = List<DateTime?>.from(updated.statusTimes);
        times[nextIndex] = dueAt;
        updated = updated.copyWith(
          status: OrderStatus.values[nextIndex],
          statusTimes: times,
        );
        changed = true;
      }
      return updated;
    }).toList();

    if (changed) {
      await _storage.saveOrders(
        nextOrders.map((order) => order.toJson()).toList(),
      );
      _orders = nextOrders;
      notifyListeners();
    }
    _scheduleNextTransition();
  }

  Future<void> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) throw StateError('Order $orderId was not found.');
    final order = _orders[index];
    if (order.isCancelled) return;
    if (order.status != OrderStatus.placed) {
      throw StateError('An order can only be cancelled before preparation.');
    }

    final cancelled = order.copyWith(cancelledAt: DateTime.now());
    final nextOrders = List<CanteenOrder>.from(_orders)..[index] = cancelled;
    await _storage.saveOrders(
      nextOrders.map((entry) => entry.toJson()).toList(),
    );
    _orders = nextOrders;
    notifyListeners();
    _scheduleNextTransition();
  }

  void _scheduleNextTransition() {
    _statusTimer?.cancel();
    DateTime? nextDue;
    for (final order in _orders) {
      if (order.isCancelled || order.status == OrderStatus.ready) continue;
      final due = order.createdAt.add(_statusStep * (order.status.index + 1));
      if (nextDue == null || due.isBefore(nextDue)) nextDue = due;
    }
    if (nextDue == null) return;

    final delay = nextDue.difference(DateTime.now());
    _statusTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      _runScheduledUpdate,
    );
  }

  Future<void> _runScheduledUpdate() async {
    try {
      await _updateDueStatuses();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'order provider',
          context: ErrorDescription('while updating timed order statuses'),
        ),
      );
      _statusTimer = Timer(const Duration(seconds: 30), _runScheduledUpdate);
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  String _createOrderId(DateTime time) {
    String id;
    do {
      _idSequence++;
      id =
          'MG-${time.millisecondsSinceEpoch.toString().substring(6)}-${_idSequence.toString().padLeft(2, '0')}';
    } while (_orders.any((order) => order.id == id));
    return id;
  }
}
