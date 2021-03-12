import 'package:new_perspective_app/chatsWidgets/chatHistory.dart';
import 'package:new_perspective_app/chatsWidgets/chatWaiting.dart';
import 'package:new_perspective_app/homeWidgets/history.dart';
import 'package:new_perspective_app/homeWidgets/profile.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:new_perspective_app/authenticationWidgets/useremailnotverifiedpage.dart';
import 'package:new_perspective_app/authenticationWidgets/userinfoformpage.dart';
import 'package:new_perspective_app/services/auth.dart';
import 'package:page_transition/page_transition.dart';

import 'leaderboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    print("On Home Page");
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Something went wrong :(")),
      );
    }
    AuthService _authService = new AuthService();
    bool userVerified = user.isVerified ?? false;
    bool userRegistered = user.registered ?? false;
    if (!userRegistered) {
      return UserInfoFormPage();
    }

    if (!userVerified) {
      return UserEmailNotVerifiedPage();
    }

    return Scaffold(
      body: new Stack(
        children:[ 
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: HistoryPage(),
                            ));
                        },
                        child: Container(
                          color: Theme.of(context).primaryColorLight,
                          child: Center(
                            child: Text("History", style: Theme.of(context).textTheme.headline1),
                          )
                        ),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: ProfilePage(),
                            ));
                        },
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          child: Center(
                            child: Text("Profile", style: Theme.of(context).textTheme.headline1),
                          )
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child:GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: UserLeaderboard(),
                              ),
                            );
                          },
                        child: Container(
                          color: Theme.of(context).primaryColorDark,
                          child: Center(
                            child: Text("Leader Board", style: Theme.of(context).textTheme.headline1, textAlign: TextAlign.center,),
                          )
                        ),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          color: Theme.of(context).backgroundColor,
                          child: Column(
                            
                            children: [
                              Spacer(
                                flex: 3
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  ),primary: Theme.of(context).accentColor 
                                ),
                                onPressed: () {  },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                                  child: Column(mainAxisSize: MainAxisSize.min,children: [
                                    Icon(Icons.explore_outlined, size: 50, ) ,
                                    Text("Explore", style: Theme.of(context).textTheme.headline2), 
                                  ],),
                                )
                                
                              ),
                              Spacer(
                                flex: 2
                              ),
                            ]
                          )
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(child: 
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: new RoundedRectangleBorder(
               borderRadius: new BorderRadius.circular(12.0),
               ),primary: Theme.of(context).buttonColor 
              ),
              onPressed: (){
                user.addToSearchForChat();
                return Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ChatWaitingPage(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(50, 31, 50, 31), 
                child: Text("Gain Some Insight", style: Theme.of(context).textTheme.headline2),
              )
            ,)
          ,)
          
        ],
      ) ,
      
      /*Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(
              flex: 4,
            ),
            Row(
              children: [
                Spacer(
                  flex: 1,
                ),
                Text(
                  "Hi ${user.displayName}!",
                  style: Theme.of(context).textTheme.headline1,
                ),
                Spacer(
                  flex: 5,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: UserLeaderboard(),
                      ),
                    );
                  },
                  icon: Icon(Icons.leaderboard_outlined),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: Profile(),
                        ));
                  },
                  child: /*SizedBox(
                    width: 25,
                    height: 25,
                    child: ClipOval(
                      child: Image.network(
                        user.photoURL,
                        width: 25,
                        height: 25,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),*/
                  user.profileImage()
                ),
                IconButton(
                  onPressed: () => _authService.signOut(),
                  icon: Icon(Icons.logout),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            Text("Chat History: "),
            Expanded(
              child: Center(
                  child: Row(children: [
                Spacer(
                  flex: 1,
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 100, maxWidth: 400),
                  child: ChatHistoryList(),
                ),
                Spacer(
                  flex: 1,
                )
              ])),
              flex: 25,
            ),
            Spacer(
              flex: 1,
            ),
            ElevatedButton.icon(
                label: Text("Find a new perspective"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent.shade700,
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  user.addToSearchForChat();
                  return Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: ChatWaitingPage(),
                    ),
                  );
                }),
            // OutlinedButton(
            //   child: SizedBox(
            //     height: 50,
            //     width: 50,
            //     child: Hero(
            //       tag: "eyeIcon",
            //       child: Expanded(
            //         child: FittedBox(
            //           child: Icon(
            //             Icons.remove_red_eye_outlined,
            //             color: Colors.black,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            //   onPressed: () {
            //     user.addToSearchForChat();
            //     return Navigator.push(
            //       context,
            //       PageTransition(
            //         type: PageTransitionType.fade,
            //         child: ChatPage(),
            //       ),
            //     );
            //   },
            // ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),*/
    );
  }
}
