import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_perspective_app/homeWidgets/homePage/homeSummaryWidget.dart';
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
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (context, index) {
                    if(index >= snapshot.data.length){
                      print("working");
                      return SizedBox(height: 100,);
                    }

                    
                    print(snapshot.data[index].chatData);
                    print(snapshot.data[index].chatID);

                    double insightScore = 0;
                    bool hasScore = snapshot.data[index].chatData['userScores'] != null && snapshot.data[index].chatData['userScores'][user.uid] != null;
                    if(hasScore){
                      insightScore = snapshot.data[index].chatData['userScores'][user.uid];
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(21, 22, 22, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: ListTile(
                          trailing: hasScore ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      insightScore.toString(),
                                      style: TextStyle(color: HomeSummaryWidget.ratingColor(insightScore), fontSize: 15, fontWeight: FontWeight.w400)
                                    ),
                                    SizedBox(
                                      width: 34,
                                      height: 34,
                                      child: CircularProgressIndicator(
                                        valueColor: new AlwaysStoppedAnimation<Color>(HomeSummaryWidget.ratingColor(insightScore)),
                                        value: insightScore / 10,
                                      ),
                                    ),
                                  ],
                                )
                              : Text("N/A", style: Theme.of(context).textTheme.bodyText1),
                          title: Text(DateFormat('E, MMM d yyyy').add_jm().format(
                              snapshot.data[index].chatData['completedAt']
                                  .toDate()), style: Theme.of(context).textTheme.bodyText1),
                        ),
                      ),
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
