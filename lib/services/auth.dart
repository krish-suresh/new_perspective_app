import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_perspective_app/interfaces.dart';

class AuthService {
  // Dependencies
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // constructor
  AuthService() {}

  Future<User> googleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCreds = await _auth.signInWithCredential(credential);
    // updateUserData(userCreds.user);

    return User.getUserFromID(userCreds.user.uid);
  }

  Future<User> signIn({String email, String password}) async {
    // try {
    //   UserCredential userCredential = await FirebaseAuth.instance
    //       .signInWithEmailAndPassword(email: email, password: password);
    //   User user = userCredential.user;
    //   DocumentSnapshot userData =
    //       await _db.collection('users').doc(user.uid).get();
    //   updateUserData(user);

    //   final now = DateTime.now();
    //   if (!user.emailVerified &&
    //       (!userData.data().containsKey('sentVerificationEmailDate') ||
    //           userData
    //               .data()['sentVerificationEmailDate']
    //               .toDate()
    //               .isBefore(DateTime(now.year, now.month, now.day - 3)))) {
    //     _db.collection('users').doc(user.uid).set({
    //       'sentVerificationEmailDate': DateTime.now(),
    //     }, SetOptions(merge: true));
    //     await user.sendEmailVerification();
    //   }
    //   return user;
    // } on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     print('No user found for that email.');
    //   } else if (e.code == 'wrong-password') {
    //     print('Wrong password provided for that user.');
    //   }
    // }
    // return null;
  }

  void updateUserData(User user) async {
    // print("Updating User: " + user.uid);
    // _db.collection('users').doc(user.uid).set(
    //     {'uid': user.uid, 'lastSeen': DateTime.now()}, SetOptions(merge: true));
  }

  void signOut() {
    _auth.signOut();
  }

  Future<User> handleSignUp(
      {String email, String password, String name}) async {
    // print("User Started");
    // UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
    //     email: email, password: password);
    // User user = userCredential.user;

    // assert(user != null);
    // assert(await user.getIdToken() != null);
    // await user.sendEmailVerification();
    // updateUserData(user);
    // user.updateProfile(displayName: name);
    // _db.collection('users').doc(user.uid).set({
    //   'sentVerificationEmailDate': DateTime.now(),
    // }, SetOptions(merge: true));
    // return user;
  }

  Stream<User> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(user.uid).get();
      return User.fromSnapshot(userDoc);
    });
  }
}
