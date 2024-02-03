import 'package:flutter/foundation.dart';
import 'package:learn_app_backend/learn_app_backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../mc_topic.dart';

/// Local storage functionality for [McTopic] data.
class McTopicDao extends ChangeNotifier {
  McTopicDao() {
    Future(() => _loadData());
  }

  final List<McTopic> _topics = [];

  /// A list of [McTopic]s that have to be synced with the Database
  final List<McTopic> _toSync = [];

  /// A list of [McTopic]s that have to be inserted into the Database
  final List<McTopic> _toUpload = [];

  /// Returns a flat copy of all [McTopic]s.
  ///
  List<McTopic> findAll() => _topics;

  /// Deletes the [McTopic] object with the given id.
  ///
  /// Return true = delete ok, false = no object with the given id found.
  Future<bool> delete(String id) async {
    var elemIndex = _topics.indexWhere((element) => element.id == id);

    if (elemIndex >= 0) {
      _topics.removeAt(elemIndex);
      await _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Updates the module in the storage with the given module object.
  ///
  /// Return true = update ok, false = no record object with the given id found.
  Future<bool> update(McTopic topic) async {
    var elemIndex = _topics.indexWhere((element) => element.id == topic.id);
    var syncIndex = _toSync.indexWhere((element) => element.id == topic.id);

    if (elemIndex >= 0) {
      _topics[elemIndex] = topic;
      if (syncIndex < 0) {
        _toSync.add(topic);
      }
      await _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Persists the given [McTopic] object.
  ///
  /// Return true = persist ok, false = error module object not persisted!
  /// Side effects: module.id = _nextId
  Future<bool> persist(McTopic topic) async {
    if (_topics.indexWhere((element) => element.id == topic.id) >= 0) {
      if (kDebugMode) {
        print('${topic.name}[${topic.id}] already in local storage');
      }
      return false;
    }
    _topics.add(topic);
    _toUpload.add(topic);
    await _saveData();
    notifyListeners();
    if (kDebugMode) {
      print('${topic.name}[${topic.id}] saved in local storage');
    }
    return true;
  }

  /// Loads all [McTopic] data from the local storage
  ///
  Future<void> _loadData() async {
    final storage = await SharedPreferences.getInstance();
    final topics = storage.getStringList('modules');
    final syncList = storage.getStringList('syncList');
    final uploadList = storage.getStringList('uploadList');

    if (topics != null && topics.isNotEmpty) {
      _topics.clear();
      _topics.addAll(topics.map((r) => McTopic.fromJson(jsonDecode(r))));
    }
    if (syncList != null && syncList.isNotEmpty) {
      _toSync.clear();
      _toSync.addAll(syncList.map((r) => McTopic.fromJson(jsonDecode(r))));
    }
    if (uploadList != null && uploadList.isNotEmpty) {
      _toUpload.clear();
      _toUpload.addAll(uploadList.map((r) => McTopic.fromJson(jsonDecode(r))));
    }
    notifyListeners();
  }

  /// Removes all data from local storage.
  Future<void> clearStorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    notifyListeners();
  }

  /// Saves all data into the local storage.
  Future<void> _saveData() async {
    final storage = await SharedPreferences.getInstance();
    final topics = _topics.map((card) => jsonEncode(card.toJson())).toList();
    final syncList = _toSync.map((card) => jsonEncode(card.toJson())).toList();
    final uploadList =
        _toUpload.map((card) => jsonEncode(card.toJson())).toList();
    storage.setStringList('modules', topics);
    storage.setStringList('syncList', syncList);
    storage.setStringList('uploadList', uploadList);
  }

  Future<bool> syncWithDB() async {
    for (var ele in _toUpload) {
      await DataBaseHandler.insertMcTopic(ele);
    }
    return true;
  }

  /// Loads all modules with id from [ids] into the local storage.
  // Future<void> loadModulesFromDB(List<int> ids) async {
  //   var localIds = _modules.map((e) => e.id).toList();
  //   ids.removeWhere((element) => localIds.contains(element));
  //   for (var id in ids) {
  //     var module = await SupaBaseHandler.getModule(id);
  //     persist(module);
  //   }
  // }
}
