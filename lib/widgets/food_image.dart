import 'package:flutter/material.dart';

class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius = 16,
  });

  final String imageUrl;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: const Color(0xFFFFF1E6),
          alignment: Alignment.center,
          child: const Icon(
            Icons.ramen_dining_rounded,
            color: Color(0xFFFF8A34),
            size: 38,
          ),
        ),
      ),
    );
  }
}
