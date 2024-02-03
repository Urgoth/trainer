import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../mc_topic.dart';

/// Local storage functionality for module data.
class McTopicDao extends ChangeNotifier {
  McTopicDao() {
    Future(() => _loadData());
  }

  final List<McTopic> _modules = [];

  /// Returns a flat copy of all modules.
  ///
  List<McTopic> findAll() => _modules.toList();

  /// Deletes the module object with the given id.
  /// Return true = delete ok, false = no object with the given id found.
  ///
  Future<bool> delete(String id) async {
    var elemIndex = _modules.indexWhere((element) => element.id == id);

    if (elemIndex >= 0) {
      _modules.removeAt(elemIndex);
      await _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Updates the module in the storage with the given module object.
  /// Return true = update ok, false = no record object with the given id found.
  ///
  Future<bool> update(McTopic module) async {
    var elemIndex = _modules.indexWhere((element) => element.id == module.id);
    if (elemIndex >= 0) {
      _modules[elemIndex] = module;
      await _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Persists the given module object.
  /// Return true = persist ok, false = error module object not persisted!
  /// Side effects: module.id = _nextId
  ///
  Future<bool> persist(McTopic module) async {
    if (_modules.indexWhere((element) => element.id == module.id) >= 0) {
      if (kDebugMode) {
        print('${module.name}[${module.id}] already in local storage');
      }
      return false;
    }
    _modules.add(module);
    await _saveData();
    notifyListeners();
    if (kDebugMode) {
      print('${module.name}[${module.id}] saved in local storage');
    }
    return true;
  }

  /// Loads the module data from the local storage
  ///
  Future<void> _loadData() async {
    final storage = await SharedPreferences.getInstance();
    final modules = storage.getStringList('modules');

    if (modules != null && modules.isNotEmpty) {
      _modules.clear();
      _modules.addAll(modules.map((r) => McTopic.fromJson(jsonDecode(r))));
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
    final modules = _modules.map((card) => jsonEncode(card.toJson())).toList();
    storage.setStringList('modules', modules);
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
