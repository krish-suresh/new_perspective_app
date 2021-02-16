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
          fontFamily: 'Georgia',
          textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SignInRegisterPageView(),
      ),
    );
  }
}

class SignInRegisterPageView extends StatelessWidget {
  const SignInRegisterPageView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    return Container(
      child: user == null
          ? PageView(
              children: [SignInPage(), RegisterPage()],
            )
          : HomePage(),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthService _authService = new AuthService();
    return Scaffold(
      body: Container(
        child: Center(
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
  final AuthService _authService = new AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    AuthService _authService = new AuthService();

    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RegisterForm(),
              RaisedButton(
                onPressed: () => _authService.googleSignIn(),
                child: Text('Signup with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatelessWidget {
  RegisterForm({Key key}) : super(key: key);
  final AuthService _authService = new AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
            onPressed: () => _authService.handleSignUp(
                email: emailController.text, password: passwordController.text),
            child: Text('Register'),
          )
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    AuthService _authService = new AuthService();

    return Container(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.toString(),
            style: Theme.of(context).textTheme.headline1,
          ),
          RaisedButton(
            onPressed: () => _authService.signOut(),
            child: Text('Sign Out'),
          )
        ],
      ),
    ));
  }
}
