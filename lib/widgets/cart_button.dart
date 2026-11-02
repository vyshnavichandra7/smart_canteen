import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => IconButton(
        tooltip: 'Open cart',
        onPressed: onPressed,
        icon: Badge(
          isLabelVisible: cart.itemCount > 0,
          label: Text('${cart.itemCount}'),
          child: const Icon(Icons.shopping_bag_outlined),
        ),
      ),
    );
  }
}
