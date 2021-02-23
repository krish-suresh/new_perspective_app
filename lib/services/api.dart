import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../interfaces.dart';

class CloudAPI {
  FirebaseFunctions functions = FirebaseFunctions.instance;

  // constructor
  CloudAPI() {}

  Future<String> searchForChat(String uid) async {
    HttpsCallableResult callableResult =
        await functions.httpsCallable('searchForChat').call();
    return callableResult.data;
  }
}
