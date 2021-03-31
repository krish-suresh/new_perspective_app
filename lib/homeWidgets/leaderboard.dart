
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/generalWidgets/loadingWidget.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

import 'homePageBackground.dart';

class UserLeaderboard extends StatelessWidget {
  const UserLeaderboard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return  HomePageBackground(
      index: 1,
      child: FutureBuilder<List<User>>(
        future: User.getLeaderboard(),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.hasData) {
            print("Number of users" + snapshot.data.length.toString());
            snapshot.data
                .sort((a, b) => a.insightScore < b.insightScore ? 1 : -1);
            double screenWidth = MediaQuery.of(context).size.width;
            double star1width = 0.39 * screenWidth;
            double star2width = 0.32 * screenWidth;
            double star3width = 0.26 * screenWidth;
            double starHeightScale = 3 / 2;
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                  ),
                  child: new Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ClipPath(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Container(
                                height: star2width * starHeightScale,
                                width: star2width,
                                color: Theme.of(context).primaryColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    snapshot.data[1].profileImage(),
                                    Text(
                                      snapshot.data[1].displayName,
                                      style: Theme.of(context).textTheme.headline5,
                                    ),
                                  ],
                                )
                              ),
                            ),
                            clipper: _MyStarShape(),
                          ),
                          ClipPath(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Container(
                                height: star1width * starHeightScale,
                                width: star1width,
                                color: Theme.of(context).primaryColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    snapshot.data[0].profileImage(),
                                    Text(
                                      snapshot.data[0].displayName,
                                      style: Theme.of(context).textTheme.headline5,
                                    ),
                                  ],
                                )
                              ),
                            ),
                            clipper: _MyStarShape(),
                          ),
                          ClipPath(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Container(
                                height: star3width * starHeightScale,
                                width: star3width,
                                color: Theme.of(context).primaryColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    snapshot.data[2].profileImage(),
                                    Text(
                                      snapshot.data[2].displayName,
                                      style: Theme.of(context).textTheme.headline5,
                                    ),
                                  ],
                                )
                              ),
                            ),
                            clipper: _MyStarShape(),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: star2width * starHeightScale,
                            width: star2width,
                            
                            child: Column(
                              children: [
                                Spacer(
                                  flex:5
                                ),
                                Text(
                                  "${snapshot.data[1].insightScore}" ,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                Spacer(
                                  flex:1
                                ),
                              ],
                            )
                          ),

                          
                          Container(
                            height: star1width * starHeightScale,
                            width: star1width,
                            
                            child: Column(
                              children: [
                                Spacer(
                                  flex:4
                                ),
                                Text(
                                  "${snapshot.data[0].insightScore}" ,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                Spacer(
                                  flex:1
                                ),
                              ],
                            )
                          ),
                          Container(
                            height: star3width * starHeightScale,
                            width: star3width,
                            
                            child: Column(
                              children: [
                                Spacer(
                                  flex:9
                                ),
                                Text(
                                  "${snapshot.data[2].insightScore}" ,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                Spacer(
                                  flex:1
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length - 3,
                      itemBuilder: (context, index) {

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(40, 11, 40, 0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            tileColor: Theme.of(context).primaryColor,
                            leading: snapshot.data[index + 3].profileImage(),
                            title: Text(snapshot.data[index + 3].displayName ?? ""),
                            trailing: Text(
                                "Total Insight Score: ${snapshot.data[index + 3].insightScore}"),
                          ),
                        );
                      }),
                ),
              ],
            );
          }
          return LoadingWidget(pageName: "Leaderboard",);
        }),
      );
  }
}

class _MyStarShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.lineTo(0.0, size.height * 0.4);
    path.lineTo(size.width * 0.25, size.height * 0.55);
    path.lineTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.5, size.height * 0.65);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    path.lineTo(size.width * 0.75, size.height * 0.55);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width * 0.65, size.height * 0.4);
    path.lineTo(size.width * 0.5, size.height * 0.15);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
    
}
