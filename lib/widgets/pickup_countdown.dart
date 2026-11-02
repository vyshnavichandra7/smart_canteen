import 'dart:async';

import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_theme.dart';

class PickupCountdown extends StatefulWidget {
  const PickupCountdown({super.key, required this.order});

  final CanteenOrder order;

  @override
  State<PickupCountdown> createState() => _PickupCountdownState();
}

class _PickupCountdownState extends State<PickupCountdown> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(covariant PickupCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.status != widget.order.status) {
      _now = DateTime.now();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.isCancelled) {
      return const _CountdownLabel(
        icon: Icons.cancel_rounded,
        label: 'Order cancelled',
        color: Color(0xFFB42318),
      );
    }
    if (widget.order.status == OrderStatus.ready) {
      return const _CountdownLabel(
        icon: Icons.check_circle_rounded,
        label: 'Ready for pickup',
        color: AppTheme.green,
      );
    }

    final remaining = widget.order.estimatedReadyAt.difference(_now);
    if (remaining <= Duration.zero) {
      return const _CountdownLabel(
        icon: Icons.timelapse_rounded,
        label: 'Ready shortly',
        color: AppTheme.orange,
      );
    }
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return _CountdownLabel(
      icon: Icons.schedule_rounded,
      label: 'Ready in $minutes:$seconds',
      color: AppTheme.orange,
    );
  }
}

class _CountdownLabel extends StatelessWidget {
  const _CountdownLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}
