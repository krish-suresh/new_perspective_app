import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:new_perspective_app/enums.dart';
import 'package:new_perspective_app/interfaces.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'messages.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();

    return Scaffold(
      // appBar: AppBar(),
      body: StreamBuilder<String>(
          stream: user.findChat(),
          builder: (context, snapshot) {
            print("Chat Data" + snapshot.toString());
            if (snapshot.hasError) {
            } else if (snapshot.hasData && snapshot.data != null) {
              print("ChatID: " + snapshot.data);
              user.removeFromSearchForChat();
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: ChatWidget(snapshot.data),
                          type: PageTransitionType.fade)));
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.black,
                    size: 100,
                  ),
                  Text("Searching for chat..."),
                  Container(
                      padding: EdgeInsets.all(15),
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator()),
                  OutlinedButton(
                    onPressed: () {
                      user.removeFromSearchForChat();
                      Navigator.pop(context);
                    },
                    child: Text("End Search"),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class ChatWidget extends StatefulWidget {
  // TODO Make stateless
  final String chatid;
  ChatWidget(this.chatid, {Key key}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Chat chat;
  List<User> users = [];
  bool usersLoaded = false;
  bool hasMessage = false;
  @override
  Widget build(BuildContext context) {
    TextEditingController messagingFieldController = TextEditingController();
    User user = context.watch<User>();
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        actions: [
          chat != null && chat.chatState == ChatState.LIVE
              ? Center(
                  child: CountdownTimer(
                  endTime: chat.chatData['liveAt'].millisecondsSinceEpoch +
                      chat.chatData['timeLimit'],
                  onEnd: () => chat.disableChat(),
                ))
              : Container(),
          IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                chat.disableChat();
                Navigator.pop(context);
              })
        ],
      ),
      body: Column(
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
                      chat.currentMessageText = messagingFieldController.text;
                      chat.updateUsersTyping(user.uid);
                      setState(() {
                        hasMessage = messagingFieldController.text != "";
                      });
                    },
                    controller: messagingFieldController,
                    decoration: InputDecoration(
                      hintText: "Share some insight",
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
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                chat = Chat.fromSnapshot(snapshot.data);
                // return ChatWidget(chat);
                if (chat != null && !usersLoaded) {
                  loadUsers();
                }
                // usersLoaded
                // ? UserTypingWidget(chat.usersTyping, users)
                // : Container(),
                return MessageList(chat, usersLoaded, users);
              },
            ),
          ),
        ],
      ),
    );
  }

  void loadUsers() async {
    users.clear();
    for (String uid in chat.userIDs) {
      users.add(await User.getUserFromID(uid));
    }
    setState(() {
      usersLoaded = true;
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
