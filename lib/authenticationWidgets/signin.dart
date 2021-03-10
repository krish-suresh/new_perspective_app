import 'package:flutter/material.dart';
import 'package:new_perspective_app/authenticationWidgets/registeration.dart';
import 'package:new_perspective_app/homeWidgets/home.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:new_perspective_app/services/auth.dart';

import 'package:provider/provider.dart';
import 'package:auth_buttons/auth_buttons.dart';

class SignInRegisterPageView extends StatelessWidget {

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
    bool showNotRegError = false;
    AuthService _authService = new AuthService();
    return Scaffold(
      body: Container(
        child: Center(
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(
                  flex: 7,
                ),
                Visibility(
                    visible: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Please register before signing in.",
                        style: TextStyle(color: Colors.red),
                      ),
                    )),
                EmailAuthButton(
                  onPressed: null,
                ),
                Spacer(
                  flex: 1,
                ),
                GoogleAuthButton(
                  onPressed: () async {
                    bool temp = await _authService.googleSignIn() == null;
                    if (temp) _authService.signOut();

                    // setState(() {
                    //   showNotRegError = temp;
                    // });
                  },
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
            );
          }),
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
