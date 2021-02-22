import 'package:flutter/material.dart';
import 'package:new_perspective_app/services/auth.dart';

import '../interfaces.dart';
import 'package:provider/provider.dart';

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
                onPressed: () => _authService.signUpGoogle(),
                child: Text('Signup with Google'),
              ),
              RaisedButton(
                onPressed: () => _authService.signUpAnonymous(),
                child: Text('Continue as Guest'),
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
  final TextEditingController nameController = TextEditingController();
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
              controller: nameController,
            ),
          ),
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
                email: emailController.text,
                password: passwordController.text,
                name: nameController.text),
            child: Text('Register'),
          )
        ],
      ),
    );
  }
}
