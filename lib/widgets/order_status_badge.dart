import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_theme.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.order});

  final CanteenOrder order;

  @override
  Widget build(BuildContext context) {
    final color = order.isCancelled
        ? const Color(0xFFB42318)
        : switch (order.status) {
            OrderStatus.placed => const Color(0xFF2563EB),
            OrderStatus.preparing => const Color(0xFFD97706),
            OrderStatus.ready => AppTheme.green,
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
