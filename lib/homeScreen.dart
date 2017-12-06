import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './globals.dart' as globals;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var data;
  var sources;
  var user;
  bool change = false;
  var newsSelection = "techcrunch";
  DataSnapshot snapshot;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  final auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  var userDatabaseReference;
  var articleDatabaseReference;

  Future getData() async {
    var response = await http.get(
        Uri.encodeFull('http://newsapi.org/v1/articles?source=' +
            newsSelection +
            '&sortBy=top&apiKey=ab31ce4a49814a27bbb16dd5c5c06608'),
        headers: {"Accept": "application/json"});
    var responseSources = await http.get(
        Uri.encodeFull('https://newsapi.org/v1/sources?language=en'),
        headers: {"Accept": "application/json"});
    userDatabaseReference = databaseReference.child(globals.userId);
    articleDatabaseReference = userDatabaseReference.child('articles');
    var snap = await articleDatabaseReference.once();
    this.setState(() {
      data = JSON.decode(response.body);
      sources = JSON.decode(responseSources.body);
      snapshot = snap;
    });
    return "Success!";
  }

  _hasArticle(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      if (value != null) {
        value.forEach((k, v) {
          if (v['url'].compareTo(article['url']) == 0) {
            flag = 1;
            // return true;
          }
        });
        if (flag == 1) return true;
      }
    }
    return false;
  }

  pushArticle(article) {
    articleDatabaseReference.push().set({
      'author': article['author'],
      'description': article['description'],
      'publishedAt': article['publishedAt'],
      'title': article['title'],
      'url': article['url'],
      'urlToImage': article['urlToImage'],
    });
  }

  _onBookmarkTap(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      value.forEach((k, v) {
        if (v['url'].compareTo(article['url']) == 0) {
          flag = 1;
          articleDatabaseReference.child(k).remove();
          Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text('Bookmark removed'),
                backgroundColor: Colors.grey[600],
              ));
        }
      });
      if (flag != 1) {
        Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text('Bookmark added'),
              backgroundColor: Colors.grey[600],
            ));
        pushArticle(article);
      }
    } else {
      pushArticle(article);
    }
    this.getData();
    this.setState(() {
      change = true;
    });
  }

  _findSourceName(id) {
    for (var i in sources["sources"]) {
      if (i["id"].compareTo(id) == 0) return i["name"];
    }
  }

  _refresh() {
    this.getData();
  }

  @override
  void initState() {
    super.initState();
    this.getData();
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
      body: new GestureDetector(
        child: data == null
            ? const Center(
                child: const CupertinoActivityIndicator(),
              )
            : new ListView.builder(
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (BuildContext context, int index) {
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
                                    data["articles"][index]["title"],
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  new Text(
                                    data["articles"][index]["description"],
                                    style: new TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  new Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      new Text(
                                        "Source: ${_findSourceName(data["source"])}",
                                        style: new TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                flutterWebviewPlugin.launch(
                                    data["articles"][index]["url"],
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
                                  data["articles"][index]["urlToImage"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              new Row(
                                children: <Widget>[
                                  new GestureDetector(
                                    child: buildButtonColumn(Icons.share),
                                    onTap: () {
                                      share(data["articles"][index]["url"]);
                                    },
                                  ),
                                  new GestureDetector(
                                    child: _hasArticle(data["articles"][index])
                                        ? buildButtonColumn(Icons.bookmark)
                                        : buildButtonColumn(
                                            Icons.bookmark_border),
                                    onTap: () {
                                      _onBookmarkTap(data["articles"][index]);
                                    },
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
        onVerticalDragDown: _refresh(),
      ),
    );
  }
}

//find something related to bind and use function _hasArticle with it. RIght now it keeps on rendering
