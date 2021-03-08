import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:new_perspective_app/enums.dart';
import 'package:new_perspective_app/interfaces.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
                                            value: time.sec / 10,
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
            appBar: AppBar(
              leading: Container(),
              actions: [
                chat != null && chat.chatState == ChatState.LIVE
                    ? Center(
                        child: CountdownTimer(
                        endTime:
                            chat.chatData['liveAt'].millisecondsSinceEpoch +
                                chat.chatData['timeLimit'],
                        widgetBuilder: (_, CurrentRemainingTime time) {
                          if (((time.min ?? 0).toDouble() * 60.0 +
                                  (time.sec ?? 0).toDouble()) <
                              30.0) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              padding: EdgeInsets.all(4),
                              child: Text(
                                  'Time Remaining: min: ${time.min ?? 0} sec: ${time.sec ?? 0}'),
                            );
                          }
                          return Text(
                              'Time Remaining: min: ${time.min ?? 0} sec: ${time.sec ?? 0}');
                        },
                        onEnd: () => chat.completeChat(),
                      ))
                    : Container(),
                Container(
                  // color: Colors.red,
                  // padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  margin: EdgeInsets.all(10),
                  child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        chat.completeChat();
                      }),
                )
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
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            "${chat.question['text']}",
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          )),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                            child: Text("New Question"),
                            onPressed: () => chat.newQuestion()),
                      )
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
              snapshot.data.sort((a, b) => b.chatData['completedAt']
                  .compareTo(a.chatData['completedAt']));
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      trailing: snapshot.data[index].chatData['userScores'] !=
                              null
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(snapshot.data[index]
                                    .chatData['userScores'][user.uid]
                                    .toString()),
                                CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      snapshot.data[index]
                                                      .chatData['userScores']
                                                  [user.uid] >
                                              7
                                          ? Colors.green
                                          : (snapshot.data[index].chatData[
                                                      'userScores'][user.uid] >
                                                  4
                                              ? Colors.orange
                                              : Colors.red)),
                                  value: snapshot.data[index]
                                          .chatData['userScores'][user.uid] /
                                      10,
                                ),
                              ],
                            )
                          : Text("N/A"),
                      title: Text(DateFormat('MM/dd/yyyy').add_jm().format(
                          snapshot.data[index].chatData['completedAt']
                              .toDate())),
                    );
                    // return ChatCard(snapshot.data[index]);
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

class InsightScorePage extends StatelessWidget {
  final Chat chat;
  final User scoringUser;
  const InsightScorePage(
    this.chat,
    this.scoringUser, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _currentSliderValue = 5;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Rate ${scoringUser.displayName} on how much insight they shared.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  Text(
                    _currentSliderValue.toString(),
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  Slider(
                    value: _currentSliderValue.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                      onPressed: () => chat
                          .scoreUser(scoringUser, _currentSliderValue)
                          .then((value) => Navigator.pop(context)),
                      child: Text("Submit"))
                ],
              );
            })
          ],
        ),
      ),
    );
  }
}

class DeclinedPage extends StatelessWidget {
  final String userName;
  const DeclinedPage({Key key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("$userName has declined your chat."),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Return to Home Screen"))
        ],
      ),
    ));
  }
}
