import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:new_perspective_app/interfaces/chatInterface.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

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
