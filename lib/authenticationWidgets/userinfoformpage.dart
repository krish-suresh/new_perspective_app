import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../interfaces.dart';

class UserInfoFormPage extends StatelessWidget {
  const UserInfoFormPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();

    TextEditingController demNumberController = TextEditingController();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: TextField(
                controller: demNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Demographic Number',
                ),
              ),
            ),
            OutlinedButton(
              child: Text("Press this button to register"),
              onPressed: () => user.registerUser(demNumberController.text),
            ),
          ],
        ),
      ),
    );
  }
}
