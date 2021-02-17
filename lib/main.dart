import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newPerspectiveApp/services/auth.dart';
import 'package:newPerspectiveApp/services/db.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'interfaces.dart';

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
          value: FirebaseAuth.instance.authStateChanges(),
        ),
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
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');
    DBService _db = DBService();
    return Container(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<Chat>(
            future: _db.getChat('YeuRc4NmQ8NPY9QsJ95T'),
            builder: (BuildContext context, AsyncSnapshot<Chat> snapshot) {
              print("SNAPSHOT: " + snapshot.toString());
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Chat chat = snapshot.data;
                return Text(
                  chat.toString(),
                  style: Theme.of(context).textTheme.headline1,
                );
              }

              return Text("loading",
                  style: Theme.of(context).textTheme.headline1);
            },
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

class ChatWidget extends StatelessWidget {
  final Chat chat;
  const ChatWidget({this.chat, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [StreamProvider.value(value: chat.getMessageStream())],
      child: Container(
        child: MessageList(),
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  const MessageList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Message> messages = context.watch<List<Message>>();
    return messages != null
        ? Container(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: MessageWidget(message: messages[index]),
                );
              },
            ),
          )
        : Text('Messages Loading');
  }
}

class MessageWidget extends StatelessWidget {
  final Message message;
  const MessageWidget({this.message, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget contentWidget = Text("");
    switch (message.contentType) {
      case "text":
        contentWidget = Text(message.content);
        break;
      default:
    }
    return Container(
      child: contentWidget,
    );
  }
}
