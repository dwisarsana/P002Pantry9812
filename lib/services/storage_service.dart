import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/garden_model.dart';

class StorageService {
  static const String _historyKey = 'garden_history';

  Future<void> saveGardens(List<GardenModel> gardens) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = gardens.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<GardenModel>> loadGardens() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_historyKey);
    
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) {
      return GardenModel.fromJson(jsonDecode(jsonStr));
    }).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final gardens = await loadGardens();
    final index = gardens.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = gardens[index];
      gardens[index] = GardenModel(
        id: g.id,
        originalImagePath: g.originalImagePath,
        resultImagePath: g.resultImagePath,
        styleName: g.styleName,
        timestamp: g.timestamp,
        settings: g.settings,
        isFavorite: !g.isFavorite,
      );
      await saveGardens(gardens);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
