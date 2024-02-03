// ignore: depend_on_referenced_packages
import 'package:learn_app_backend/learn_app_backend.dart';
import 'package:learn_app_backend/mc_topic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  group('A group of tests', () {
    McTopicDao? mcTopicDao;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'modules': [testTopic()].map((e) => json.encode(e.toJson())).toList()
      });
      mcTopicDao = McTopicDao();
      await Future.delayed(const Duration(milliseconds: 500));
    });

    tearDown(() {
      SharedPreferences.resetStatic();
    });

    test('findAll()', () {
      final modules = mcTopicDao?.findAll();
      expect(modules?.length, 1);
    });

    test('persist', () async {
      final topic = testTopic2();
      final result = await mcTopicDao?.persist(topic);
      expect(result, true);
      expect(mcTopicDao?.findAll().length, 2);
    });

    test('update()', () async {
      var topic = mcTopicDao?.findAll()[0];
      String? topicId = topic?.id;
      expect(topic != null, true);
      expect(topic?.learnCards != null, true);
      expect(topic?.learnCards.length, 20);
      topic?.addCard(testCards[20]['question'], testCards[20]['answers']);

      final result = await mcTopicDao?.update(topic as McTopic);
      expect(result, true);

      topic = mcTopicDao?.findAll()[0];
      expect(topic != null, true);
      expect(topic?.id, topicId);
      expect(topic?.name, 'Trivia');
      expect(topic?.learnCards != null, true);
      expect(topic?.learnCards.length, 21);
    });
  });
}
