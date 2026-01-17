import 'package:flutter/material.dart';

class ProjectCacheController {
  // Singleton pattern
  static final ProjectCacheController _instance =
      ProjectCacheController._internal();
  factory ProjectCacheController() => _instance;
  ProjectCacheController._internal();

  // Cache: projectId -> List of data
  final Map<String, List<Map<String, dynamic>>> _dataCache = {};

  // Notify listeners when data updates
  final ValueNotifier<int> updateNotifier = ValueNotifier<int>(0);

  void setData(String projectId, List<Map<String, dynamic>> data) {
    _dataCache[projectId] = data;
    updateNotifier.value++;
  }

  List<Map<String, dynamic>>? getData(String projectId) {
    return _dataCache[projectId];
  }

  void clearCache(String projectId) {
    _dataCache.remove(projectId);
    updateNotifier.value++;
  }
}
