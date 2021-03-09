import 'package:flutter/material.dart';
import 'package:new_perspective_app/enums.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:provider/provider.dart';
import 'package:intersperse/intersperse.dart';

class UserInfoFormPage extends StatelessWidget {
  const UserInfoFormPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    print("On Reg Page");
    TextEditingController displayNameController = TextEditingController();
    displayNameController.text = user.displayName;
    bool showError = false;

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
        child: SingleChildScrollView(
          child: FutureBuilder<List<DemographicQuestion>>(
              future: DemographicQuestion.getAllQuestions(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DemographicQuestion>> snapshot) {
                if (snapshot.hasError) {
                  return Text("Error occured loading questions :(");
                } else if (snapshot.hasData) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Spacer(
                          //   flex: 15,
                          // ),
                          Text(
                            "Demographic form to better match you to a new perspective",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          // Spacer(
                          //   flex: 2,
                          // ),
                          profilePhoto,
                          // Spacer(
                          //   flex: 5,
                          // ),
                          Visibility(
                            child: Text(
                              "Please fill out all the fields",
                              style: TextStyle(color: Colors.red),
                            ),
                            visible: showError,
                          ),
                          // Spacer(
                          //   flex: 1,
                          // ),
                          // Flexible(
                          //   flex: 25,
                          //   child: ListView(
                          //     children: [
                          TextField(
                            controller: displayNameController,
                            decoration:
                                InputDecoration(labelText: "Display Name"),
                          ),
                          ...snapshot.data
                              .map((e) => e.getWidget())
                              .intersperseOuter(SizedBox(
                                height: 15,
                              )),
                          //     ],
                          //   ),
                          // ),
                          ElevatedButton(
                            child: Text("Submit"),
                            onPressed: () {
                              //   user.photoURL = photoURLCheckbox
                              //       ? "https://www.tenforums.com/geek/gars/images/2/types/thumb_15951118880user.png"
                              //       : user.photoURL; // TODO make this dynamic

                              if (snapshot.data.every((element) =>
                                      element.selectedValue != null) &&
                                  displayNameController.text != "") {
                                user.displayName = displayNameController.text;
                                user.userDemographicData = {
                                  for (DemographicQuestion question
                                      in snapshot.data)
                                    question.id: question.getValue()
                                };
                                user.registered = true;
                                user.updateUser();
                              } else {
                                print("Show Error");
                                setState(() {
                                  showError = true;
                                });
                              }
                            },
                          ),
                          // Spacer(
                          //   flex: 10,
                          // ),
                        ],
                      ),
                    );
                  });
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Loading questions..."),
                    CircularProgressIndicator(),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Map<String, dynamic> collectDemographicData() {}
}
