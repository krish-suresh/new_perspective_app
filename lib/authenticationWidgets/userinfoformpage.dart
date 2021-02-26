import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../interfaces.dart';

class UserInfoFormPage extends StatelessWidget {
  const UserInfoFormPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();

    TextEditingController demNumberController = TextEditingController();

    Widget profilePhoto = user.photoURL != null
        ? ClipOval(
            child: Image.network(
              user.photoURL,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          )
        : Container();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            profilePhoto,
            Spacer(),
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
              child: Text("Submit"),
              onPressed: () => user.registerUser(demNumberController.text),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
