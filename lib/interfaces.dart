import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String contentType;
  final String content;
  final DateTime sentAt;
  final String userID;
  const Message({this.userID, this.contentType, this.content, this.sentAt});
  factory Message.fromJSON(Map<String, dynamic> data) {
    print(data);
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
  List<User> usersTyping;
  Chat({this.createdAt, this.userIDs, this.chatID});

  factory Chat.fromSnapshot(DocumentSnapshot snapshot, String chatID) {
    Map<String, dynamic> chatData = snapshot.data();
    print("CHATID: " + snapshot.id);
    Chat chat = Chat(
      chatID: snapshot.id,
      userIDs: List.from(chatData['users']),
      createdAt: chatData['createdAt'].toDate(),
    );
    chat.messages = List<Message>.from(
        chatData['messages'].map((data) => Message.fromJSON(data)));
    chat.messages.sort((a, b) => a.sentAt.isAfter(b.sentAt) ? 1 : -1);
    return chat;
  }

  Stream<List<Message>> getMessageStream() {
    return null;
  }

  void updateUsersTyping() {}

  sendMessage({String content, String contentType, String userID}) {
    Message message = Message(
        content: content,
        contentType: contentType,
        userID: userID,
        sentAt: DateTime.now());
    FirebaseFirestore.instance
        .collection('chats')
        .doc('YeuRc4NmQ8NPY9QsJ95T')
        .update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }
}
