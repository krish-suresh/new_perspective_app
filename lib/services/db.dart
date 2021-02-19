import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../interfaces.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // constructor
  DBService() {}

  Stream<Chat> getChatStream(chatID) {
    return _db
        .collection('chats')
        .doc(chatID)
        .snapshots()
        .map((snapshot) => Chat.fromSnapshot(snapshot, chatID));
  }
}
