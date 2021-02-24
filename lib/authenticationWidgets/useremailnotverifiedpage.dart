import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserEmailNotVerifiedPage extends StatelessWidget {
  final Timestamp emailLastSent;
  const UserEmailNotVerifiedPage({Key key, this.emailLastSent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please verify your email to proceed.",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Icon(
              Icons.email_outlined,
              size: 100,
            ),
            ElevatedButton(
              onPressed: () {
                print("TODO Impl");
              },
              child: Text("Press to resend verification email."),
            ),
            Text(
              "Verification email last sent on: \n${emailLastSent.toString()}",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}
