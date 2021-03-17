

import 'package:new_perspective_app/chatsWidgets/chatWaiting.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/homeWidgets/history.dart';
import 'package:new_perspective_app/homeWidgets/homePage/home.dart';
import 'package:page_transition/page_transition.dart';

import 'leaderboard.dart';

class BottomBar extends StatelessWidget{
  final int index;
  const BottomBar({Key key,  this.index}) : super(key: key);
  
  Color itemColor(context, bool onPage){
    return (onPage) ? Theme.of(context).primaryColorLight :Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    
    User user = context.watch<User>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(icon: Icon(Icons.home, color: itemColor(context, index == 0), size: 30), onPressed: () { 
            if(index != 0){
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: HomePage(),
                ),
              );
            }
          },),
          IconButton(icon: Icon(Icons.leaderboard, color: itemColor(context, index == 1), size: 30), onPressed: () { 
            if(index != 1){
            Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: UserLeaderboard(),
                ),
              );
            }
           },),
          ElevatedButton(onPressed: () {
            user.addToSearchForChat();
                return Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ChatWaitingPage(),
                  ),
                );

          }, child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  
                  offset: new Offset(0, 4),
                  blurRadius: 2,
                  color: Color.fromARGB(64, 0, 0, 0),
                )
              ],
            ),
            width: 75,
            height: 75,
            child: Icon(Icons.remove_red_eye, color: Colors.white, size: 50),
          ), style: ElevatedButton.styleFrom(shape: CircleBorder(), primary: Theme.of(context).primaryColor)),
          IconButton(icon: Icon(Icons.history, color: itemColor(context, index == 2), size: 30), onPressed: () { 
            if(index != 2){
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: HistoryPage(),
                  ),
                );
            }
           },),
            IconButton(icon: Icon(Icons.explore_outlined, color: itemColor(context, index == 3), size: 30), onPressed: () {  },),
        ],
      ),
    );
  }

}