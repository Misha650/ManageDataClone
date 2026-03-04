import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ProjectCacheController {
  // Singleton pattern
  static final ProjectCacheController _instance =
      ProjectCacheController._internal();
  factory ProjectCacheController() => _instance;
  ProjectCacheController._internal();

  // In-memory cache
  final Map<String, List<Map<String, dynamic>>> _dataCache = {};

  // Notify listeners when data updates
  final ValueNotifier<int> updateNotifier = ValueNotifier<int>(0);

  Future<File> _getCacheFile(String projectId) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/project_cache_$projectId.json';
    return File(path);
  }

  Future<void> setData(
    String projectId,
    List<Map<String, dynamic>> data,
  ) async {
    _dataCache[projectId] = data;
    updateNotifier.value++;

    try {
      final file = await _getCacheFile(projectId);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving cache: $e");
    }
  }

  /// Returns cached data from memory or disk
  Future<List<Map<String, dynamic>>?> getData(String projectId) async {
    // 1. Check memory
    if (_dataCache.containsKey(projectId)) {
      return _dataCache[projectId];
    }

    // 2. Check disk
    try {
      final file = await _getCacheFile(projectId);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        final List<Map<String, dynamic>> data = jsonList
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        // Populate memory cache
        _dataCache[projectId] = data;
        return data;
      }
    } catch (e) {
      debugPrint("Error reading cache: $e");
    }

    return null;
  }

  Future<void> clearCache(String projectId) async {
    _dataCache.remove(projectId);
    updateNotifier.value++;

    try {
      final file = await _getCacheFile(projectId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("Error clearing cache: $e");
    }
  }
}
