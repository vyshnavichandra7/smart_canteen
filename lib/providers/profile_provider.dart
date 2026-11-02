import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._storage);

  final LocalStorageService _storage;
  String _displayName = 'Student';

  String get displayName => _displayName;

  Future<void> initialize() async {
    _displayName = _storage.displayName;
  }

  Future<void> updateDisplayName(String value) async {
    final name = value.trim();
    if (name.isEmpty) throw ArgumentError('Name cannot be empty.');
    await _storage.saveDisplayName(name);
    _displayName = name;
    notifyListeners();
  }
}
