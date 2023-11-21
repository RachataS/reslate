import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reslate/models/profile.dart';

class firebaseDoc {
  Profile profile = Profile();
  late DocumentReference firebaseDocument;
  Map<String, dynamic>? data, document;
  // For email login
  var userEmail = FirebaseAuth.instance.currentUser?.email;

// For Google sign-in
  var userUID = FirebaseAuth.instance.currentUser?.uid;
  var username, email;

  CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("Profile");

  Future<String?> getDocumentId() async {
    try {
      String? userId;
      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      String? userUID = FirebaseAuth.instance.currentUser?.uid;

      if (userEmail != null) {
        // Query the collection for the user with the specified email
        var querySnapshot = await FirebaseFirestore.instance
            .collection('Profile')
            .where('Email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If the user with the specified email exists, get their document ID
          userId = querySnapshot.docs.first.id;
        }
      } else if (userUID != null) {
        // Query the collection for the user with the specified UID
        var querySnapshot = await FirebaseFirestore.instance
            .collection('Profile')
            .where('Email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If the user with the specified UID exists, get their document ID
          userId = querySnapshot.docs.first.id;
        }
      }
      profile.docID = userId;
      return userId;
    } catch (e) {
      print('Error getting document ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      // Get the current user ID or a random ID
      var docID = await getDocumentId();
      // ดึงข้อมูลได้แต่ยังเอา document id มาที่หน้า menu ไม่ได้
      if (docID == null) {
        firebaseDocument =
            await FirebaseFirestore.instance.collection('Profile').doc();
      } else {
        firebaseDocument = await FirebaseFirestore.instance
            .collection('Profile')
            .doc('$docID');
      }
      document = getDocumentData() as Map<String, dynamic>?;
      return document;
    } catch (e) {
      print('Error initializing page: $e');
    }
  }

  Future<Map<String, dynamic>?> getDocumentData() async {
    DocumentSnapshot documentSnapshot = await firebaseDocument.get();
    if (documentSnapshot.exists) {
      data = await documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        username = await data?['Username'];
        email = await data?['Email'];
        return data;
      } else {
        print('Data is null or not a Map<String, dynamic>');
      }
    } else {
      print('Document does not exist');
    }
  }

