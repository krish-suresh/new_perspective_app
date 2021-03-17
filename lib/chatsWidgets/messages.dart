import 'package:flutter/material.dart';
import 'package:new_perspective_app/interfaces/chatInterface.dart';
import 'package:new_perspective_app/interfaces/messageInterface.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:provider/provider.dart';

import 'chat.dart';

class MessageList extends StatelessWidget {
  final Chat chat;
  final List<User> users;
  const MessageList(this.chat, this.users, {Key key}) : super(key: key);

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
                  return UserTypingWidget(chat.usersTyping, users);
                }
                return ListTile(
                  title: MessageWidget(
                    message: chat.messages[index - 1],
                    previousMessage: index < chat.messages.length
                        ? chat.messages[index]
                        : null,
                    user: users
                        .where((element) =>
                            element.uid == chat.messages[index - 1].userID)
                        .first,
                  ),
                );
              },
            ),
          )
        : Text('Messages Loading');
  }
}

class MessageWidget extends StatelessWidget {
  final Message message;
  final User user;
  final Message previousMessage;
  const MessageWidget({this.message, Key key, this.user, this.previousMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    User myUser = context.watch<User>();
    bool sentByMe = myUser.uid == message.userID;
    Widget contentWidget = Text("");
    switch (message.contentType) {
      case "text":
        contentWidget = Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 11),
            decoration: BoxDecoration(
              color: sentByMe ? new Color(0xFFC4C4C4) : Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(64, 0, 0, 0),
                  spreadRadius: -1,
                  blurRadius: 0,
                  offset: const Offset( 
                        0.0, 
                        5.0, 
                      ), 
                ) 
              ]
            ),
            child: Text(
              message.content,
            ),
          ),
        );
        break;
      default:
    }
    double cWidth = MediaQuery.of(context).size.width * 0.9;
    
    return Container(
      // padding: EdgeInsets.all(16.0),
      width: cWidth,
      child: Column(
        crossAxisAlignment:
            sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          previousMessage == null || previousMessage.userID != message.userID 
          ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: (sentByMe) ? MainAxisAlignment.end : MainAxisAlignment.start ,
                  children: [
                    user.profileImage(),
                    Text(
                        user.displayName,
                        style: TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              )
          : Container(),
          sentByMe
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(
                      flex: 1,
                    ),
                    contentWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    contentWidget,
                    Spacer(
                      flex: 1,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
