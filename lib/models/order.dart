import '../data/sample_menu.dart';
import 'cart_item.dart';

enum OrderStatus { placed, preparing, ready }

const simulatedStatusInterval = Duration(minutes: 1);

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.placed => 'Placed',
    OrderStatus.preparing => 'Preparing',
    OrderStatus.ready => 'Ready',
  };
}

class CanteenOrder {
  const CanteenOrder({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.status,
    required this.statusTimes,
    this.cancelledAt,
  });

  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final OrderStatus status;
  final List<DateTime?> statusTimes;
  final DateTime? cancelledAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get total => items.fold(0, (sum, item) => sum + item.total);
  bool get isCancelled => cancelledAt != null;
  bool get canBeCancelled => !isCancelled && status == OrderStatus.placed;
  String get displayStatus => isCancelled ? 'Cancelled' : status.label;
  DateTime get estimatedReadyAt =>
      createdAt.add(simulatedStatusInterval * (OrderStatus.values.length - 1));

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((item) => item.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'statusTimes': statusTimes.map((time) => time?.toIso8601String()).toList(),
    if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
  };

  factory CanteenOrder.fromJson(Map<String, dynamic> json) {
    final menuById = {for (final item in sampleMenu) item.id: item};
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Saved order items must be a list.');
    }
    final items = rawItems.map((rawItem) {
      if (rawItem is! Map) {
        throw const FormatException('Saved order item must be an object.');
      }
      final item = Map<String, dynamic>.from(rawItem);
      final food = menuById[item['foodId']];
      final quantity = item['quantity'];
      if (food == null || quantity is! int || quantity < 1) {
        throw const FormatException('Saved order contains an invalid item.');
      }
      return CartItem(food: food, quantity: quantity);
    }).toList();
    final rawTimes = json['statusTimes'];
    if (rawTimes is! List || rawTimes.length != OrderStatus.values.length) {
      throw const FormatException('Saved order timestamps are invalid.');
    }
    final statusTimes = rawTimes.map((value) {
      if (value == null) return null;
      if (value is! String) {
        throw const FormatException('Saved order timestamp is invalid.');
      }
      return DateTime.parse(value);
    }).toList();
    final statusName = json['status'];
    final status = OrderStatus.values.where(
      (value) => value.name == statusName,
    );
    if (status.isEmpty ||
        json['id'] is! String ||
        json['createdAt'] is! String) {
      throw const FormatException('Saved order details are invalid.');
    }
    final rawCancelledAt = json['cancelledAt'];
    if (rawCancelledAt != null && rawCancelledAt is! String) {
      throw const FormatException('Saved cancellation time is invalid.');
    }
    return CanteenOrder(
      id: json['id'] as String,
      items: items,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: status.first,
      statusTimes: statusTimes,
      cancelledAt: rawCancelledAt == null
          ? null
          : DateTime.parse(rawCancelledAt as String),
    );
  }

  CanteenOrder copyWith({
    OrderStatus? status,
    List<DateTime?>? statusTimes,
    DateTime? cancelledAt,
  }) => CanteenOrder(
    id: id,
    items: items,
    createdAt: createdAt,
    status: status ?? this.status,
    statusTimes: statusTimes ?? this.statusTimes,
    cancelledAt: cancelledAt ?? this.cancelledAt,
  );
}
