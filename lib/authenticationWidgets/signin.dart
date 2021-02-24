import 'package:flutter/material.dart';
import 'package:new_perspective_app/authenticationWidgets/registeration.dart';
import 'package:new_perspective_app/interfaces.dart';
import 'package:new_perspective_app/services/auth.dart';

import '../main.dart';
import 'package:provider/provider.dart';
import 'package:auth_buttons/auth_buttons.dart';

class SignInRegisterPageView extends StatelessWidget {
  const SignInRegisterPageView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    return Container(
      height: 100,
      child: user == null
          ? Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Center(
                        child: Text(
                      "New Perspective",
                      style: Theme.of(context).textTheme.headline6,
                    )),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 8,
                    child: ScrollConfiguration(
                      behavior: SigninSignUpScrollBehavior(),
                      child: PageView(
                        children: [SignInPage(), RegisterPage()],
                      ),
                    ),
                  ),
                ],
              ),
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
              Spacer(
                flex: 7,
              ),
              EmailAuthButton(),
              Spacer(
                flex: 1,
              ),
              GoogleAuthButton(
                onPressed: () => _authService.googleSignIn(),
              ),
              Spacer(
                flex: 1,
              ),
              AbsorbPointer(
                child: MaterialButton(
                  child: Text("Swipe to register >"),
                  onPressed: () {},
                ),
              ),
              Spacer(
                flex: 7,
              )
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
          MaterialButton(
            onPressed: () => _authService.signIn(
                email: emailController.text, password: passwordController.text),
            child: Text('Sign in'),
          )
        ],
      ),
    );
  }
}

class SigninSignUpScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
