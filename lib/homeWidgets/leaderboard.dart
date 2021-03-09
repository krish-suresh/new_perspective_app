import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_perspective_app/interfaces/userInterface.dart';

class UserLeaderboard extends StatelessWidget {
  const UserLeaderboard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insight Score Leaderboard"),
      ),
      body: FutureBuilder<List<User>>(
          future: User.getLeaderboard(),
          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
            if (snapshot.hasData) {
              print("Number of users" + snapshot.data.length.toString());
              snapshot.data
                  .sort((a, b) => a.insightScore < b.insightScore ? 1 : -1);
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Widget profilePhoto = snapshot.data[index].photoURL != null
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: ClipOval(
                              child: Image.network(
                                snapshot.data[index].photoURL,
                                width: 25,
                                height: 25,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 25,
                            height: 25,
                          );
                    Color tileColor = Colors.white;
                    switch (index) {
                      case 0:
                        tileColor = Colors.amber;
                        break;
                      case 1:
                        tileColor = Colors.grey.shade500;
                        break;
                      case 2:
                        tileColor = Colors.brown;
                        break;
                      default:
                        break;
                    }
                    return ListTile(
                      tileColor: tileColor,
                      leading: profilePhoto,
                      title: Text(snapshot.data[index].displayName ?? ""),
                      trailing: Text(
                          "Total Insight Score: ${snapshot.data[index].insightScore}"),
                    );
                  });
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Loading leaderboard..."),
                  CircularProgressIndicator()
                ],
              ),
            );
          }),
    );
  }
}
