import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_login/res/constant.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn? googleSignIn = GoogleSignIn();

String? name;
String? email;
String? imageUrl;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn!.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );
  UserCredential authResult =
      await firebaseAuth.signInWithCredential(credential);
  User? user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    // Checking if email and name is null
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);
    // Store the retrieved data
    name = user.displayName;
    email = user.email;
    imageUrl = user.photoURL;

    // if (name.contains("")) {
    //   name = name.substring(0, name.indexOf(""));
    // }
    // final User? currentUser = kFirebaseAuth.currentUser;
    // assert(user.uid == currentUser!.uid);

    log('signInWithGoogle succeeded: $user');
    return '$user';
  }
  return '';
}

Future<void> signOutGoogle() async {
  await googleSignIn!.signOut();
  print("User Signed Out");
}
