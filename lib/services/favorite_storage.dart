import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteStorage {
  static const String _favoriteKey = "guest_favorites";

  static final StreamController<void> _changes =
      StreamController<void>.broadcast();

  static Stream<void> get favoriteChanges => _changes.stream;

  static Future<void> saveFavorites(List<String> productIds) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_favoriteKey, productIds);

    _changes.add(null);
  }

  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_favoriteKey) ?? [];
  }

  static Future<void> addFavorite(String productId) async {
    final favorites = await loadFavorites();

    if (!favorites.contains(productId)) {
      favorites.add(productId);

      await saveFavorites(favorites);
    }
  }

  static Future<void> removeFavorite(String productId) async {
    final favorites = await loadFavorites();

    favorites.remove(productId);

    await saveFavorites(favorites);
  }

  static Future<bool> isFavorite(String productId) async {
    final favorites = await loadFavorites();

    return favorites.contains(productId);
  }

  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_favoriteKey);

    _changes.add(null);
  }
}
