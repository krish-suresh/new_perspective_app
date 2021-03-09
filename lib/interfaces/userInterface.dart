
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../enums.dart';
import 'chatInterface.dart';

class User {
  final Map<String, dynamic> userProfile;
  String uid;
  String email;
  String photoURL;
  String displayName;
  Timestamp createdAt;
  Timestamp lastSeen;
  bool registered;
  Map<String, dynamic> userDemographicData;

  bool isVerified;
  int insightScore = 0;
  User(this.userProfile,
      {this.uid,
      this.displayName,
      this.lastSeen,
      this.photoURL,
      this.email,
      this.createdAt,
      this.registered,
      this.isVerified,
      this.userDemographicData,
      this.insightScore});
  factory User.fromJson(Map<String, dynamic> userData) {
    User user = User(
      userData,
      uid: userData['uid'],
      displayName: userData['displayName'],
      lastSeen: userData['lastSeen'],
      photoURL: userData['photoURL'],
      email: userData['email'],
      createdAt: userData['createdAt'],
      registered: userData['registered'],
      isVerified: userData['isVerified'],
      insightScore: userData['insightScore'] ?? 0,
      userDemographicData:
          Map<String, dynamic>.from(userData['userDemographicData'] ?? {}),
    );
    user.uid = userData['uid'];
    user.displayName = userData['displayName'];
    user.photoURL = userData['photoURL'];
    return user;
  }
  static Future<User> getUserFromID(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists ? User.fromJson(userDoc.data()) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid, // TODO add more fields
      'email': email,
      'photoURL': photoURL,
      'displayName': displayName,
      'createdAt': createdAt,
      'lastSeen': lastSeen,
      'registered': registered,
      'isVerified': isVerified,
      'insightScore': insightScore,
      'userDemographicData': userDemographicData
    };
  }

  updateUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(this.toJson(), SetOptions(merge: true));
  }

  addToSearchForChat() {
    FirebaseFirestore.instance
        .collection('chatSearch')
        .doc('searchingUsers')
        .update({
      'liveSearchingUsers': FieldValue.arrayUnion([uid])
    });
  }

  removeFromSearchForChat() {
    FirebaseFirestore.instance
        .collection('chatSearch')
        .doc('searchingUsers')
        .update({
      'liveSearchingUsers': FieldValue.arrayRemove([uid])
    });
  }

  Stream<String> findChat() {
    print("Searching for chat: " + uid);
    return FirebaseFirestore.instance
        .collection("chats")
        .where('users', arrayContainsAny: [uid])
        .where("chatState", isEqualTo: "CREATED")
        .snapshots(includeMetadataChanges: false)
        .map((event) {
          print("In Search");
          if (event.docs == null || event.docs.length == 0) {
            return null;
          }
          return event.docs.first.id;
        });
  }

  static Future<List<User>> getUsersFromChat(String chatID) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("chats").doc(chatID).get();
    List<String> userIDs = List.from(snapshot.data()['users']);
    return Future.wait(userIDs.map((e) async => await User.getUserFromID(e)));
  }

  static Stream<User> getStream(String uid) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((event) =>
            event.data() != null ? User.fromJson(event.data()) : null);
  }

  Future<List<Chat>> getChatHistory(String uid) async {
    return FirebaseFirestore.instance
        .collection("chats")
        .where('users', arrayContains: uid)
        .where('chatState', isEqualTo: ChatState.COMPLETED.name)
        .get()
        .then((value) => value.docs.map((e) => Chat.fromSnapshot(e)).toList());
  }

  static Future<List<User>> getLeaderboard() async {
    return await FirebaseFirestore.instance
        .collection("users")
        // .orderBy('insightScore')
        .get()
        .then((value) {
      return value.docs.map((e) => User.fromJson(e.data())).toList();
    });
  }
}

class DemographicQuestion {
  final String id;
  final String title;
  final DemographicQuestionType type;
  final bool disabled;
  final Map<String, dynamic> questionData;
  String selectedValue;
  DemographicQuestion(
      {this.id, this.title, this.type, this.disabled, this.questionData});

  factory DemographicQuestion.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> snapshotData = snapshot.data();
    return DemographicQuestion(
        id: snapshot.id,
        title: snapshotData['title'],
        type: EnumToString.fromString(
            DemographicQuestionType.values, snapshotData['type']),
        disabled: snapshotData['disabled'],
        questionData: snapshotData);
  }

  Map<String, dynamic> getValue() {
    return {
      'title': title,
      'answer': selectedValue,
    };
  }

  Widget getWidget() {
    Widget content;
    switch (type) {
      case DemographicQuestionType.dropdown:
        List<String> dropdownfields =
            List<String>.from(questionData['dropdownfields']);
        dropdownfields.add("Prefer Not to Answer");
        content = StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: title,
            ),
            value: selectedValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            onChanged: (String newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
            items: dropdownfields.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        });
        break;
      case DemographicQuestionType.textfield:
        content = TextField(
          decoration: InputDecoration(labelText: title),
          onChanged: (value) => selectedValue = value,
        );
        break;
      case DemographicQuestionType.multiselect:
        return Container();
        break;
    }
    return content;
  }

  static Future<List<DemographicQuestion>> getAllQuestions() {
    return FirebaseFirestore.instance
        .collection("userDemographicQuestions")
        .where('disabled', isEqualTo: false)
        .get()
        .then((value) => value.docs
            .map((e) => DemographicQuestion.fromSnapshot(e))
            .toList());
  }
}
