



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/generalWidgets/loadingWidget.dart';
import 'package:new_perspective_app/homeWidgets/homePageBackground.dart';
import 'package:new_perspective_app/interfaces/quoteInterface.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

class QuoteHomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return HomePageBackground(
      index: 3,
      child: FutureBuilder<List<User>>(
      future: User.getLeaderboard(),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.hasData) {
          print("Number of users" + snapshot.data.length.toString());
          snapshot.data.sort((a, b) {
            ExploreQuote q = a.getLatestQuote();
            ExploreQuote r = b.getLatestQuote();
            if(q == null){
              return 1;
            }else if(r == null){
              return -1;
            }
            return q.time.compareTo(r.time);
          });
          return Column(
            children: [
              Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      ExploreQuote q = snapshot.data[index].getLatestQuote();
                      if(q == null){
                        return Container(height: 0, width: 0,);
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(40, 11, 40, 0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          tileColor: Theme.of(context).primaryColor,
                          leading: snapshot.data[index].profileImage(),
                          title: Text(snapshot.data[index].displayName ?? ""),
                          trailing: Text("\"${q.quote}\""),
                        ),
                      );
                    }),
              ),
            ],
          );
        }
        return LoadingWidget(pageName: "Explore",);
      }),
    );
  }

}