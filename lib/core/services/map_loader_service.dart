import 'dart:convert';

import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:flutter/services.dart';

class MapLoaderService {
  const MapLoaderService();

  /// Default map path inside assets
  static const String defaultMapPath = 'assets/map/library_map.json';

  /// Load map from assets
  Future<LibraryMapModel> load({String path = defaultMapPath}) async {
    try {
      final jsonString = await rootBundle.loadString(path);

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      return LibraryMapModel.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load map from "$path"\nError: $e');
    }
  }
}
