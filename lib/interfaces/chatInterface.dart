
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

import '../enums.dart';
import 'messageInterface.dart';

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
  final Map<String, dynamic> emotionEvent;
  Chat(
      {this.messages,
      this.usersTyping,
      this.chatData,
      this.chatState,
      this.userIDs,
      this.chatID,
      this.usersStatus,
      this.question,
      this.emotionEvent});

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
        question: chatData['question'],
        emotionEvent: chatData['emotionEvent']);
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
    print(question['random']);
    int r = 0;
    do {
      r = Random().nextInt(10);
    } while (r.toString() == question['random']);
    print("New Question " + r.toString());
    FirebaseFirestore.instance
        .collection('questions')
        .where('random', isEqualTo: r.toString())
        .get()
        .then((value) {
      if (value.docs.length == 0) {
        return;
      }

      Map<String, dynamic> data = value.docs.first.data();
      FirebaseFirestore.instance.collection('chats').doc(chatID).update({
        'question': {
          'id': data['id'],
          'text': data['question'],
          'random': data['random']
        }
      });
    });
  }

  Future<void> scoreUser(User user, int currentSliderValue) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatID).update(
        {'userScores.${user.uid}': currentSliderValue}).then((value) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'insightScore': user.insightScore + currentSliderValue});
    });
  }

  bool isEmotionEventActive() {
    return this.emotionEvent['createdAt'].millisecondsSinceEpoch +
            (this.emotionEvent['coolDownTimeSec'] * 1000) >
        Timestamp.now().millisecondsSinceEpoch;
  }

  getEmotionEventEndTime() {
    return this.emotionEvent['createdAt'].millisecondsSinceEpoch +
        (this.emotionEvent['coolDownTimeSec'] * 1000);
  }
}
