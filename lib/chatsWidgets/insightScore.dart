import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/interfaces/chatInterface.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

class InsightScorePage extends StatelessWidget {
  final Chat chat;
  final User scoringUser;
  const InsightScorePage(
    this.chat,
    this.scoringUser, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _currentSliderValue = 5;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Rate ${scoringUser.displayName} on how much insight they shared.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  Text(
                    _currentSliderValue.toString(),
                    style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.black),
                  ),
                  Slider(
                    value: _currentSliderValue.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                      onPressed: () => chat
                          .scoreUser(scoringUser, _currentSliderValue)
                          .then((value) => Navigator.pop(context)),
                      child: Text("Submit"))
                ],
              );
            })
          ],
        ),
      ),
    );
  }
}
