import 'package:flutter/material.dart';
import 'package:new_perspective_app/services/auth.dart';

import '../interfaces.dart';
import 'package:provider/provider.dart';
import 'package:auth_buttons/auth_buttons.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key key}) : super(key: key);

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
              EmailAuthButton(
                text: 'Signup with Email',
                onPressed: null,
              ),
              Spacer(
                flex: 1,
              ),
              GoogleAuthButton(
                onPressed: () => _authService.signUpGoogle(),
                text: 'Signup with Google',
              ),
              Spacer(
                flex: 1,
              ),
              MaterialButton(
                onPressed: () => _authService.signUpAnonymous(),
                child: Text('Press to continue as Guest'),
              ),
              Spacer(
                flex: 7,
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
          MaterialButton(
            onPressed: () => _authService.signUpEmail(
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
