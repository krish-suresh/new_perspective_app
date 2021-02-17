import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../interfaces.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // constructor
  DBService() {}

  Future<List<Message>> getMessages(String messagesID) {}

  Future<Chat> getChat(String chatID) async {
    DocumentSnapshot snapshot = await _db.collection('chats').doc(chatID).get();
    Map<String, dynamic> chatData = snapshot.data();
    print("CHATDATETIME: " + chatData['users'].toString());

    return Chat(
        chatID: chatData[''],
        userIDs: chatData['users'],
        createdAt: chatData['createdAt'].toDate(),
        // messagesID: chatData['messages']
        );
  }
}
