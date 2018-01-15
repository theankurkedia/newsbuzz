import 'dart:async';
import 'package:flutter/material.dart';
import './HomeFeedScreen.dart' as HomeFeedScreeen;
import './SourceLibraryScreen.dart' as SourceLibraryScreen;
import './CategoriesScreen.dart' as CategoriesScreen;
import './BookmarkScreen.dart' as BookmarkScreen;
import './globalStore.dart' as globalStore;

void main() {
  runApp(new MaterialApp(home: new NewsBuzz()));
}

class NewsBuzz extends StatefulWidget {
  @override
  createState() => new NewsBuzzState();
}

class NewsBuzzState extends State<NewsBuzz>
    with SingleTickerProviderStateMixin {
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
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("News Buzz"),
          centerTitle: true,
        ),
        bottomNavigationBar: new Material(
            color: Colors.blue[600],
            child: new TabBar(controller: controller, tabs: <Tab>[
              new Tab(icon: new Icon(Icons.view_headline, size: 30.0)),
              new Tab(icon: new Icon(Icons.view_module, size: 30.0)),
              new Tab(icon: new Icon(Icons.explore, size: 30.0)),
              new Tab(icon: new Icon(Icons.bookmark, size: 30.0)),
            ])),
        body: new TabBarView(controller: controller, children: <Widget>[
          new HomeFeedScreeen.HomeFeedScreen(),
          new SourceLibraryScreen.SourceLibraryScreen(),
          new CategoriesScreen.CategoriesScreen(),
          new BookmarkScreen.BookmarksScreen(),
        ]));
  }
}
