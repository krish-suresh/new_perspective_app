import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../interfaces.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // constructor
  DBService() {}
}
