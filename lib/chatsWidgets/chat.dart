import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newPerspectiveApp/interfaces.dart';
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
  String chatid;
  ChatWidget(this.chatid, {Key key}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Chat chat;
  @override
  Widget build(BuildContext context) {
    // Chat chat = context.watch<Chat>();
    TextEditingController messagingFieldController = TextEditingController();
    User user = context.watch<User>();
    double cWidth = MediaQuery.of(context).size.width * 0.95;
    return Container(
      child: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
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
              return MessageList(messages: chat.messages);
            },
          ),
          // chat != null
          //     ? UserTypingWidget(displayName: user.displayName)
          //     : Container(),
          Container(
            width: cWidth,
            child: TextField(
              onChanged: (value) {
                chat.updateUsersTyping(user.uid);
              },
              controller: messagingFieldController,
              decoration: InputDecoration(
                hintText: "Enter a message",
                suffixIcon: IconButton(
                  onPressed: () => chat.sendMessage(
                      content: messagingFieldController.text,
                      contentType: 'text',
                      userID: user.uid),
                  icon: Icon(Icons.arrow_upward),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserTypingWidget extends StatelessWidget {
  final String displayName;
  const UserTypingWidget({Key key, this.displayName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text("$displayName is typing"),
          // JumpingDotsProgressIndicator(
          //   numberOfDots: 6,
          // ),
        ],
      ),
    );
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

class MessageList extends StatelessWidget {
  final List<Message> messages;
  const MessageList({Key key, this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return messages != null
        ? Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: MessageWidget(message: messages[index]),
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
