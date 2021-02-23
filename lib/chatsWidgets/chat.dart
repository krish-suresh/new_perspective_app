import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/interfaces.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  final String chatid;
  const ChatPage(this.chatid, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ChatWidget(chatid),
    );
  }
}

class ChatWidget extends StatefulWidget {
  final String chatid;
  ChatWidget(this.chatid, {Key key}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Chat chat;
  List<User> users = [];
  bool usersLoaded = false;
  @override
  Widget build(BuildContext context) {
    // Chat chat = context.watch<Chat>();
    TextEditingController messagingFieldController = TextEditingController();
    User user = context.watch<User>();

    double cWidth = MediaQuery.of(context).size.width * 0.95;
    return Column(
      mainAxisSize: MainAxisSize.max,
      verticalDirection: VerticalDirection.up,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  chat.currentMessageText = messagingFieldController.text;
                  chat.updateUsersTyping(user.uid);
                },
                controller: messagingFieldController,
                decoration: InputDecoration(
                  hintText: "Enter a message",
                ),
              ),
            ),
            Container(
              child: IconButton(
                onPressed: () {
                  chat.sendMessage(
                      content: messagingFieldController.text,
                      contentType: 'text',
                      userID: user.uid);
                  messagingFieldController.clear();
                  chat.currentMessageText = messagingFieldController.text;
                  chat.updateUsersTyping(user.uid);
                },
                icon: Icon(Icons.arrow_upward),
              ),
            ),
          ],
        ),
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

class JumpingDot extends AnimatedWidget {
  JumpingDot({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      height: animation.value,
      child: Text('.'),
    );
  }
}

class MessageList extends StatelessWidget {
  final Chat chat;
  final bool usersLoaded;
  final List<User> users;
  const MessageList(this.chat, this.usersLoaded, this.users, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chat.messages != null
        ? Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              reverse: true,
              itemCount: chat.messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return usersLoaded
                      ? UserTypingWidget(chat.usersTyping, users)
                      : Container();
                }
                return ListTile(
                  title: MessageWidget(message: chat.messages[index - 1]),
                );
              },
            ),
          )
        : Text('Messages Loading');
  }
}

class MessageWidget extends StatelessWidget {
  final Message message;
  const MessageWidget({this.message, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    bool sentByMe = user.uid == message.userID;
    Widget contentWidget = Text("");
    switch (message.contentType) {
      case "text":
        contentWidget = Container(
          width: MediaQuery.of(context).size.width * 0.5,
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          decoration: BoxDecoration(
            color: sentByMe ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(
            message.content,
          ),
        );
        break;
      default:
    }
    double cWidth = MediaQuery.of(context).size.width * 0.9;

    return Container(
      // padding: EdgeInsets.all(16.0),
      width: cWidth,
      child: sentByMe
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                contentWidget,
                user.photoURL != null
                    ? Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(user.photoURL),
                          ),
                        ),
                      )
                    : Container(),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [contentWidget],
            ),
    );
  }
}

class JumpingDotsProgressIndicator extends StatefulWidget {
  final int numberOfDots;
  final double beginTweenValue = 0.0;
  final double endTweenValue = 8.0;

  JumpingDotsProgressIndicator({
    this.numberOfDots = 3,
  });

  _JumpingDotsProgressIndicatorState createState() =>
      _JumpingDotsProgressIndicatorState(
        numberOfDots: this.numberOfDots,
      );
}

class _JumpingDotsProgressIndicatorState
    extends State<JumpingDotsProgressIndicator> with TickerProviderStateMixin {
  int numberOfDots;
  List<AnimationController> controllers = new List<AnimationController>();
  List<Animation<double>> animations = new List<Animation<double>>();
  List<Widget> _widgets = new List<Widget>();

  _JumpingDotsProgressIndicatorState({
    this.numberOfDots,
  });
  Widget build(BuildContext context) {
    return Container();
  }
}
