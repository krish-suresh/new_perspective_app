
import 'package:new_perspective_app/authenticationWidgets/demographicQuestion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/services/auth.dart';


class Profile extends StatelessWidget {
  final AuthService _authService = new AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("On Profile Page");


    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: DemographicWidget()
      );
  }
}
