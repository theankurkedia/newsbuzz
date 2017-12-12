import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:timeago/timeago.dart';
import './globalStore.dart' as globalStore;

class BookmarksScreen extends StatefulWidget {
  BookmarksScreen({Key key}) : super(key: key);

  @override
  _BookmarksScreenState createState() => new _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  DataSnapshot snapshot;
  bool change = false;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

  Future updateSnapshot() async {
    var snap = await globalStore.articleDatabaseReference.once();
    this.setState(() {
      snapshot = snap;
    });
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.updateSnapshot();
  }

  _onBookmarkTap(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      value.forEach((k, v) {
        if (v['url'].compareTo(article['url']) == 0) {
          globalStore.articleDatabaseReference.child(k).remove();
          Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text('Bookmark removed'),
                backgroundColor: Colors.grey[600],
              ));
        }
      });
      this.updateSnapshot();
      this.setState(() {
        change = true;
      });
    }
  }

  Column buildButtonColumn(IconData icon) {
    Color color = Theme.of(context).primaryColor;
    return new Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Icon(icon, color: color),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[200],
      body: (snapshot != null && snapshot.value != null)
          ? new Column(
              children: <Widget>[
                new Flexible(
                    child: new FirebaseAnimatedList(
                  query: globalStore.articleDatabaseReference,
                  sort: (a, b) => b.key.compareTo(a.key),
                  padding: new EdgeInsets.all(2.0),
                  itemBuilder: (_, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return new GestureDetector(
                      child: new Card(
                        child: new Row(
                          children: [
                            new Expanded(
                              child: new GestureDetector(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new Text(
                                      snapshot.value["title"],
                                      style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    new Text(
                                      snapshot.value["description"],
                                      style: new TextStyle(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    new Text(
                                      "Published " +
                                          timeAgo(DateTime.parse(
                                              snapshot.value["publishedAt"])),
                                      style: new TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    new Padding(
                                      padding: new EdgeInsets.all(5.0),
                                      child: new Text(
                                        "Source: ${snapshot.value["source"]}",
                                        style: new TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  flutterWebviewPlugin.launch(
                                      snapshot.value["url"],
                                      fullScreen: false);
                                },
                              ),
                            ),
                            new Column(
                              children: <Widget>[
                                new SizedBox(
                                  height: 100.0,
                                  width: 100.0,
                                  child: new Image.network(
                                    snapshot.value["urlToImage"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                new Row(
                                  children: <Widget>[
                                    new GestureDetector(
                                      child: buildButtonColumn(Icons.share),
                                      onTap: () {
                                        share(snapshot.value["url"]);
                                      },
                                    ),
                                    new GestureDetector(
                                      child: buildButtonColumn(Icons.bookmark),
                                      onTap: () {
                                        _onBookmarkTap(snapshot.value);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ],
            )
          : new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Icon(Icons.chrome_reader_mode,
                      color: Colors.grey, size: 60.0),
                  new Text(
                    "No articles saved",
                    style: new TextStyle(fontSize: 24.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
