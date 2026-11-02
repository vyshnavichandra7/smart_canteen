import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  static const _cartKey = 'canteen_cart_v1';
  static const _ordersKey = 'canteen_orders_v1';
  static const _favoritesKey = 'canteen_favorites_v1';
  static const _onboardingKey = 'canteen_onboarding_seen';
  static const _displayNameKey = 'canteen_display_name';
  static const _legacySignedInKey = 'canteen_demo_signed_in';
  static const _legacyRollNumberKey = 'canteen_demo_roll_number';
  static const _legacyDemoRollNumber = '22BD1A0501';

  bool get hasSeenOnboarding => _preferences.getBool(_onboardingKey) ?? false;
  String get displayName =>
      _preferences.getString(_displayNameKey) ?? 'Student';

  Future<void> setOnboardingSeen() async {
    await _requireSaved(
      _preferences.setBool(_onboardingKey, true),
      'onboarding state',
    );
  }

  Future<void> saveDisplayName(String name) async {
    await _requireSaved(
      _preferences.setString(_displayNameKey, name),
      'display name',
    );
  }

  Future<void> removeLegacyDemoSignIn() async {
    final oldRollNumber = _preferences.getString(_legacyRollNumberKey);
    final rollRemoved = await _preferences.remove(_legacyRollNumberKey);
    final signInRemoved = await _preferences.remove(_legacySignedInKey);
    if (!rollRemoved || !signInRemoved) {
      throw StateError('Could not clear previous demo sign-in data.');
    }
    if (oldRollNumber == _legacyDemoRollNumber &&
        displayName == _legacyDemoRollNumber) {
      await saveDisplayName('Student');
    }
  }

  List<Map<String, dynamic>> loadCart() =>
      _decodeList(_preferences.getString(_cartKey));

  Future<void> saveCart(List<Map<String, Object>> items) async {
    await _requireSaved(
      _preferences.setString(_cartKey, jsonEncode(items)),
      'cart',
    );
  }

  List<Map<String, dynamic>> loadOrders() =>
      _decodeList(_preferences.getString(_ordersKey));

  Future<void> saveOrders(List<Map<String, dynamic>> orders) async {
    await _requireSaved(
      _preferences.setString(_ordersKey, jsonEncode(orders)),
      'orders',
    );
  }

  List<String> loadFavoriteIds() =>
      _preferences.getStringList(_favoritesKey) ?? [];

  Future<void> saveFavoriteIds(List<String> favoriteIds) async {
    await _requireSaved(
      _preferences.setStringList(_favoritesKey, favoriteIds),
      'favorite dishes',
    );
  }

  Future<void> _requireSaved(Future<bool> write, String label) async {
    if (!await write) {
      throw StateError('Could not save $label to local storage.');
    }
  }

  List<Map<String, dynamic>> _decodeList(String? value) {
    if (value == null) return [];
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      throw const FormatException('Saved canteen data must be a list.');
    }
    return decoded.map((entry) {
      if (entry is! Map) {
        throw const FormatException('Saved canteen item must be an object.');
      }
      return Map<String, dynamic>.from(entry);
    }).toList();
  }
}
