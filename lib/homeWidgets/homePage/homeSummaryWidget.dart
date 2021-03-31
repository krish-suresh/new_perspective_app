
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';
class HomeSummaryWidget extends StatelessWidget{

  double randomRating(){
    return (Random(1).nextDouble() * 100).toInt() / 10;
  }

  static Color ratingColor(double rating){
    return rating > 7 ? Colors.green: (rating > 4 ? Colors.amber: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    double averageRating = randomRating();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
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
          child: Padding(
            padding: const EdgeInsets.all(11.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Summary", style: Theme.of(context).textTheme.headline3),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: new Stack(
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(ratingColor(averageRating)),
                              value: averageRating / 10,
                              strokeWidth: 16,
                            )
                          ),


                            SizedBox(
                            width: 140,
                            height: 140,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("$averageRating", style: TextStyle(color: ratingColor(averageRating), fontSize: 64, fontWeight: FontWeight.w100, fontStyle: FontStyle.normal), textAlign: TextAlign.center),
                                  Text("Insight Score", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w100, fontStyle: FontStyle.normal), textAlign: TextAlign.center),
                                ],
                              )
                            )
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: new Stack(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                                    child: Text("15", style: Theme.of(context).textTheme.headline4),
                                  ),
                                  IconShadowWidget(Icon(Icons.message_rounded, color: Colors.white, size: 20), shadowColor: Color.fromARGB(100, 0, 0, 0),)
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
                                child: Text("chats", style: Theme.of(context).textTheme.headline5),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: new Stack(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                                    child: Text("25", style: Theme.of(context).textTheme.headline4),
                                  ),
                                  IconShadowWidget(Icon(Icons.format_quote_rounded, color: Colors.white, size: 20), shadowColor: Color.fromARGB(100, 0, 0, 0),)
                                  
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
                                child: Text("quotes", style: Theme.of(context).textTheme.headline5),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: new Stack(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                                    child: Text("2nd", style: Theme.of(context).textTheme.headline4),
                                  ),
                                  IconShadowWidget(Icon(Icons.star, color: Colors.white, size: 15), shadowColor: Color.fromARGB(100, 0, 0, 0),)
                                  
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
                                child: Text("rank", style: Theme.of(context).textTheme.headline5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                
              ],
            ),
          ),
        )
      ],
    );
  }
}