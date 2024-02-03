import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';

import './exeptions/exceptions.dart';

/// An answer has a String and a boolen value to indicate if the answer is correct.
///
/// example
/// ```dart
/// Answer answer = ('Der schiefe turm von pisa', true);
///
/// print('The answer ${answer.$1} is ${answer.$2});
/// ```
typedef Answer = (String, bool);

/// Returns a Json representation of a [Answer] object
///
Map<String, dynamic> answerToJson(Answer answer) {
  return {
    'answer': answer.$1,
    'correctnes': answer.$2,
  };
}

/// Creates a [Answer] object from a json String
///
Answer answerFromJson(Map<String, dynamic> answerJson) {
  return (answerJson['answer'] as String, answerJson['correctnes'] as bool);
}

/// Returns a String of Json representation from the [Answer]s of the given [MultipleChoiceCard] object
///
String answersToJsonString(MultipleChoiceCard learnCard) {
  return jsonEncode(
      {'answers': List.from(learnCard.answers.map((e) => answerToJson(e)))});
}

/// Returns a List of [Answer]s from the given json String
///
List<Answer> answersFromJsonString(String jsonString) {
  Map<String, dynamic> jsonObj = jsonDecode(jsonString);
  List<Answer> answers =
      List.from(jsonObj['answers'].map((e) => answerFromJson(e)));
  return answers;
}

/// The data model for a flash card.
class MultipleChoiceCard {
  String _id;
  final String authorId;
  DateTime _lastModified;
  final DateTime _created;
  String _question;
  List<Answer> _answers; // ignore: prefer_final_fields

  String get id => _id;
  set id(String newId) {
    if (newId.isNotEmpty) {
      _id = newId;
    }
  }

  DateTime get lastModified => _lastModified;
  set lastModified(DateTime time) {
    if (time.isAfter(_lastModified)) {
      _lastModified = time;
    }
  }

  String get question => _question;
  set question(String newQuestion) {
    if (newQuestion.isNotEmpty) {
      _question = newQuestion;
    }
  }

  DateTime get created => _created;

  /// A deep copy of the answer list from this [MultipleChoiceCard].
  List<Answer> get answers => List<Answer>.from(_answers);

  MultipleChoiceCard({
    required String id,
    required this.authorId,
    DateTime? created,
    DateTime? lastModified,
    required String question,
    required List<(String, bool)> answers,
  })  : _id = id,
        _created = created ?? DateTime.now().toUtc(),
        _lastModified = lastModified ?? DateTime.now().toUtc(),
        _question = question,
        _answers = answers {
    if (!validateAnswerList()) {
      throw InvalidAnswerList(
          cause:
              "The answer list must have 4-6 options and at least one correct answer");
    }
  }

  /// Creates a [MultipleChoiceCard] object from a json object
  ///
  MultipleChoiceCard.fromJson(Map<String, dynamic> json)
      : _id = json['id'] as String,
        authorId = json['authorId'] as String,
        _lastModified = DateTime.parse(json['lastModified']),
        _created = DateTime.parse(json['created']),
        _question = json['question'] as String,
        _answers =
            List<Answer>.from(json['answers'].map((e) => answerFromJson(e))) {
    if (!validateAnswerList()) {
      throw InvalidAnswerList(
          cause:
              "The answer list must have 4-6 options and at least one correct answer");
    }
  }

  /// Returns a Json representation of the [MultipleChoiceCard] object
  ///
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'authorId': authorId,
      'lastModified': _lastModified.toIso8601String(),
      'created': _created.toIso8601String(),
      'question': _question,
      'answers': List.from(_answers.map((e) => answerToJson(e))),
    };
  }

  /// Validates constrains for a list of answers.
  ///
  /// 1. there are 4-6 answers
  /// 1. at least one of them is correct
  bool validateAnswerList() {
    if (answers.length < 2 || answers.length > 6) {
      return false;
    }
    if (!answers.map((e) => e.$2).reduce((value, element) => value | element)) {
      return false;
    }
    return true;
  }
}

/// [ContextMultipleChoiceCard]s enable sharing a Instace of a [MultipleChoiceCard] whithin a widget tree.
///
/// to enable a new page to access a [MultipleChoiceCard] instance use:
/// ```dart
///   Navigator.push(
///     context,
///    MaterialPageRoute(
///       builder: (context) => ContextLearnCard(
///           learnCard: learnCard,
///           child: const LearnCardDetailPage()),
///    ),
///   );
/// ```
///
/// to retrieve the [learnCard] from within a child widget use:
/// ``` dart
/// ContextLearnCard.of(context).learnCard
/// ```
class ContextMultipleChoiceCard extends InheritedWidget {
  final MultipleChoiceCard learnCard;

  const ContextMultipleChoiceCard(
      {super.key, required this.learnCard, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  /// Returns the [ContextMultipleChoiceCard] from the widget tree.
  ///
  /// Throws an error if no [ContextMultipleChoiceCard] was added to the tree before.
  static ContextMultipleChoiceCard of(BuildContext context) {
    ContextMultipleChoiceCard? learnCardDetail =
        context.dependOnInheritedWidgetOfExactType<ContextMultipleChoiceCard>();
    if (learnCardDetail == null) {
      throw 'No ModuleDetail found!';
    }
    return learnCardDetail;
  }
}
