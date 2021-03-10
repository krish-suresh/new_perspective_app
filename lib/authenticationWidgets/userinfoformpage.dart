import 'package:flutter/material.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:provider/provider.dart';

import 'demographicQuestion.dart';

class UserInfoFormPage extends StatelessWidget {
  const UserInfoFormPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DemographicWidget(),
    );
  }

  Map<String, dynamic> collectDemographicData() {}
}
