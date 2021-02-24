import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final DateTime createdAt;
  final List<String> userIDs;
  final String chatID;
  List<Message> messages;
  Map<String, bool> usersTyping;
  String currentMessageText = "";
  Chat({this.createdAt, this.userIDs, this.chatID});

  factory Chat.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> chatData = snapshot.data();
    Chat chat = Chat(
      chatID: snapshot.id,
      userIDs: List.from(chatData['users']),
      createdAt: chatData['createdAt'].toDate(),
    );
    chat.messages = List<Message>.from(
        chatData['messages'].map((data) => Message.fromJSON(data)));
    chat.messages.sort((a, b) => a.sentAt.isBefore(b.sentAt) ? 1 : -1);
    chat.usersTyping = Map<String, bool>.from(chatData['usersTyping']);
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

  disableChat() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatID)
        .update({'disabledAt': Timestamp.now()});
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'registered': true}, SetOptions(merge: true));
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
    return FirebaseFirestore.instance
        .collection("chats")
        .where("disabledAt", isNull: true)
        .where('users', arrayContains: uid)
        .snapshots()
        .map((event) {
      return event.docs.first.id;
    });
  }
}
