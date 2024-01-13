import 'dart:async';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/models/card_item.dart';
import 'package:reslate/controllers/getDocument.dart';
import 'package:reslate/screens/bottomBar.dart';

class Game {
  Game(this.gridSize) {
    getWordsList();
    matching = 24;
    score = 0;
  }
  final int gridSize;

  List<CardItem> cards = [];
  bool isGameOver = false;
  Set<IconData> icons = {};

  var docID, wordsList;

  int matching = 24;
  int score = 0;
  int topScore = 0;
  bool isCardMatchCheckInProgress = false;

  FlutterTts flutterTts = FlutterTts();
  Future<void> speak(String text) async {
    try {
      // Check the language of the input text
      String language = _detectLanguage(text);

      // Set the appropriate language for TTS
      await flutterTts.setLanguage(language);

      // Other TTS settings
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.awaitSynthCompletion(true);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);

      // Speak the text
      await flutterTts.speak(text);
    } catch (e) {
      print(e);
    }
  }

// Helper function to detect the language of the text
  String _detectLanguage(String text) {
    // Implement your language detection logic here
    // For example, you could use a language detection library or simple heuristics
    // based on character ranges for common languages

    // Example using a basic heuristic for Thai:
    if (text.contains(RegExp(r'[\u0E00-\u0E7F]+'))) {
      return "th-TH"; // Thai language code
    } else {
      return "en-US"; // Default language
    }
  }

  Future<void> getWordsList() async {
    try {
      firebaseDoc firebasedoc = firebaseDoc();
      docID = await firebasedoc.getDocumentId();
      wordsList = await firebasedoc.getCard(docID, true);
      wordsList.shuffle(Random());

      await generateCards(wordsList);
    } catch (e) {
      print(e);
    }
  }

  Future<void> generateCards(List<Map<String, dynamic>> jsonData) async {
    cards = [];

    final List<Color> cardColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.grey,
      Colors.pink,
    ];

    jsonData.sort((a, b) => a['answerCorrect'].compareTo(b['answerCorrect']));

    for (int i = 0; i < (gridSize * gridSize / 2); i++) {
      final cardData = jsonData[i];
      print(cardData['question']);
      final CardItem questionCard = CardItem(
        id: cardData['id'],
        key: cardData['question'],
        question: cardData['question'],
        color: cardColors[i % cardColors.length],
        check: i,
      );

      final CardItem thaiCard = CardItem(
        id: cardData['id'],
        key: cardData['question'],
        question: cardData['thai'],
        color: cardColors[i % cardColors.length],
        check: i,
      );

      final Color cardColor = cardColors[i % cardColors.length];
      final List<CardItem> newCards =
          _createCardItems(questionCard, thaiCard, cardColor);
      cards.addAll(newCards);
    }

    cards.shuffle(Random());
  }

  void resetGame() {
    generateCards(wordsList);
    isGameOver = false;
    matching = 24;
    score = 0;
  }

  void addMatchingTime() async {
    matching = matching + 10;
  }

  Future<void> onCardPressed(int index, BuildContext context) async {
    final collectionReference =
        FirebaseFirestore.instance.collection('Profile').doc(docID);
    final subcollectionReference = collectionReference.collection("savedWords");
    if (isGameOver || isCardMatchCheckInProgress) {
      return; // Game is already over or card match check is in progress
    }

    if (cards[index].state == CardState.visible ||
        cards[index].state == CardState.guessed) {
      return;
    }

    cards[index].state = CardState.visible;
    final List<int> visibleCardIndexes = _getVisibleCardIndexes();
    speak(cards[index].question);
    if (visibleCardIndexes.length == 2) {
      isCardMatchCheckInProgress = true;

      final CardItem card1 = cards[visibleCardIndexes[0]];
      final CardItem card2 = cards[visibleCardIndexes[1]];

      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (card1.check == card2.check) {
          card1.state = CardState.guessed;
          card2.state = CardState.guessed;
          isGameOver = _isGameOver();
          try {
            await subcollectionReference.doc(cards[index].key).update({
              'answerCorrect': FieldValue.increment(1),
            });
          } catch (e) {
            print(e);
          }
          score++;
        } else {
          card1.state = CardState.hidden;
          card2.state = CardState.hidden;
        }
        isCardMatchCheckInProgress = false;
        matching--;

        if (matching == 0) {
          _showGameOverDialog(context);

          // Fetch the current 'aids' value
          DocumentSnapshot<Map<String, dynamic>> userDocument =
              await collectionReference.get();
          int currentAids = userDocument.data()?['aids'] ?? 0;
          int level = userDocument.data()?['archiveLevel'] ?? 0;

          if (score >= 8 && score <= 15) {
            if (currentAids < 3 && level <= 2) {
              await collectionReference.update({
                'aids': FieldValue.increment(1),
              });
            }
          } else if (score >= 16 && score <= 23) {
            if (currentAids < 3 && level <= 2) {
              await collectionReference.update({
                'aids': FieldValue.increment(2),
              });
            }
          } else if (score >= 24) {
            if (currentAids < 3 && level <= 2) {
              await collectionReference.update({
                'aids': FieldValue.increment(3),
              });
            }
          }
        } else if (_isGameOver()) {
          // If all cards are matched, reset the game randomly
          resetGameRandomly();
        }
      });
    }
  }

  void resetGameRandomly() {
    // Shuffle the wordsList and generate new cards
    wordsList.shuffle(Random());
    generateCards(wordsList);

    // Reset the game state
    isGameOver = false;
    matching += 10;
  }

  void _showGameOverDialog(BuildContext context) async {
    await fetchTopScore();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red[200]!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          title: Text(
            'Game Over',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[900]!),
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                Text(
                  'Top Score\n${topScore}',
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                Text(
                  'Your score is ${score}',
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      resetGame();
                    },
                    child: Text(
                      'Play Again',
                      style: TextStyle(color: Colors.blue[700]!),
                    ),
                  ),
                  SizedBox(width: 16), // Add some spacing between buttons
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Get.to(bottombar(), transition: Transition.topLevel);
                    },
                    child: Text(
                      'Exit',
                      style: TextStyle(color: Colors.red[700]!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (matching <= 0) {
        // Handle taps outside the AlertDialog, in this case, go to bottom bar
        Get.to(bottombar(), transition: Transition.topLevel);
      }
    });
  }

  List<CardItem> _createCardItems(
      CardItem questionCard, CardItem thaiCard, Color cardColor) {
    return [
      CardItem(
          id: questionCard.id,
          question: questionCard.question,
          key: questionCard.key,
          state: CardState.hidden,
          color: cardColor,
          check: questionCard.check),
      CardItem(
          id: thaiCard.id,
          key: questionCard.key,
          question: thaiCard.question,
          state: CardState.hidden,
          color: cardColor,
          check: questionCard.check),
    ];
  }

  List<int> _getVisibleCardIndexes() {
    return cards
        .asMap()
        .entries
        .where((entry) => entry.value.state == CardState.visible)
        .map((entry) => entry.key)
        .toList();
  }

  bool _isGameOver() {
    return cards.every((card) => card.state == CardState.guessed);
  }

  Future<void> fetchTopScore() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await FirebaseFirestore.instance.collection("Profile").doc(docID).get();

    if (userDocument.exists) {
      topScore = await userDocument.data()?['cardTopScore'] ?? 0;
      print(topScore);
      if (topScore < score) {
        topScore = score;

        await FirebaseFirestore.instance
            .collection("Profile")
            .doc(docID)
            .update({'cardTopScore': topScore});
      }
    }
  }
}
