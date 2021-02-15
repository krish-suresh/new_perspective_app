import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return userCreds.user;
  }

  Future<User> signIn({String email, String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

  void updateUserData(User user) async {}

  void signOut() {
    _auth.signOut();
  }

  Future<User> handleSignUp(email, password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = userCredential.user;

    assert(user != null);
    assert(await user.getIdToken() != null);

    return user;
  }
}
