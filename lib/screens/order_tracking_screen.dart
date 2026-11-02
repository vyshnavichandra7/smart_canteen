import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/food_card.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_status_tracker.dart';
import '../widgets/pickup_countdown.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track your order')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final order = orderId == null
              ? provider.latestOrder
              : provider.findById(orderId!);
          if (order == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.track_changes_rounded,
                      size: 54,
                      color: AppTheme.muted,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'No order to track yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Place an order and its progress will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'ORDER ID',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          OrderStatusBadge(order: order),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.id,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.itemCount} items · ${formatPrice(order.total)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        order.items
                            .map(
                              (item) => '${item.quantity} × ${item.food.name}',
                            )
                            .join(' · '),
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PickupCountdown(order: order),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (order.isCancelled)
                _CancelledOrderNotice(order: order)
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 20),
                        OrderStatusTracker(order: order),
                      ],
                    ),
                  ),
                ),
                if (order.canBeCancelled) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _confirmCancellation(context, provider, order.id),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    OrderProvider provider,
    String id,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text(
          'You can cancel while the order is still Placed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB42318),
            ),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (shouldCancel != true || !context.mounted) return;
    try {
      await provider.cancelOrder(id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order cancelled')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not cancel order: $error')));
    }
  }
}

class _CancelledOrderNotice extends StatelessWidget {
  const _CancelledOrderNotice({required this.order});

  final CanteenOrder order;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_rounded, color: Color(0xFFB42318)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order cancelled',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: const Color(0xFFB42318)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cancelled ${TimeOfDay.fromDateTime(order.cancelledAt!).format(context)}. This order will not progress further.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
