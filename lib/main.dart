import 'dart:async';
import 'package:flutter/material.dart';
import './HomeScreen.dart' as HomeScreeen;
import './LibraryScreen.dart' as LibraryScreen;
import './CategoriesScreen.dart' as CategoriesScreen;
import './BookmarkScreen.dart' as BookmarkScreen;
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
    controller = new TabController(vsync: this, length: 4);
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
              new Tab(icon: new Icon(Icons.explore)),
              new Tab(icon: new Icon(Icons.bookmark)),
            ])),
        body: new TabBarView(controller: controller, children: <Widget>[
          new HomeScreeen.HomeScreen(),
          new LibraryScreen.LibraryScreen(),
          new CategoriesScreen.CategoriesScreen(),
          new BookmarkScreen.BookmarksScreen(),
        ]));
  }
}
