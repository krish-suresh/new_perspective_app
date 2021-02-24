import 'package:flutter/material.dart';
import 'package:new_perspective_app/chatsWidgets/chat.dart';
import 'package:new_perspective_app/interfaces.dart';
import 'package:new_perspective_app/services/api.dart';
import 'package:provider/provider.dart';

class ChatSearchPage extends StatelessWidget {
  const ChatSearchPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CloudAPI api = CloudAPI();
    User user = context.watch<User>();
    return Scaffold(
      body: FutureBuilder(
          future: api.searchForChat(user.uid),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text("Something went wrong :("));
            } else if (snapshot.hasData) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(snapshot.data),
                ),
              );
              Future.delayed(Duration.zero, () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ChatPage(snapshot.data)));
              });
            }
            return Center(
                child: Column(
              children: [
                CircularProgressIndicator(),
                Text("Searching for chat..."),
              ],
            ));
          }),
    );
  }
}
