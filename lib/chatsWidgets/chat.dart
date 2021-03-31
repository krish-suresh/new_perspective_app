import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:new_perspective_app/chatsWidgets/chatPrep.dart';
import 'package:new_perspective_app/enums.dart';
import 'package:new_perspective_app/interfaces/chatInterface.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'declinePage.dart';
import 'insightScore.dart';
import 'messages.dart';

class ChatWidget extends StatelessWidget {
  final String chatid;
  final List<User> users;
  ChatWidget(this.chatid, {Key key, this.users}) : super(key: key);

  Chat chat;
  bool hasMessage = false;
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    TextEditingController messagingFieldController = TextEditingController();
    User user = context.watch<User>();
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(chatid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          chat = Chat.fromSnapshot(snapshot.data);
          switch (chat.chatState) {
            case ChatState.CREATED:
              return ChatPrep(users: users, chat: chat);
            case ChatState.LIVE:
              if (chat.emotionEvent != null && chat.isEmotionEventActive()) {
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: Scaffold(
                          body: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "We detected the discussion to be getting heated, please take a quick break.",
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                      "“There are things known and there are things unknown, and in between are the doors of perception.” ― Aldous Huxley"),
                                  CountdownTimer(
                                    endTime: chat.getEmotionEventEndTime(),
                                    widgetBuilder:
                                        (_, CurrentRemainingTime time) {
                                      if (time == null) {
                                        return Container();
                                      }
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text((time.sec ?? 0).toString()),
                                          CircularProgressIndicator(
                                            value: time.sec /
                                                chat.emotionEvent[
                                                    'coolDownTimeSec'],
                                          ),
                                        ],
                                      );
                                    },
                                    onEnd: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ));
              }
              break;
            case ChatState.COMPLETED:
              // ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text("Your Chat Has Been Completed.")));
              // Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: InsightScorePage(
                              chat,
                              users
                                  .where((element) => element.uid != user.uid)
                                  .first),
                          type: PageTransitionType.fade)));

              break;
            case ChatState.DELETED:
              // ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text("Your Chat Has Been Closed.")));
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: DeclinedPage(
                              userName: users
                                  .where((element) => element.uid != user.uid)
                                  .first
                                  .displayName),
                          type: PageTransitionType.fade)));
              break;
          }

          return Scaffold(
            key: _scaffoldKey,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    new Color(0xFF492B78),
                    new Color(0xFFE4CFE1),
                  ]
                )
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                verticalDirection: VerticalDirection.up,
                children: [
                  StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 50,
                          child: TextField(
                            autofocus: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (value) {
                              chat.currentMessageText =
                                  messagingFieldController.text;
                              chat.updateUsersTyping(user.uid);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  hasMessage =
                                      messagingFieldController.text != "";
                                });
                              });
                            },
                            controller: messagingFieldController,
                            decoration: InputDecoration(
                              hintText: "Share some insight...",
                            ),
                          ),
                        ),
                        Container(
                          child: IconButton(
                            onPressed: hasMessage
                                ? () {
                                    chat.sendMessage(
                                        content: messagingFieldController.text,
                                        contentType: 'text',
                                        userID: user.uid);
                                    messagingFieldController.clear();
                                    chat.currentMessageText =
                                        messagingFieldController.text;
                                    chat.updateUsersTyping(user.uid);
                                  }
                                : null,
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ),
                      ],
                    );
                  }),
                  Expanded(child: MessageList(chat, users)),
                  GestureDetector(
                    onTap: () => chat.newQuestion(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(11, 42, 11, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              offset: new Offset(0, 4),
                              blurRadius: 2,
                              color: Color.fromARGB(64, 0, 0, 0),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "${chat.question['text']}",
                                style: Theme.of(context).textTheme.headline2,
                                textAlign: TextAlign.center,
                              ),
                              chat != null && chat.chatState == ChatState.LIVE
                              ? Center(
                                child: CountdownTimer(
                                endTime: chat.chatData['liveAt'].millisecondsSinceEpoch + chat.chatData['timeLimit'],
                                widgetBuilder: (_, CurrentRemainingTime time) {
                                  if (((time.min ?? 0).toDouble() * 60.0 + (time.sec ?? 0).toDouble()) < 30.0) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(5))),
                                      padding: EdgeInsets.all(4),
                                      child: Text('${time.min ?? 0}:${(time.sec < 10) ? 0 : ""}${time.sec ?? 0}', style: Theme.of(context).textTheme.headline3),
                                    );
                                  }
                                  return Text('${time.min ?? 0}:${(time.sec < 10) ? 0 : ""}${time.sec ?? 0}', style: Theme.of(context).textTheme.headline3);
                                },
                                onEnd: () => chat.completeChat(),
                              )) : Container(),

                            ],
                          ),
                        )),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class UserTypingWidget extends StatelessWidget {
  final Map<String, bool> usersTyping;
  final List<User> users;
  const UserTypingWidget(this.usersTyping, this.users, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    User myUser = context.watch<User>();
    List<String> namesTyping = [];
    for (User user in users) {
      if (myUser.uid != user.uid && usersTyping[user.uid]) {
        namesTyping.add(user.displayName);
      }
    }
    String names = namesTyping.join(" ");
    return namesTyping.length > 0
        ? Container(
            child: Row(
              children: [
                Text("$names is typing"),
                // JumpingDotsProgressIndicator(
                //   numberOfDots: 6,
                // ),
              ],
            ),
          )
        : Container();
  }
}

class ChatCard extends StatelessWidget {
  final Chat chat;
  const ChatCard(this.chat, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    return Card(
      child: Column(
        children: [
          Text("Chat on ${chat.chatData['completedAt'].toDate()}"),
          Text(
              "Insight Score: ${chat.chatData['userScores'] != null ? chat.chatData['userScores'][user.uid] ?? 'N/A' : 'N/A'}")
        ],
      ),
    );
  }
}
