import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class SubProjectCacheController {
  // Singleton pattern
  static final SubProjectCacheController _instance =
      SubProjectCacheController._internal();
  factory SubProjectCacheController() => _instance;
  SubProjectCacheController._internal();

  // In-memory cache: "projectId|subprojectId" -> List of data
  final Map<String, List<Map<String, dynamic>>> _allDataCache = {};

  // Notify listeners when data updates for a specific key
  final Map<String, ValueNotifier<int>> _updateNotifiers = {};

  String _getKey(String projectId, String subprojectId) =>
      "${projectId}_$subprojectId";

  Future<File> _getCacheFile(String projectId, String subprojectId) async {
    final directory = await getApplicationDocumentsDirectory();
    final key = _getKey(projectId, subprojectId);
    final path = '${directory.path}/subproject_cache_$key.json';
    return File(path);
  }

  ValueNotifier<int> getNotifier(String projectId, String subprojectId) {
    final key = _getKey(projectId, subprojectId);
    return _updateNotifiers.putIfAbsent(key, () => ValueNotifier<int>(0));
  }

  Future<void> setData(
    String projectId,
    String subprojectId,
    List<Map<String, dynamic>> data,
  ) async {
    final key = _getKey(projectId, subprojectId);
    _allDataCache[key] = data;
    getNotifier(projectId, subprojectId).value++;

    try {
      final file = await _getCacheFile(projectId, subprojectId);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving subproject cache: $e");
    }
  }

  Future<List<Map<String, dynamic>>?> getData(
    String projectId,
    String subprojectId,
  ) async {
    final key = _getKey(projectId, subprojectId);

    // 1. Check memory
    if (_allDataCache.containsKey(key)) {
      return _allDataCache[key];
    }

    // 2. Check disk
    try {
      final file = await _getCacheFile(projectId, subprojectId);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        final List<Map<String, dynamic>> data = jsonList
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        // Populate memory cache
        _allDataCache[key] = data;
        return data;
      }
    } catch (e) {
      debugPrint("Error reading subproject cache: $e");
    }

    return null;
  }
}
