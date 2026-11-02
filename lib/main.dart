import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/order_provider.dart';
import 'providers/profile_provider.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final storage = LocalStorageService(preferences);
  await storage.removeLegacyDemoSignIn();
  final cartProvider = CartProvider(storage);
  final favoritesProvider = FavoritesProvider(storage);
  final orderProvider = OrderProvider(storage);
  final profileProvider = ProfileProvider(storage);

  await Future.wait([
    cartProvider.initialize(),
    favoritesProvider.initialize(),
    orderProvider.initialize(),
    profileProvider.initialize(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: orderProvider),
        ChangeNotifierProvider.value(value: profileProvider),
      ],
      child: CanteenApp(storage: storage),
    ),
  );
}
