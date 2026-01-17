import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubProjectCacheController {
  // Singleton pattern
  static final SubProjectCacheController _instance =
      SubProjectCacheController._internal();
  factory SubProjectCacheController() => _instance;
  SubProjectCacheController._internal();

  // Cache: "projectId|subprojectId" -> List of DocumentSnapshots
  final Map<String, List<QueryDocumentSnapshot>> _allDocsCache = {};

  // Notify listeners when data updates for a specific key
  final Map<String, ValueNotifier<int>> _updateNotifiers = {};

  String _getKey(String projectId, String subprojectId) =>
      "$projectId|$subprojectId";

  ValueNotifier<int> getNotifier(String projectId, String subprojectId) {
    final key = _getKey(projectId, subprojectId);
    return _updateNotifiers.putIfAbsent(key, () => ValueNotifier<int>(0));
  }

  void setDocs(
    String projectId,
    String subprojectId,
    List<QueryDocumentSnapshot> docs,
  ) {
    final key = _getKey(projectId, subprojectId);
    _allDocsCache[key] = docs;
    getNotifier(projectId, subprojectId).value++;
  }

  List<QueryDocumentSnapshot>? getDocs(String projectId, String subprojectId) {
    final key = _getKey(projectId, subprojectId);
    return _allDocsCache[key];
  }
}
