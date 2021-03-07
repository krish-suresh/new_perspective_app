import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthLib;
import 'authenticationWidgets/signin.dart';
import 'interfaces.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData appTheme = ThemeData(
    primarySwatch: Colors.green,
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
    return StreamBuilder<FirebaseAuthLib.User>(
        stream: FirebaseAuthLib.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return MultiProvider(
            providers: [
              StreamProvider.value(
                  value: User.getStream(snapshot.hasData &&
                          snapshot.data != null
                      ? FirebaseAuthLib.FirebaseAuth.instance.currentUser.uid
                      : null))
            ],
            child: MaterialApp(
              title: 'New Perspective App',
              theme: appTheme,
              home: SignInRegisterPageView(),
            ),
          );
        });
  }
}
