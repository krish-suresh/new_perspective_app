import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../enums.dart';

class DemographicQuestion {
  final String id;
  final String title;
  final DemographicQuestionType type;
  final bool disabled;
  final Map<String, dynamic> questionData;
  String selectedValue;

  DemographicQuestion(
      {this.id, this.title, this.type, this.disabled, this.questionData});

  factory DemographicQuestion.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> snapshotData = snapshot.data();
    return DemographicQuestion(
        id: snapshot.id,
        title: snapshotData['title'],
        type: EnumToString.fromString(
            DemographicQuestionType.values, snapshotData['type']),
        disabled: snapshotData['disabled'],
        questionData: snapshotData);
  }

  Map<String, dynamic> getValue() {
    return {
      'title': title,
      'answer': selectedValue,
    };
  }



  Widget getWidget() {
    Widget content;
    switch (type) {
      case DemographicQuestionType.dropdown:
        List<String> dropdownfields =
            List<String>.from(questionData['dropdownfields']);
        dropdownfields.add("Prefer Not to Answer");
        content = StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: title,
            ),
            value: selectedValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            onChanged: (String newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
            items: dropdownfields.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        });
        break;
      case DemographicQuestionType.textfield:
        content = TextField(
          controller: new TextEditingController(text: selectedValue),
          decoration: InputDecoration(labelText: title),
          onChanged: (value) => selectedValue = value,
        );
        break;
      case DemographicQuestionType.multiselect:
        return Container();
        break;
    }
    return content;
  }

  static Future<List<DemographicQuestion>> getAllQuestions() {
    return FirebaseFirestore.instance
        .collection("userDemographicQuestions")
        .where('disabled', isEqualTo: false)
        .get()
        .then((value) => value.docs
            .map((e) => DemographicQuestion.fromSnapshot(e))
            .toList());
  }
}
