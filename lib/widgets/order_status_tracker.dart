import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_theme.dart';

class OrderStatusTracker extends StatelessWidget {
  const OrderStatusTracker({super.key, required this.order});

  final CanteenOrder order;

  static const _icons = [
    Icons.receipt_long_rounded,
    Icons.soup_kitchen_rounded,
    Icons.takeout_dining_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(OrderStatus.values.length, (index) {
        final status = OrderStatus.values[index];
        final complete = index <= order.status.index;
        final current = index == order.status.index;
        final time = order.statusTimes[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 42,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: complete ? AppTheme.navy : const Color(0xFFF0F1F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icons[index],
                      size: 19,
                      color: complete ? Colors.white : AppTheme.muted,
                    ),
                  ),
                  if (index < OrderStatus.values.length - 1)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeInOut,
                      height: 36,
                      width: 2,
                      color: index < order.status.index
                          ? AppTheme.navy
                          : const Color(0xFFE5E7EB),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.15),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Text(
                            status.label,
                            key: ValueKey(status),
                            style: TextStyle(
                              fontWeight: current
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: complete ? AppTheme.ink : AppTheme.muted,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (current) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: AppTheme.orange,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusDetail(
                        order: order,
                        index: index,
                        time: time,
                        context: context,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _statusDetail({
    required CanteenOrder order,
    required int index,
    required DateTime? time,
    required BuildContext context,
  }) {
    if (time == null) return 'Updates automatically';
    final updatedAt = TimeOfDay.fromDateTime(time).format(context);
    if (index == order.status.index && order.status != OrderStatus.ready) {
      return 'Next update in about 1 min · Updated $updatedAt';
    }
    return 'Updated $updatedAt';
  }
}
