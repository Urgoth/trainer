import '../mc_topic.dart';
import '../mc_card.dart';
import './mc_cards_test_data.dart';

McTopic testTopic() {
  McTopic testTopic = McTopic(
      authorId: '5pnwul2gbstia35',
      name: 'Trivia',
      description: 'Die wirklich wichtigen Fragen',
      learnCards: <MultipleChoiceCard>[]);
  for (var card in testCards.sublist(0, 20)) {
    testTopic.addCard(card['question'], card['answers']);
  }
  return testTopic;
}

McTopic testTopic2() {
  McTopic testTopic = McTopic(
      authorId: '5pnwul2gbstia35',
      name: 'Trivia Subset',
      description: 'Die wirklich wichtigen Fragen',
      learnCards: <MultipleChoiceCard>[]);
  for (var card in testCards.sublist(0, 10)) {
    testTopic.addCard(card['question'], card['answers']);
  }
  return testTopic;
}
