import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthLib;
import 'authenticationWidgets/signin.dart';
import 'interfaces/userInterface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData appTheme = ThemeData(

    //New Colors
    primaryColor: Color(0xFF317A79),
    accentColor: Color(0xFF41276B),
    primaryColorLight: Color(0xFF79ADAD),


  /*  primaryColorDark: Color(0xFF79ADAD),
    primaryColorLight: Color(0xFFC1EDD3),
    primaryColor: Color(0xFF79AD97),
    buttonColor: Color(0xFF41276B),
    backgroundColor: Color(0xFFE4DEF1),
    accentColor: Color(0xFF317A79),*/

    fontFamily: 'Roboto',
    textTheme: TextTheme(
 
      headline1: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w600),
      headline2: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
      headline3: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
      headline4: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600, shadows: [Shadow(offset: new Offset(0, 4), blurRadius: 4, color: Color.fromARGB(100, 0, 0, 0))]),
      headline5: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500, shadows: [Shadow(offset: new Offset(0, 4), blurRadius: 4, color: Color.fromARGB(100, 0, 0, 0))]),

      bodyText1:  TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w100),
      bodyText2: TextStyle(fontSize: 10.0, fontFamily: 'Hind'),
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
