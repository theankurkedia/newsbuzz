library news.globals;

import 'dart:async';
import 'package:flutter/material.dart';
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

List categories = [
  {"id": "business", "name": "Business", "icon": Icons.work},
  {"id": "technology", "name": "Technology", "icon": Icons.smartphone},
  {
    "id": "science-and-nature",
    "name": "Science and Nature",
    "icon": Icons.nature_people
  },
  {"id": "sport", "name": "Sports", "icon": Icons.directions_bike},
  {"id": "entertainment", "name": "Entertainment", "icon": Icons.local_movies},
  {"id": "gaming", "name": "Gaming", "icon": Icons.videogame_asset},
  {"id": "general", "name": "General", "icon": Icons.people},
  {
    "id": "health-and-medical",
    "name": "Health and Medical",
    "icon": Icons.local_hospital
  },
  {"id": "music", "name": "Music", "icon": Icons.music_note},
  {"id": "politics", "name": "Politics", "icon": Icons.assistant_photo}
];
