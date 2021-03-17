



import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget{
  
  final String pageName;
  const LoadingWidget({Key key,  this.pageName}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Loading $pageName..."),
          SizedBox(height: 10),
          CircularProgressIndicator()
        ],
      ),
    );
}

}