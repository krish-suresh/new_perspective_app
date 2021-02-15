import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newPerspectiveApp/auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
            value: FirebaseAuth.instance.authStateChanges()),
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    AuthService _authService = new AuthService();

    return Container(
      child: user != null
          ? Column(
              children: [
                Text(user.displayName),
                RaisedButton(
                  onPressed: () => _authService.signOut(),
                  child: Text('Sign Out'),
                )
              ],
            )
          : Center(
              child: RaisedButton(
                onPressed: () => _authService.googleSignIn(),
                child: Text('Signin with Google'),
              ),
            ),
    );
  }
}
