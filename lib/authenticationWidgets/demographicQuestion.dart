


import 'package:new_perspective_app/authenticationWidgets/signin.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/interfaces/demographicQuestionInterface.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';
import 'package:new_perspective_app/services/auth.dart';

import 'package:intersperse/intersperse.dart';

class DemographicWidget extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
     User user = context.watch<User>();
    TextEditingController displayNameController = TextEditingController();
    displayNameController.text = user.displayName;
    bool showError = false;
    AuthService _authService = new AuthService();

    return Center(
            child: SingleChildScrollView(
              child: FutureBuilder<List<DemographicQuestion>>(
                  future: DemographicQuestion.getAllQuestions(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<DemographicQuestion>> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error occured loading questions :(");
                    } else if (snapshot.hasData) {
                      //Fill in widget info
                      if(user.userDemographicData.isNotEmpty){
                        for(DemographicQuestion question in snapshot.data){
                          user.userDemographicData[question.id].forEach((k, v) {
                            if(k == "answer"){
                              question.selectedValue = v;
                            }
                          });
                        }
                      }
                      /*user.userDemographicData = {
                                  for (DemographicQuestion question
                                      in snapshot.data)
                                    question.id: question.getValue()
                                };*/
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Spacer(
                              //   flex: 15,
                              // ),
                              // Text(
                              //   "Demographic form to better match you to a new perspective",
                              //   style: TextStyle(
                              //       fontSize: 15, fontWeight: FontWeight.w400),
                              // ),
                              // Spacer(
                              //   flex: 2,
                              // ),
                              user.profileImageLarge(),
                              // Spacer(
                              //   flex: 5,
                              // ),
                              Text(
                                user.displayName,
                                style: Theme.of(context).textTheme.headline3,
                              ),

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
                              Row(
                                children:[
                                  Spacer(
                                    flex: 8
                                  ),
                                  ElevatedButton(
                                    child: Text("Save"),
                                    onPressed: () {
                                      //   user.photoURL = photoURLCheckbox
                                      //       ? "https://www.tenforums.com/geek/gars/images/2/types/thumb_15951118880user.png"
                                      //       : user.photoURL; // TODO make this dynamic

                                      if (snapshot.data.every((element) =>
                                              element.selectedValue != null) &&
                                          displayNameController.text != "") {
                                        user.displayName =
                                            displayNameController.text;
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
                                    flex: 1,
                                  ),

                                  ElevatedButton(
                                    onPressed: (){
                                      if(!Navigator.canPop(context)){
                                        (new AuthService()).signOut();
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.fade,
                                          child: SignInRegisterPageView(),
                                        ),
                                      );
                                      }else{
                                        Navigator.pop(context);
                                      }
                                      
                                      
                                      
                                      
                                    }, 
                                    child: Text("Cancel")
                                  ),
                                  Spacer(
                                    flex: 8,
                                  ),
                                ]
                              )
                              
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
          );
  }

}