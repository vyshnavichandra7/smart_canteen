import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CanteenLogo extends StatelessWidget {
  const CanteenLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E6),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.orange, width: size * 0.075),
            ),
            alignment: Alignment.center,
            child: Container(
              height: size * 0.68,
              width: size * 0.68,
              decoration: const BoxDecoration(
                color: AppTheme.navy,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rice_bowl_rounded,
                color: Colors.white,
                size: size * 0.43,
              ),
            ),
          ),
          Positioned(
            top: size * 0.03,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.orange,
              size: size * 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
