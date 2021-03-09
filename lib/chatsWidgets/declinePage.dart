
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeclinedPage extends StatelessWidget {
  final String userName;
  const DeclinedPage({Key key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("$userName has declined your chat."),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Return to Home Screen"))
        ],
      ),
    ));
  }
}
