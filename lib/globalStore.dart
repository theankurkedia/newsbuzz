import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

String userId;
var sourceList = [];
final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
final databaseReference = FirebaseDatabase.instance.reference();
var userDatabaseReference;
var articleSourcesDatabaseReference;
var articleDatabaseReference;
Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) user = await googleSignIn.signInSilently();
  if (user == null) {
    await googleSignIn.signIn();
    analytics.logLogin();
  }
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  }
  userId = user.id;
  userDatabaseReference = databaseReference.child(user.id);
  articleDatabaseReference = databaseReference.child(user.id).child('articles');
  articleSourcesDatabaseReference =
      databaseReference.child(user.id).child('sources');
}

var logIn = _ensureLoggedIn();
