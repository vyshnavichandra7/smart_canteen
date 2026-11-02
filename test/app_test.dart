import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgit_smart_canteen/app.dart';
import 'package:mgit_smart_canteen/data/sample_menu.dart';
import 'package:mgit_smart_canteen/models/order.dart';
import 'package:mgit_smart_canteen/providers/cart_provider.dart';
import 'package:mgit_smart_canteen/providers/favorites_provider.dart';
import 'package:mgit_smart_canteen/providers/order_provider.dart';
import 'package:mgit_smart_canteen/providers/profile_provider.dart';
import 'package:mgit_smart_canteen/screens/order_tracking_screen.dart';
import 'package:mgit_smart_canteen/services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageService storage;
  late CartProvider cart;
  late FavoritesProvider favorites;
  late OrderProvider orders;
  late ProfileProvider profile;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    storage = LocalStorageService(preferences);
    cart = CartProvider(storage);
    favorites = FavoritesProvider(storage);
    orders = OrderProvider(storage);
    profile = ProfileProvider(storage);
    await Future.wait([
      cart.initialize(),
      favorites.initialize(),
      orders.initialize(),
      profile.initialize(),
    ]);
  });

  test(
    'cart totals follow actual quantities and return to zero when empty',
    () async {
      expect(cart.isEmpty, isTrue);
      expect(cart.total, 0);

      final idli = sampleMenu.firstWhere((food) => food.id == 'idli');
      await cart.add(idli);
      await cart.increment(idli.id);
      expect(cart.itemCount, 2);
      expect(cart.subtotal, 70);

      await cart.decrement(idli.id);
      expect(cart.itemCount, 1);
      expect(cart.total, 35);
      await cart.remove(idli.id);
      expect(cart.isEmpty, isTrue);
      expect(cart.total, 0);
    },
  );

  test(
    'quantity cannot fall below zero and unavailable items are rejected',
    () async {
      await cart.decrement('missing');
      expect(cart.itemCount, 0);
      final coffee = sampleMenu.firstWhere((food) => food.id == 'coffee');
      await expectLater(cart.add(coffee), throwsStateError);
      expect(cart.isEmpty, isTrue);
    },
  );

  test('sample menu includes popular Chicken Biryani in Meals', () {
    final biryani = sampleMenu.firstWhere(
      (food) => food.id == 'chicken-biryani',
    );
    expect(biryani.name, 'Chicken Biryani');
    expect(biryani.category, 'Meals');
    expect(biryani.isAvailable, isTrue);
    expect(biryani.isPopular, isTrue);
    expect(biryani.price, 140);
  });

  test('cart survives provider recreation from local storage', () async {
    await cart.add(sampleMenu.firstWhere((food) => food.id == 'tea'));
    await cart.increment('tea');

    final restored = CartProvider(storage);
    await restored.initialize();
    expect(restored.itemCount, 2);
    expect(restored.total, 30);
  });

  test('removing the old login clears its saved roll number', () async {
    SharedPreferences.setMockInitialValues({
      'canteen_demo_signed_in': true,
      'canteen_demo_roll_number': '22BD1A0501',
      'canteen_display_name': '22BD1A0501',
    });
    final preferences = await SharedPreferences.getInstance();
    final migratedStorage = LocalStorageService(preferences);

    await migratedStorage.removeLegacyDemoSignIn();

    expect(preferences.getBool('canteen_demo_signed_in'), isNull);
    expect(preferences.getString('canteen_demo_roll_number'), isNull);
    expect(migratedStorage.displayName, 'Student');
  });

  test('favorites toggle and persist across provider recreation', () async {
    expect(favorites.isFavorite('dosa'), isFalse);
    await favorites.toggle('dosa');
    expect(favorites.isFavorite('dosa'), isTrue);

    final restored = FavoritesProvider(storage);
    await restored.initialize();
    expect(restored.isFavorite('dosa'), isTrue);

    await restored.toggle('dosa');
    expect(restored.isFavorite('dosa'), isFalse);
    expect(favorites.isFavorite('dosa'), isTrue);
  });

  test('order automatically advances to preparing and ready', () async {
    await cart.add(sampleMenu.firstWhere((food) => food.id == 'samosa'));
    await cart.increment('samosa');

    final timedOrders = OrderProvider(
      storage,
      statusStep: const Duration(milliseconds: 25),
    );
    await timedOrders.initialize();
    final order = await timedOrders.placeOrder(cart);
    expect(order.id, startsWith('MG-'));
    expect(order.status, OrderStatus.placed);
    expect(order.total, 40);
    expect(
      order.estimatedReadyAt,
      order.createdAt.add(const Duration(minutes: 2)),
    );
    expect(cart.isEmpty, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 35));
    expect(timedOrders.findById(order.id)?.status, OrderStatus.preparing);
    await Future<void>.delayed(const Duration(milliseconds: 35));
    expect(timedOrders.findById(order.id)?.status, OrderStatus.ready);

    final restored = OrderProvider(storage);
    await restored.initialize();
    expect(restored.findById(order.id)?.status, OrderStatus.ready);
    timedOrders.dispose();
    restored.dispose();
  });

  test(
    'placed order can be cancelled and stays cancelled after its timer',
    () async {
      await cart.add(sampleMenu.firstWhere((food) => food.id == 'idli'));
      final timedOrders = OrderProvider(
        storage,
        statusStep: const Duration(milliseconds: 25),
      );
      await timedOrders.initialize();
      final order = await timedOrders.placeOrder(cart);

      expect(order.canBeCancelled, isTrue);
      await timedOrders.cancelOrder(order.id);
      await Future<void>.delayed(const Duration(milliseconds: 70));

      final cancelled = timedOrders.findById(order.id)!;
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.displayStatus, 'Cancelled');
      expect(cancelled.status, OrderStatus.placed);
      expect(cancelled.cancelledAt, isNotNull);
      expect(CanteenOrder.fromJson(cancelled.toJson()).isCancelled, isTrue);
      timedOrders.dispose();
    },
  );

  test('order can no longer be cancelled after preparation starts', () async {
    await cart.add(sampleMenu.firstWhere((food) => food.id == 'dosa'));
    final timedOrders = OrderProvider(
      storage,
      statusStep: const Duration(milliseconds: 20),
    );
    await timedOrders.initialize();
    final order = await timedOrders.placeOrder(cart);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(timedOrders.findById(order.id)?.status, OrderStatus.preparing);
    await expectLater(timedOrders.cancelOrder(order.id), throwsStateError);
    timedOrders.dispose();
  });

  testWidgets('tracking confirms cancellation and displays cancelled state', (
    tester,
  ) async {
    await cart.add(sampleMenu.firstWhere((food) => food.id == 'tea'));
    final order = await orders.placeOrder(cart);
    await tester.pumpWidget(
      ChangeNotifierProvider<OrderProvider>.value(
        value: orders,
        child: const MaterialApp(home: OrderTrackingScreen()),
      ),
    );

    await tester.tap(find.text('Cancel order'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this order?'), findsOneWidget);
    await tester.tap(find.text('Cancel order').last);
    await tester.pumpAndSettle();

    expect(orders.findById(order.id)?.isCancelled, isTrue);
    expect(find.text('Order progress'), findsNothing);
    expect(find.text('Cancel this order?'), findsNothing);
    expect(find.text('Order cancelled'), findsWidgets);
  });

  testWidgets('onboarding completes and bottom navigation switches screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cart),
          ChangeNotifierProvider.value(value: favorites),
          ChangeNotifierProvider.value(value: orders),
          ChangeNotifierProvider.value(value: profile),
        ],
        child: CanteenApp(storage: storage),
      ),
    );
    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Popular on Campus'), findsOneWidget);

    await tester.tap(find.text('Menu').last);
    await tester.pumpAndSettle();
    expect(find.text('Explore the menu'), findsOneWidget);

    await tester.tap(find.text('My Orders').last);
    await tester.pumpAndSettle();
    expect(find.text('No orders yet'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Profile & about'), findsOneWidget);
  });
}
