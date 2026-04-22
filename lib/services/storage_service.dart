import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pantry_model.dart';

class StorageService {
  static const String _historyKey = 'pantry_history';

  Future<void> savePantries(List<PantryModel> pantries) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = pantries.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<PantryModel>> loadPantries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_historyKey);
    
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) {
      return PantryModel.fromJson(jsonDecode(jsonStr));
    }).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final pantries = await loadPantries();
    final index = pantries.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = pantries[index];
      pantries[index] = PantryModel(
        id: g.id,
        originalImagePath: g.originalImagePath,
        resultImagePath: g.resultImagePath,
        styleName: g.styleName,
        timestamp: g.timestamp,
        settings: g.settings,
        isFavorite: !g.isFavorite,
      );
      await savePantries(pantries);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
