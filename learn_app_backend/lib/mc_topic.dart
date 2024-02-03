import 'package:flutter/material.dart';

import 'mc_card.dart';

/// The data model for a module.
class McTopic {
  int lastCardId;
  final String _id;
  final String _authorId;
  DateTime _lastModified;
  final String name;
  final String description;
  final List<MultipleChoiceCard> _learnCards;

  /// A deep copy of the list of [MultipleChoiceCard]s from this Module
  List<MultipleChoiceCard> get learnCards =>
      List<MultipleChoiceCard>.from(_learnCards);

  String? get id => _id;
  String get authorId => _authorId;
  DateTime get lastModified => _lastModified;

  McTopic({
    this.lastCardId = 0,
    String? id,
    required String authorId,
    DateTime? lastModified,
    required this.name,
    required this.description,
    required List<MultipleChoiceCard> learnCards,
  })  : _id = id ?? UniqueKey().toString(),
        _authorId = authorId,
        _learnCards = learnCards,
        _lastModified = lastModified ?? DateTime.now();

  /// Appends the given card onto the List of [MultipleChoiceCard]s of the [McTopic].
  ///
  addCard(String question, List<Answer> answers) {
    DateTime lastModified = DateTime.now();
    lastCardId = lastCardId + 1;
    String learnCardId = _id + lastCardId.toString();

    _learnCards.add(MultipleChoiceCard(
        id: learnCardId,
        lastModified: lastModified,
        question: question,
        answers: answers));
    _lastModified = lastModified;
  }

  /// Returns a [MultipleChoiceCard] object with the given id from the cards in the Module instance.
  /// If id is not in in the [McTopic] null is returned
  ///
  MultipleChoiceCard? getCard(String id) {
    return _learnCards.where((element) => element.id == id).firstOrNull;
  }

  /// Creates a Module object from a json object
  ///
  McTopic.fromJson(Map<String, dynamic> json)
      : _id = json['id'] as String,
        _authorId = json['_authorId'],
        lastCardId = json['lastCardId'],
        _lastModified = DateTime.parse(json['lastModified']),
        name = json['name'] as String,
        description = json['description'] as String,
        _learnCards = List<MultipleChoiceCard>.from(json['learnCards']
            .map((element) => MultipleChoiceCard.fromJson(element)));

  /// Returns a Json representation of the Module object
  ///
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      '_authorId': _authorId,
      'lastCardId': lastCardId,
      'lastModified': _lastModified.toString(),
      'name': name,
      'description': description,
      'learnCards': List<dynamic>.from(_learnCards.map((e) => e.toJson())),
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
