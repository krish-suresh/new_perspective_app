import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:page_transition/page_transition.dart';

import 'chat.dart';

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
