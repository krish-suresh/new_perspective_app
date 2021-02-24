import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/chatsWidgets/chat.dart';
import 'package:new_perspective_app/services/auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'authenticationWidgets/signin.dart';
import 'authenticationWidgets/useremailnotverifiedpage.dart';
import 'authenticationWidgets/userinfoformpage.dart';
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
    print("On Home Page");
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
      body: Container(
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
                  onPressed: () => _authService.signOut(),
                  icon: Icon(Icons.logout),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            Expanded(
              child: Center(child: Text("CHAT HISTORY COMING SOON")),
              flex: 25,
            ),
            Text("Find a new perspective"),
            Spacer(
              flex: 1,
            ),
            OutlinedButton(
              child: SizedBox(
                width: 50,
                child: Hero(
                  tag: "eyeIcon",
                  child: Expanded(
                    child: FittedBox(
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              onPressed: () {
                user.addToSearchForChat();
                return Navigator.push(
                  context,
                  CustomPageRoute(
                    type: PageTransitionType.fade,
                    child: ChatPage(),
                  ),
                );
              },
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPageRoute extends PageTransition {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  CustomPageRoute({child, type}) : super(child: child, type: type);
}
