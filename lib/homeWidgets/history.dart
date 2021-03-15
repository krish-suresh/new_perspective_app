
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/chatsWidgets/chatHistory.dart';
import 'package:new_perspective_app/services/auth.dart';

import 'bottomBar.dart';


class HistoryPage extends StatelessWidget {
  final AuthService _authService = new AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("On History Page");


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
                child: ChatHistoryList(),
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
              child: BottomBar(index: 2,),
            )
          ],
        ),
      )
      
     
    );
  }
}
