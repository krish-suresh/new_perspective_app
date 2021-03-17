


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottomBar.dart';

class HomePageBackground extends StatelessWidget{

  final Widget child;
  final int index;
  const HomePageBackground({Key key,  this.child, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                width: MediaQuery.of(context).size.height,
                child: child,
              ),
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
              child: BottomBar(index: index,),
            )
          ],
        ),
      )
     
    );
  }

}