import 'dart:async';
import 'package:flutter/material.dart';
import './homeScreen.dart' as homeScreeen;
import './bookmarksScreen.dart' as bookmarkScreen;
import './libraryScreen.dart' as libraryScreen;
import './globalStore.dart' as globalStore;

void main() {
  runApp(new MaterialApp(home: new NewsApp()));
}

class NewsApp extends StatefulWidget {
  @override
  createState() => new NewsAppState();
}

class NewsAppState extends State<NewsApp> with SingleTickerProviderStateMixin {
  TabController controller;
  Future ensureLogIn() async {
    await globalStore.logIn;
  }

  @override
  void initState() {
    super.initState();
    this.ensureLogIn();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("News App"),
        ),
        bottomNavigationBar: new Material(
            color: Colors.blue[600],
            child: new TabBar(controller: controller, tabs: <Tab>[
              new Tab(icon: new Icon(Icons.view_headline)),
              new Tab(icon: new Icon(Icons.view_module)),
              new Tab(icon: new Icon(Icons.bookmark)),
            ])),
        body: new TabBarView(controller: controller, children: <Widget>[
          new homeScreeen.HomeScreen(),
          new libraryScreen.LibraryScreen(),
          new bookmarkScreen.BookmarksScreen(),
        ]));
  }
}
