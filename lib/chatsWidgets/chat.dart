import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:new_perspective_app/enums.dart';
import 'package:new_perspective_app/interfaces.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'messages.dart';

class ChatWaitingPage extends StatelessWidget {
  const ChatWaitingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    Widget searchingContent = Center(
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
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Chat Search Stopped")));
              Navigator.pop(context);
            },
            child: Text("End Search"),
          ),
        ],
      ),
    );
    return Scaffold(
      // appBar: AppBar(),
      body: StreamBuilder<String>(
          stream: user.findChat(),
          builder: (context, snapshot) {
            print("Chat Data" + snapshot.toString());
            if (snapshot.hasError) {
            } else if (snapshot.hasData && snapshot.data != null) {
              String chatID = snapshot.data;
              print("ChatID: " + snapshot.data);
              user.removeFromSearchForChat();
              return FutureBuilder<List<User>>(
                  future: User.getUsersFromChat(chatID),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<User>> snapshot) {
                    if (snapshot.hasData) {
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  child:
                                      ChatWidget(chatID, users: snapshot.data),
                                  type: PageTransitionType.fade)));
                    }
                    return searchingContent;
                  });
            }
            return searchingContent;
          }),
    );
  }
}

class ChatWidget extends StatelessWidget {
  final String chatid;
  final List<User> users;
  ChatWidget(this.chatid, {Key key, this.users}) : super(key: key);

  Chat chat;
  bool hasMessage = false;
  @override
  Widget build(BuildContext context) {
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
              User toUser = users.firstWhere((a) => a.uid != user.uid);
              Widget profilePhoto = toUser.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        toUser.photoURL,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container();

              Widget userStatus = Container();
              switch (chat.usersStatus[toUser.uid]) {
                case ChatUserStatus.ACCEPTED:
                  userStatus = Text("${toUser.displayName} has accepted.");
                  break;

                case ChatUserStatus.NORESPONSE:
                  userStatus = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Waiting for ${toUser.displayName} to response."),
                      CircularProgressIndicator()
                    ],
                  );
                  break;
                case ChatUserStatus.DECLINED:
                case ChatUserStatus.DISCONNECTED:
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text("Your Chat Has Closed.")));
                  // WidgetsBinding.instance
                  //     .addPostFrameCallback((_) => Navigator.pushReplacement(
                  //           context,
                  //           PageTransition(
                  //             type: PageTransitionType.fade,
                  //             child: ChatWaitingPage(),
                  //           ),
                  //         ));
                  break;
              }
              return Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      Spacer(
                        flex: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("You have been matched with:"),
                      ),
                      profilePhoto,
                      Expanded(
                        child: Text(
                          toUser.displayName,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Text("Add some info here"),
                      Spacer(
                        flex: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              chat.userDecline(user.uid);
                              // WidgetsBinding.instance.addPostFrameCallback(
                              //     (_) => Navigator.pushReplacement(
                              //           context,
                              //           PageTransition(
                              //             type: PageTransitionType.fade,
                              //             child: ChatWaitingPage(),
                              //           ),
                              //         ));
                            },
                            child: Text("Decline"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              onPrimary: Colors.white,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => chat.userAccept(user.uid),
                            child: Text("Accept"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      userStatus,
                      Spacer(
                        flex: 5,
                      )
                    ],
                  ),
                ),
              );
            case ChatState.LIVE:
              // TODO: Handle this case.
              break;
            case ChatState.COMPLETED:
              // ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text("Your Chat Has Been Completed.")));
              Navigator.pop(context);
              return Container();
              break;
            case ChatState.DELETED:
              // ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text("Your Chat Has Been Closed.")));
              Navigator.pop(context);
              break;
          }
          return Scaffold(
            appBar: AppBar(
              leading: Container(),
              actions: [
                chat != null && chat.chatState == ChatState.LIVE
                    ? Center(
                        child: CountdownTimer(
                        endTime:
                            chat.chatData['liveAt'].millisecondsSinceEpoch +
                                chat.chatData['timeLimit'],
                        onEnd: () => chat.completeChat(),
                      ))
                    : Container(),
                IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      chat.completeChat();
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
                            chat.currentMessageText =
                                messagingFieldController.text;
                            chat.updateUsersTyping(user.uid);
                            setState(() {
                              hasMessage = messagingFieldController.text != "";
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
                Container(
                  child: Row(
                    children: [
                      Text("Discussion Question: ${chat.question['text']}"),
                      IconButton(
                          icon: Icon(Icons.arrow_right),
                          onPressed: () => chat.newQuestion())
                    ],
                  ),
                ),
              ],
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

class ChatHistoryList extends StatelessWidget {
  const ChatHistoryList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    return Container(
      child: FutureBuilder<List<Chat>>(
        future: user.getChatHistory(user.uid),
        builder: (BuildContext context, AsyncSnapshot<List<Chat>> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong while fetching chat history. :(");
          } else if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Text("You have no chats.");
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ChatCard(snapshot.data[index]);
                  });
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Loading Chat History..."),
              SizedBox(
                height: 50,
              ),
              CircularProgressIndicator()
            ],
          );
        },
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final Chat chat;
  const ChatCard(this.chat, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [Text("Chat ${chat.chatID}")],
      ),
    );
  }
}
