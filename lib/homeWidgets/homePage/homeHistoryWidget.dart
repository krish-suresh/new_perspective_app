

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_perspective_app/homeWidgets/homePage/homeSummaryWidget.dart';
import 'package:provider/provider.dart';
import 'package:new_perspective_app/interfaces/chatInterface.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

class HomeHistoryWidget extends StatelessWidget{

  const HomeHistoryWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    return SizedBox(
      height: 100,
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
                  padding: EdgeInsets.only(right: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    double insightScore = 0;
                    bool hasScore = snapshot.data[index].chatData['userScores'] != null && snapshot.data[index].chatData['userScores'][user.uid] != null;
                    if(hasScore){
                      insightScore = snapshot.data[index].chatData['userScores'][user.uid];
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 8),
                      child: SizedBox(
                        width: 93,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                offset: new Offset(0, 4),
                                blurRadius: 2,
                                color: Color.fromARGB(64, 0, 0, 0),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [ 
                              hasScore ? Stack(
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

                               Padding(
                                 padding: const EdgeInsets.only(top: 8),
                                 child: Text(
                                   DateFormat('E, MMM d yyyy').format(snapshot.data[index].chatData['completedAt'].toDate()),
                                   style: Theme.of(context).textTheme.bodyText1,
                                   textAlign: TextAlign.center,
                                  ),
                               ),

                            ],
                          )
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
                height: 10,
              ),
              CircularProgressIndicator()
            ],
          );
        },
      ),
    );
  }

}