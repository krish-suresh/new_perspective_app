import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/chatsWidgets/chat.dart';
import 'package:new_perspective_app/services/auth.dart';
import 'package:new_perspective_app/services/db.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'authenticationWidgets/signin.dart';
import 'interfaces.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData appTheme = ThemeData(
    primarySwatch: Colors.blue,
    backgroundColor: Colors.white,
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 25, color: Colors.black),
      headline6: TextStyle(
          fontSize: 40, color: Colors.black, fontWeight: FontWeight.w200),
      bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  @override
  Widget build(BuildContext context) {
    AuthService authService = new AuthService();
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: authService.authStateChanges(),
        ),
      ],
      child: MaterialApp(
        title: 'New Perspective App',
        theme: appTheme,
        home: SignInRegisterPageView(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    User toUser;
    AuthService _authService = new AuthService();
    Chat chat;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi ${user.displayName}!",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  IconButton(
                    onPressed: () => _authService.signOut(),
                    icon: Icon(Icons.logout),
                  )
                ],
              ),
              Text("Connect Chat"),
              IconButton(
                  icon: Icon(Icons.remove_red_eye_outlined),
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatPage('YeuRc4NmQ8NPY9QsJ95T')),
                      )),
            ],
          )),
    );
  }
}
