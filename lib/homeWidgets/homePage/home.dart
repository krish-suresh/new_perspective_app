
import 'dart:math';

import 'package:new_perspective_app/homeWidgets/history.dart';
import 'package:new_perspective_app/homeWidgets/homePage/homeHistoryWidget.dart';
import 'package:new_perspective_app/homeWidgets/homePage/homeSummaryWidget.dart';
import 'package:new_perspective_app/homeWidgets/profile.dart';

import 'package:provider/provider.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

import 'package:flutter/material.dart';
import 'package:new_perspective_app/authenticationWidgets/useremailnotverifiedpage.dart';
import 'package:new_perspective_app/authenticationWidgets/userinfoformpage.dart';
import 'package:new_perspective_app/services/auth.dart';
import 'package:page_transition/page_transition.dart';

import '../bottomBar.dart';


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
      body: SafeArea(
        child: new Stack(
          

          children: [
            
            //page COntainer

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    new Color(0xFF79ADAD),
                    new Color(0xFFE4CFE1),
                  ]
                )
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 50, 0, 12),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
                                    child: Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  Text(
                                    "Insight",
                                    style: Theme.of(context).textTheme.headline1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onTap: () {Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: ProfilePage(),
                                        ));},
                              child:user.profileImageCustom(40)
                            ),
                          )
                        ],
                      ),
                      HomeSummaryWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text("History", style: Theme.of(context).textTheme.headline2),
                          ),
                        ],
                      ),
                      HomeHistoryWidget(),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: HistoryPage(),
                            ));
                        },
                        child: Text(
                          "view history",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text("Quotes", style: Theme.of(context).textTheme.headline2),
                          ),
                        ],
                      ),
                      
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              offset: new Offset(0, 4),
                              blurRadius: 2,
                              color: Color.fromARGB(64, 0, 0, 0),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.format_quote_rounded, color: Colors.white, size: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text("Life is about eating pineapple", style: Theme.of(context).textTheme.bodyText1),
                              ),
                              Transform.rotate(
                                angle: pi,
                                child: Icon(Icons.format_quote_rounded, color: Colors.white, size: 20)
                              ),
                            ],
                          ),
                        )
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          
                        },
                        child: Text(
                          "view quotes",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),

                      SizedBox(height: 100,)
                    ],
                  ),
                ),
              )
            ),

            //Visual Fadout
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        new Color(0x00E4CFE1),
                        new Color(0xFFE4CFE1),
                        new Color(0xFFE4CFE1),
                        new Color(0xFFE4CFE1),
                        new Color(0xFFE4CFE1),
                      ]
                    )
                  ),
                  child: Column(
                    children: [
                      Row(children: [],)
                    ],
                  ),
                ),
              ),
            ),

            //Bottom Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomBar(index: 0,),
            )
          ],
        ),
      )
      
       /*new Stack(
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
      ) ,*/
      
     
    );
  }
}
