import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/chatsWidgets/chat.dart';
import 'package:new_perspective_app/services/auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthLib;
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: UserLeaderboard(),
                      ),
                    );
                  },
                  icon: Icon(Icons.leaderboard_outlined),
                ),
                Spacer(
                  flex: 1,
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
              child: Center(child: ChatHistoryList()),
              flex: 25,
            ),
            Spacer(
              flex: 1,
            ),
            ElevatedButton.icon(
                label: Text("Find a new perspective"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green.shade300,
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
      ),
    );
  }
}

class UserLeaderboard extends StatelessWidget {
  const UserLeaderboard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insight Score Leaderboard"),
      ),
      body: FutureBuilder<List<User>>(
          future: User.getLeaderboard(),
          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
            if (snapshot.hasData) {
              print("Number of users" + snapshot.data.length.toString());
              snapshot.data
                  .sort((a, b) => a.insightScore < b.insightScore ? 1 : -1);
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Widget profilePhoto = snapshot.data[index].photoURL != null
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: ClipOval(
                              child: Image.network(
                                snapshot.data[index].photoURL,
                                width: 25,
                                height: 25,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 25,
                            height: 25,
                          );
                    Color tileColor = Colors.white;
                    switch (index) {
                      case 0:
                        tileColor = Colors.amber;
                        break;
                      case 1:
                        tileColor = Colors.grey.shade500;
                        break;
                      case 2:
                        tileColor = Colors.brown;
                        break;
                      default:
                        break;
                    }
                    return ListTile(
                      tileColor: tileColor,
                      leading: profilePhoto,
                      title: Text(snapshot.data[index].displayName ?? ""),
                      trailing: Text(
                          "Total Insight Score: ${snapshot.data[index].insightScore}"),
                    );
                  });
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Loading leaderboard..."),
                  CircularProgressIndicator()
                ],
              ),
            );
          }),
    );
  }
}
