import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'enums.dart';

class Message {
  final String contentType;
  final String content;
  final DateTime sentAt;
  final String userID;
  const Message({this.userID, this.contentType, this.content, this.sentAt});
  factory Message.fromJSON(Map<String, dynamic> data) {
    return Message(
        userID: data['userID'],
        content: data['content'],
        contentType: data['contentType'],
        sentAt: data['sentAt'].toDate());
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': this.userID,
      'content': this.content,
      'contentType': this.contentType,
      'sentAt': this.sentAt
    };
  }
  //Remove const if edit message added

}

class Chat {
  final List<String> userIDs;
  final String chatID;
  final List<Message> messages;
  final Map<String, bool> usersTyping;
  String currentMessageText = "";
  final Map<String, dynamic> chatData;
  final ChatState chatState;
  final Map<String, ChatUserStatus> usersStatus;
  final Map<String, dynamic> question;
  Chat(
      {this.messages,
      this.usersTyping,
      this.chatData,
      this.chatState,
      this.userIDs,
      this.chatID,
      this.usersStatus,
      this.question});

  factory Chat.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> chatData = snapshot.data();
    Chat chat = Chat(
        chatID: snapshot.id,
        userIDs: List.from(chatData['users']),
        messages: List<Message>.from(
            chatData['messages'].map((data) => Message.fromJSON(data))),
        usersTyping: Map<String, bool>.from(chatData['usersTyping']),
        chatData: chatData,
        chatState: EnumToString.fromString(
          ChatState.values,
          chatData['chatState'],
        ),
        usersStatus: Map<String, String>.from(chatData['usersStatus']).map(
            (key, value) => MapEntry(
                key, EnumToString.fromString(ChatUserStatus.values, value))),
        question: chatData['question']);
    chat.messages.sort((a, b) => a.sentAt.isBefore(b.sentAt) ? 1 : -1);
    return chat;
  }

  void updateUsersTyping(String userid) {
    bool typing = currentMessageText != "";
    if (usersTyping[userid] != typing) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatID)
          .update({'usersTyping.' + userid: typing});
    }
  }

  sendMessage({String content, String contentType, String userID}) {
    print("Sending Message: " + content);
    Message message = Message(
        content: content,
        contentType: contentType,
        userID: userID,
        sentAt: DateTime.now());
    FirebaseFirestore.instance.collection('chats').doc(chatID).update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  deleteChat() {
    FirebaseFirestore.instance.collection('chats').doc(chatID).update({
      'deletedAt': Timestamp.now(),
      'chatState': EnumToString.convertToString(ChatState.DELETED)
    });
  }

  void userDecline(String uid) {
    usersStatus[uid] = ChatUserStatus.DECLINED;
    FirebaseFirestore.instance.collection('chats').doc(chatID).update({
      'usersStatus': usersStatus.map(
          (key, value) => MapEntry(key, EnumToString.convertToString(value)))
    }).then((value) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatID)
          .update({'chatState': 'DELETED'});
    });
  }

  void userAccept(String uid) {
    usersStatus[uid] = ChatUserStatus.ACCEPTED;
    FirebaseFirestore.instance.collection('chats').doc(chatID).update({
      'usersStatus': usersStatus.map(
          (key, value) => MapEntry(key, EnumToString.convertToString(value)))
    }).then((value) {
      if (usersStatus.values
          .every((element) => element == ChatUserStatus.ACCEPTED)) {
        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatID)
            .update({'chatState': 'LIVE', 'liveAt': Timestamp.now()});
      }
    });
  }

  completeChat() {
    FirebaseFirestore.instance.collection('chats').doc(chatID).update({
      'completedAt': Timestamp.now(),
      'chatState': EnumToString.convertToString(ChatState.COMPLETED)
    });
  }

  newQuestion() {
    print("New Question");
    FirebaseFirestore.instance
        .collection('questions')
        .where('id', isNotEqualTo: question['id'])
        .get()
        .then((value) {
      if (value.docs.length == 0) {
        return;
      }

      Map<String, dynamic> data = value.docs.first.data();
      FirebaseFirestore.instance.collection('chats').doc(chatID).update({
        'question': {'id': data['id'], 'text': data['question']}
      });
    });
  }
}

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
  User(this.userProfile,
      {this.uid,
      this.displayName,
      this.lastSeen,
      this.photoURL,
      this.email,
      this.createdAt,
      this.registered,
      this.isVerified});
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
    );
    user.uid = userData['uid'];
    user.displayName = userData['displayName'];
    user.photoURL = userData['photoURL'];
    return user;
  }
  static Future<User> getUserFromID(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc != null ? User.fromJson(userDoc.data()) : null;
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
      'isVerified': isVerified
    };
  }

  registerUser(String text) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'registered': true,
    }, SetOptions(merge: true));
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
}
