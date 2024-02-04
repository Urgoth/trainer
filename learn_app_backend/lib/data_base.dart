import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import 'mc_topic.dart';
import 'mc_card.dart';

final pb = PocketBase('http://172.17.0.2:8080/');

/// A collection of static methods to use the Database
class DataBaseHandler {
  /// creates a new user with given [username], [email] and [password]
  static Future<(bool, String)> createUser(String username, String email,
      String password, String passwordConfirm) async {
    try {
      await pb.collection('users').create(body: {
        'username': username,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm
      });
      return (true, 'Succsessfully created user: $username');
    } on ClientException catch (e) {
      if (kDebugMode) {
        print('Statuscode: ${e.statusCode}');
        print('Statuscode: ${e.response}');
      }
      return (false, (e.response['message'] as String));
    } catch (e) {
      rethrow;
    }
  }

  /// Login a User with the given [email] and [password]
  static Future<(bool, String)> login(String email, String password) async {
    try {
      final authData = await pb.collection('users').authWithPassword(
            email,
            password,
          );
      if (kDebugMode) {
        print(authData);
      }
      return (true, 'Succsessfully logged in as $email');
    } on ClientException catch (e) {
      if (kDebugMode) {
        print('Statuscode: ${e.statusCode}');
        print('Statuscode: ${e.response}');
      }
      return (false, (e.response['message'] as String));
    } catch (e) {
      rethrow;
    }
  }

  /// Logout the current user.
  static bool logout() {
    pb.authStore.clear();
    return true;
  }

  static Future<McTopic?> getTopic(String topicId) async {
    try {
      var record =
          await pb.collection('mc_topics').getOne(topicId, expand: 'mc_cards');

      var topicJson = {
        'id': record.getStringValue('id'),
        'author': record.getStringValue('author'),
        'created': record.getStringValue('created'),
        'updated': record.getStringValue('updated'),
        'name': record.getStringValue('name'),
        'description': record.getStringValue('description'),
        'mc_cards': record.getListValue('mc_cards'),
      };

      var topic = McTopic.fromJson(topicJson);
      return topic;
    } on ClientException catch (e) {
      if (kDebugMode) {
        print('Statuscode: ${e.statusCode}');
        print('Statuscode: ${e.response}');
      }
      return null;
    }
  }

  // static Future<List<McTopic>> getTopics() async {
  //   try {} on ClientException catch (e) {
  //     if (kDebugMode) {
  //       print('Statuscode: ${e.statusCode}');
  //       print('Statuscode: ${e.response}');
  //     }
  //     return [];
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  /// insert [McTopic] into the Database and updates ids.
  static Future<bool> insertMcTopic(McTopic topic) async {
    try {
      List<String> cardIds = [];
      for (var card in topic.learnCards) {
        final body = <String, dynamic>{
          "question": card.question,
          "answers": answersToJsonString(card),
          "author": card.authorId,
          "moderators": [],
        };

        var res = await pb.collection('mc_cards').create(body: body);
        card.id = res.id;
        cardIds.add(card.id);
        card.lastModified = DateTime.parse(res.updated);
        if (kDebugMode) {
          print(res);
        }
      }

      // create the mc_topics entry
      final topicsBody = <String, dynamic>{
        "name": topic.name,
        "description": topic.description,
        "mc_cards": cardIds,
        "author": topic.authorId,
        "moderator": [],
      };

      final result = await pb.collection('mc_topics').create(body: topicsBody);
      topic.id = result.id;
      topic.lastModified = DateTime.parse(result.updated);
      if (kDebugMode) {
        print(result);
      }

      return true;
    } on ClientException catch (e) {
      if (kDebugMode) {
        print('Statuscode: ${e.statusCode}');
        print('Statuscode: ${e.response}');
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> syncTopic(McTopic topic) async {
    try {
      // TODO: make id to topic.id
      var res = await pb
          .collection('mc_topics')
          .getOne('qstnq4b4j2n88up', fields: 'mc_cards');
      List<String> dbCardIds = List<String>.from(
          res.data['mc_cards'].map((e) => e.toString()).toList());
      print('dbCardIds: $dbCardIds');

      var res2 = await pb
          .collection('mc_topics')
          .getOne('qstnq4b4j2n88up', expand: 'mc_cards');

      List<(String, DateTime)> cardIdToUpdatedDate = [];
      if (res2.expand['mc_cards'] != null) {
        cardIdToUpdatedDate = List<(String, DateTime)>.from(res2
            .expand['mc_cards']!
            .map((e) => (e.id.toString(), DateTime.parse(e.updated))));
      }

      print(cardIdToUpdatedDate);

      // 3 Listen: 1. Update 2. Upload 3. Delete

      List<MultipleChoiceCard> toUpload = topic.learnCards
          .where((element) =>
              !cardIdToUpdatedDate.map((e) => e.$1).contains(element.id))
          .toList();
      print('toUpload: $toUpload');

      List<MultipleChoiceCard> toSync = topic.learnCards
          .where((element) =>
              cardIdToUpdatedDate.map((e) => e.$1).contains(element.id))
          .toList();
      print('toSync before remove: $toSync');
      toSync.removeWhere((element) =>
          cardIdToUpdatedDate.contains((element.id, element.lastModified)));
      print('toSync: $toSync');

      List<String> toDelete = dbCardIds
          .where(
              (element) => topic.learnCards.map((e) => e.id).contains(element))
          .toList();

      return true;
    } on ClientException catch (e) {
      if (kDebugMode) {
        print('Statuscode: ${e.statusCode}');
        print('Statuscode: ${e.response}');
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> _appendCardsToMcTopic(
      McTopic topic, List<MultipleChoiceCard> cards) async {
    try {
      List<String> cardIds = [];
      for (var card in cards) {
        final body = <String, dynamic>{
          "question": card.question,
          "answers": answersToJsonString(card),
          "author": card.authorId,
          "moderators": [],
        };

        var res = await pb.collection('mc_cards').create(body: body);
        card.id = res.id;
        cardIds.add(card.id);
        card.lastModified = DateTime.parse(res.updated);
        if (kDebugMode) {
          print(res);
        }
      }

      final result = await pb.collection('mc_topics').update(topic.id, body: {
        // append multiple tags at once
        'mc_cards+': cardIds,
      });

      topic.lastModified = DateTime.parse(result.updated);
      if (kDebugMode) {
        print(result);
      }

      return true;
    } on ClientException catch (e) {
      if (kDebugMode) {
        print('Statuscode: ${e.statusCode}');
        print('Statuscode: ${e.response}');
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// A debug Method that prints out the available authentification methods.
  static void listAuthMethods() async {
    try {
      final result = await pb.collection('users').listAuthMethods();
      if (kDebugMode) {
        print(result);
      }
    } on ClientException catch (e) {
      if (kDebugMode) {
        print('Statuscode: ${e.statusCode}');
        print('Statuscode: ${e.response}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
