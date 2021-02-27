import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_perspective_app/interfaces.dart';

class AuthService {
  // Dependencies
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // constructor
  AuthService() {}

  Future<User> googleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseAuth.GoogleAuthCredential credential =
        FirebaseAuth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.UserCredential userCreds =
        await _auth.signInWithCredential(credential);
    // updateUserData(userCreds.user);
    return await User.getUserFromID(userCreds.user.uid);
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
    print("Updating User: " + user.uid);
    _db.collection('users').doc(user.uid).set(
        {'uid': user.uid, 'lastSeen': Timestamp.now()},
        SetOptions(merge: true));
  }

  void signOut() async {
    await _auth.signOut();
  }

  signUpEmail({String email, String password, String name}) async {
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

  Stream<bool> userSignedIn() {
    return _auth.authStateChanges().asyncMap((user) async {
      print("Auth State Changed");
      if (user == null) {
        print("Not Signed In");
        return false;
      }
      print("User Authed");
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(user.uid).get();
      if (userDoc.data() == null) {
        print("Not registered");
        return false;
      }
      return true;
    });
  }

  signUpGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseAuth.GoogleAuthCredential credential =
        FirebaseAuth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    print("UID: " + userCredential.user.uid);
    FirebaseAuth.User firebaseUser = userCredential.user;
    User user = User.fromJson({
      'uid': firebaseUser.uid,
      'displayName': firebaseUser.displayName,
      'photoURL': firebaseUser.photoURL,
      'email': firebaseUser.email,
      'lastSeen': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'registered': false,
      'isVerified': true
    });
    print("Signing in google: " + user.uid);
    await createUserProfile(user);
  }

  signUpAnonymous() async {
    FirebaseAuth.UserCredential userCredential =
        await _auth.signInAnonymously();
    User user = User.fromJson({
      'uid': userCredential.user.uid,
      'displayName': "Guest",
      'lastSeen': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'registered': false,
      'isVerified': true,
      'photoURL':
          "https://www.tenforums.com/geek/gars/images/2/types/thumb_15951118880user.png", // TODO THIS IS HARDCODED FOR NOW
    });
    print("Signing in guest: " + user.uid);
    await createUserProfile(user);
  }

  createUserProfile(User user) async {
    await _db.collection('users').doc(user.uid).set(user.toJson());
  }
}
