import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._storage);

  final LocalStorageService _storage;
  Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get count => _favoriteIds.length;
  bool isFavorite(String foodId) => _favoriteIds.contains(foodId);

  Future<void> initialize() async {
    _favoriteIds = _storage.loadFavoriteIds().toSet();
    notifyListeners();
  }

  Future<void> toggle(String foodId) async {
    final next = Set<String>.from(_favoriteIds);
    if (!next.add(foodId)) next.remove(foodId);
    await _storage.saveFavoriteIds(next.toList()..sort());
    _favoriteIds = next;
    notifyListeners();
  }
}
