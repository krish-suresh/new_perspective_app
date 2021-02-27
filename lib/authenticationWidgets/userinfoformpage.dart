import 'package:flutter/material.dart';
import 'package:new_perspective_app/enums.dart';
import 'package:provider/provider.dart';
import 'package:intersperse/intersperse.dart';
import '../interfaces.dart';

class UserInfoFormPage extends StatelessWidget {
  const UserInfoFormPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    print("On Reg Page");
    TextEditingController demNumberController = TextEditingController();
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
        child: FutureBuilder<List<DemographicQuestion>>(
            future: DemographicQuestion.getAllQuestions(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DemographicQuestion>> snapshot) {
              if (snapshot.hasError) {
                return Text("Error occured loading questions :(");
              } else if (snapshot.hasData) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(
                        flex: 15,
                      ),
                      Text(
                        "Demographic form to better match you to a new perspective",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      profilePhoto,
                      Spacer(
                        flex: 5,
                      ),
                      Visibility(
                        child: Text(
                          "Please fill out all the fields",
                          style: TextStyle(color: Colors.red),
                        ),
                        visible: showError,
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      ...snapshot.data
                          .map((e) => e.getWidget())
                          .intersperseOuter(Spacer(
                            flex: 1,
                          )),
                      ElevatedButton(
                        child: Text("Submit"),
                        onPressed: () {
                          //   user.displayName = displayNameController.text;
                          //   user.photoURL = photoURLCheckbox
                          //       ? "https://www.tenforums.com/geek/gars/images/2/types/thumb_15951118880user.png"
                          //       : user.photoURL; // TODO make this dynamic

                          if (snapshot.data.every(
                              (element) => element.selectedValue != null)) {
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
                      Spacer(
                        flex: 10,
                      ),
                    ],
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
    );
  }

  Map<String, dynamic> collectDemographicData() {}
}
