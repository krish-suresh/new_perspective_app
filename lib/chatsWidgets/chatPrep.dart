




import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:new_perspective_app/interfaces/chatInterface.dart';
import 'package:provider/provider.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

import '../enums.dart';

class ChatPrep extends StatelessWidget{
  
  final List<User> users;
  final Chat chat;
  const ChatPrep({Key key, this.users, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    User toUser = users.firstWhere((a) => a.uid != user.uid);

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
            toUser.profileImageLarge(),
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
  }

}