import 'package:flutter/material.dart';

import 'mc_card.dart';

/// The data model for a module.
class McTopic {
  String _id;
  int _lastCardId;
  final DateTime _created;
  DateTime _lastModified;
  String _name;
  String _description;
  final String _authorId;
  final List<MultipleChoiceCard> _mcCards;

  String get id => _id;
  set id(String newId) {
    if (newId.isNotEmpty) {
      _id = newId;
    }
  }

  String get name => _name;
  set name(String newname) {
    if (newname.isNotEmpty) {
      _name = newname;
    }
  }

  String get description => _description;
  set description(String newdescription) {
    if (newdescription.isNotEmpty) {
      _description = newdescription;
    }
  }

  /// A deep copy of the list of [MultipleChoiceCard]s from this Module
  List<MultipleChoiceCard> get learnCards =>
      List<MultipleChoiceCard>.from(_mcCards);

  String get authorId => _authorId;

  DateTime get created => _created;

  DateTime get lastModified => _lastModified;
  set lastModified(DateTime time) {
    if (time.isAfter(_lastModified)) {
      _lastModified = time;
    }
  }

  McTopic({
    int lastCardId = 0,
    String? id,
    required String authorId,
    DateTime? lastModified,
    DateTime? created,
    required String name,
    required String description,
    required List<MultipleChoiceCard> learnCards,
  })  : _lastCardId = lastCardId,
        _description = description,
        _name = name,
        _id = id ?? UniqueKey().toString(),
        _authorId = authorId,
        _mcCards = learnCards,
        _created = created ?? DateTime.now().toUtc(),
        _lastModified = lastModified ?? DateTime.now().toUtc();

  /// Appends the given card onto the List of [MultipleChoiceCard]s of the [McTopic].
  ///
  addCard(String question, List<Answer> answers, [String? authorId]) {
    DateTime lastModified = DateTime.now();
    _lastCardId = _lastCardId + 1;
    String learnCardId = _id + _lastCardId.toString();

    _mcCards.add(MultipleChoiceCard(
        id: learnCardId,
        authorId: authorId ?? _authorId,
        lastModified: lastModified,
        question: question,
        answers: answers));
    _lastModified = lastModified;
  }

  /// Returns a [MultipleChoiceCard] object with the given id from the cards in the Module instance.
  /// If id is not in in the [McTopic] null is returned
  ///
  MultipleChoiceCard? getCard(String id) {
    return _mcCards.where((element) => element.id == id).firstOrNull;
  }

  /// Creates a Module object from a json object
  ///
  McTopic.fromJson(Map<String, dynamic> json)
      : _id = json['id'] as String,
        _authorId = json['author'],
        _lastCardId = json['lastCardId'] ?? 0,
        _created = DateTime.parse(json['created']),
        _lastModified = DateTime.parse(json['updated']),
        _name = json['name'] as String,
        _description = json['description'] as String,
        _mcCards = List<MultipleChoiceCard>.from(json['mc_cards']
            .map((element) => MultipleChoiceCard.fromJson(element)));

  /// Returns a Json representation of the Module object
  ///
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'author': _authorId,
      'lastCardId': _lastCardId,
      'created': _created.toIso8601String(),
      'updated': _lastModified.toIso8601String(),
      'name': _name,
      'description': _description,
      'learnCards': List<dynamic>.from(_mcCards.map((e) => e.toJson())),
    };
  }
}

/// [ContextMcTopic]s enable sharing a Instace of a [McTopic] whithin a widget tree.
///
/// to enable a new site to access a [McTopic] instance use:
/// ```dart
///   Navigator.push(
///     context,
///    MaterialPageRoute(
///       builder: (context) => ContextModule(
///           module: module,
///           child: const ModuleDetailPage()),
///    ),
///   );
/// ```
///
/// to retrieve the [module] from within a child widget use:
/// ``` dart
/// ContextModule.of(context).module
/// ```
class ContextMcTopic extends InheritedWidget {
  final McTopic module;

  const ContextMcTopic({super.key, required this.module, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  /// Returns the [ContextMcTopic] from the widget tree.
  ///
  /// Throws an error if no [ContextMcTopic] was added to the tree before.
  static ContextMcTopic of(BuildContext context) {
    ContextMcTopic? moduleDetail =
        context.dependOnInheritedWidgetOfExactType<ContextMcTopic>();
    if (moduleDetail == null) {
      throw 'No ModuleDetail found!';
    }
    return moduleDetail;
  }
}
