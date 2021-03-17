
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/chatsWidgets/chatHistory.dart';
import 'package:new_perspective_app/services/auth.dart';

import 'homePageBackground.dart';


class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("On History Page");

    return  HomePageBackground(
      index: 2,
      child: ChatHistoryList()
    );
  }
}
