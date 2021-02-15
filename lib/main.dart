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
            backgroundColor: Colors.white,
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

    return Scaffold(
      body: Container(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.displayName),
                  RaisedButton(
                    onPressed: () => _authService.signOut(),
                    child: Text('Sign Out'),
                  )
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SignInForm(),
                    RaisedButton(
                      onPressed: () => _authService.googleSignIn(),
                      child: Text('Signin with Google'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class SignInForm extends StatelessWidget {
  SignInForm({Key key}) : super(key: key);
  AuthService _authService = new AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              controller: emailController,
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              controller: passwordController,
            ),
          ),
          RaisedButton(
            onPressed: () => _authService.signIn(
                email: emailController.text, password: passwordController.text),
            child: Text('Sign in'),
          )
        ],
      ),
    );
  }
}