  Future<int> getSavedWords(
      numberOfQuestion, bool savedWordsData, docID) async {
    List<Map<String, dynamic>> savedWords = [];

    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(docID);
    QuerySnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
        await userDocumentRef.collection("savedWords").get();

    savedWordsQuerySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> data = doc.data();
      savedWords.add(data);
    });
    savedWords.shuffle(Random());

    if (savedWords.isNotEmpty) {
      // Sort the savedWords list based on the chosen field and order
      String sortByField = savedWordsData ? "answerCorrect" : "answerWrong";
      savedWords.sort((a, b) => a[sortByField].compareTo(b[sortByField]));

      if (!savedWordsData) {
        savedWords = savedWords.reversed.toList();
      }

      Random random = Random();

      if (numberOfQuestion <= savedWords.length) {
        List<int> randomIndices = [];

        for (int a = 0; a < numberOfQuestion && a < savedWords.length; a++) {
          Map<String, dynamic> randomWord = savedWords[a];
          String thaiKey = randomWord['thai'];
          String engKey = randomWord['question'];
          String thaiKey1, thaiKey2, thaiKey3;
          List<dynamic> reviewList = randomWord['options'];

          try {
            if (reviewList.length < 5) {
              // Update the "beQuestion" field to true for the selected word
              savedWords[a]['beQuestion'] = true;

              while (randomIndices.length < 3) {
                int randomIndex;
                do {
                  randomIndex = random.nextInt(savedWords.length);
                } while (randomIndex == a ||
                    randomIndices.contains(randomIndex)); // Avoid duplicates
                randomIndices.add(randomIndex);
              }

              // Get the Thai keys for the randomly selected incorrect answers
              List randomThaiKeys = randomIndices
                  .map((index) {
                    if (index < savedWords.length) {
                      return savedWords[index]['thai'];
                    } else {
                      return null;
                    }
                  })
                  .where((key) => key != null)
                  .toList();

              // Ensure that the correct answer is not in the list of incorrect answers
              randomThaiKeys.remove(thaiKey);

              if (randomThaiKeys.length >= 3) {
                thaiKey1 = randomThaiKeys[0];
                thaiKey2 = randomThaiKeys[1];
                thaiKey3 = randomThaiKeys[2];

                await saveChoice(
                    engKey, thaiKey, thaiKey1, thaiKey2, thaiKey3, docID);
              }
            }
          } catch (e) {
            print('random choice error ${e}');
          }
          // print('${a} = ${engKey}');
        }

        // Update the Firestore documents to set "beQuestion" to false for the remaining words
        for (int i = numberOfQuestion; i < savedWords.length; i++) {
          savedWords[i]['beQuestion'] = false;
        }

        // Batch Firestore updates for "beQuestion" values
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (Map<String, dynamic> wordData in savedWords) {
          DocumentReference docRef = userDocumentRef
              .collection("savedWords")
              .doc(wordData['question']);
          batch.set(
            docRef,
            {'beQuestion': wordData['beQuestion']},
            SetOptions(merge: true),
          );
        }
        await batch.commit();
      } else {
        Fluttertoast.showToast(
            msg: "คุณมีคำศัพท์ไม่ถึง ${numberOfQuestion} คำ",
            gravity: ToastGravity.TOP);
      }
    } else {
      Fluttertoast.showToast(
          msg: "คุณมีคำศัพท์ไม่ถึง ${numberOfQuestion} คำ",
          gravity: ToastGravity.TOP);
    }
    return savedWords.length;
  }

  Future<void> saveChoice(
      question, correctAnswer, answer1, answer2, answer3, docID) async {
    // print('${question} ${correctAnswer} ${answer1} ${answer2} ${answer3}');

    try {
      DocumentReference<Map<String, dynamic>> newDocumentRef =
          userCollection.doc(docID).collection("savedWords").doc(question);

      // Create an array of answers with the correct answer included
      List<String> answerArray = [correctAnswer, answer1, answer2, answer3];

      // Shuffle the answerArray to randomize the order
      answerArray.shuffle();

      // Find the index of the correct answer within the shuffled array
      int correctAnswerIndex = answerArray.indexOf(correctAnswer);

      Map<String, dynamic> dataToStore = {
        "options": answerArray,
        "answer_index": correctAnswerIndex,
      };
      await newDocumentRef.set(dataToStore, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestion(docID, savedWordsData) async {
    List<Map<String, dynamic>> firestoreData = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await userCollection
          .doc(docID)
          .collection("savedWords")
          .where("beQuestion", isEqualTo: true)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        Map<String, dynamic> data = document.data();
        if (data['options'] != null && data['options'].length > 1) {
          firestoreData.add(data);
        }
      }

      // Determine whether to sort by answerCorrect or answerWrong
      String sortByField =
          savedWordsData ?? false ? "answerCorrect" : "answerWrong";

      // Sort the data based on the chosen field
      firestoreData.sort((a, b) => a[sortByField].compareTo(b[sortByField]));

      // Determine whether to show questions in ascending or descending order
      bool ascendingOrder = (savedWordsData ?? false)
          ? (firestoreData.last[sortByField] <= 0)
          : (firestoreData.first[sortByField] <= 0);

      // If ascending order, reverse the list
      if (ascendingOrder) {
        firestoreData = List.from(firestoreData.reversed);
      }
      // int numberOfQuestion = numberOfQuestion ?? 0;
      // while (firestoreData.length < numberOfQuestion) {
      //   print(firestoreData.length);
      //   firebaseDoc firebasedoc = firebaseDoc();
      //   await firebasedoc.getSavedWords(
      //       numberOfQuestion, widget.savedWordsData ?? true, widget.docID);
      // }

      return firestoreData;
    } catch (e) {
      print("Error fetching data: $e");
      return []; // Return an empty list on error
    }
  }

  Future<List<Map<String, dynamic>>> getCard(docID, savedWordsData) async {
    List<Map<String, dynamic>> firestoreData = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await userCollection.doc(docID).collection("savedWords").get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        Map<String, dynamic> data = document.data();
        if (data['options'] != null && data['options'].length > 1) {
          firestoreData.add(data);
        }
      }

      // Determine whether to sort by answerCorrect or answerWrong
      String sortByField =
          savedWordsData ?? false ? "answerCorrect" : "answerWrong";

      // Sort the data based on the chosen field
      firestoreData.sort((a, b) => a[sortByField].compareTo(b[sortByField]));

      // Determine whether to show questions in ascending or descending order
      bool ascendingOrder = (savedWordsData ?? false)
          ? (firestoreData.last[sortByField] <= 0)
          : (firestoreData.first[sortByField] <= 0);

      // If ascending order, reverse the list
      if (ascendingOrder) {
        firestoreData = List.from(firestoreData.reversed);
      }
      // int numberOfQuestion = numberOfQuestion ?? 0;
      // while (firestoreData.length < numberOfQuestion) {
      //   print(firestoreData.length);
      //   firebaseDoc firebasedoc = firebaseDoc();
      //   await firebasedoc.getSavedWords(
      //       numberOfQuestion, widget.savedWordsData ?? true, widget.docID);
      // }

      return firestoreData;
    } catch (e) {
      print("Error fetching data: $e");
      return []; // Return an empty list on error
    }
  }
}
