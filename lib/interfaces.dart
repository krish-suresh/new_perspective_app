import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String contentType;
  final String content;
  final DateTime timestamp;
  final String messageType;
  final String messageID;
  const Message(this.messageID,
      {this.contentType, this.content, this.timestamp, this.messageType});
      //Remove const if edit message added
  
}

class Chat {
  final DateTime createdAt;
  final List<String> userIDs;
  final String chatID;
  String messagesID;
  List<User> usersTyping;
  Chat({this.createdAt, this.userIDs, this.chatID}) {
    print("CHATID: " + this.chatID);
  }

  Stream<List<Message>> getMessageStream() {
    return null;
  }

  void updateUsersTyping() {

  }
}
