import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:timeago/timeago.dart';
import './globalStore.dart' as globalStore;

class SearchScreen extends StatefulWidget {
  SearchScreen({
    Key key,
    this.searchQuery = "",
  })
      : super(key: key);
  final searchQuery;
  @override
  _SearchScreenState createState() =>
      new _SearchScreenState(searchQuery: this.searchQuery);
}

class _SearchScreenState extends State<SearchScreen> {
  _SearchScreenState({this.searchQuery});

  var searchQuery;
  var data;
  bool change = false;
  DataSnapshot snapshot;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  final auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  var userDatabaseReference;
  var articleDatabaseReference;

  Future getData() async {
    var response = await http.get(
        Uri.encodeFull('https://newsapi.org/v2/everything?q=' +
            searchQuery +
            '&sortBy=popularity'),
        headers: {
          "Accept": "application/json",
          "X-Api-Key": "ab31ce4a49814a27bbb16dd5c5c06608"
        });

    var snap = await globalStore.articleDatabaseReference.once();

    if (mounted) {
      this.setState(() {
        data = JSON.decode(response.body);
        snapshot = snap;
      });
    }
    return "Success!";
  }

  _hasArticle(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      if (value != null) {
        value.forEach((k, v) {
          if (v['url'].compareTo(article['url']) == 0) flag = 1;
          return;
        });
        if (flag == 1) return true;
      }
    }
    return false;
  }

  pushArticle(article) {
    articleDatabaseReference.push().set({
      'source': article["source"]["name"],
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
        pushArticle(article);
        Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text('Bookmark added'),
              backgroundColor: Colors.grey[600],
            ));
      }
      if (mounted) {
        this.setState(() {
          change = true;
        });
      }
    } else {
      pushArticle(article);
    }
  }

  _refresh() {
    this.getData();
  }

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

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(searchQuery)),
      backgroundColor: Colors.grey[200],
      body: new GestureDetector(
        child: data == null
            ? const Center(
                child: const CupertinoActivityIndicator(),
              )
            : data["articles"].length < 1
                ? new Center(
                    child: new Text(
                      "Could not find anything related to '$searchQuery'",
                      style: new TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
                : new ListView.builder(
                    itemCount: data['articles'].length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                        child: new Card(
                          child: new Padding(
                            padding: new EdgeInsets.all(10.0),
                            child: new Column(
                              children: [
                                new Row(
                                  children: <Widget>[
                                    new Padding(
                                      padding: new EdgeInsets.only(left: 4.0),
                                      child: new Text(
                                        timeAgo(DateTime.parse(data["articles"]
                                            [index]["publishedAt"])),
                                        style: new TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    new Padding(
                                      padding: new EdgeInsets.all(5.0),
                                      child: new Text(
                                        data["articles"][index]["source"]
                                            ["name"],
                                        style: new TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  children: [
                                    new Expanded(
                                      child: new GestureDetector(
                                        child: new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            new Padding(
                                              padding: new EdgeInsets.only(
                                                  left: 4.0,
                                                  right: 8.0,
                                                  bottom: 8.0,
                                                  top: 8.0),
                                              child: new Text(
                                                data["articles"][index]
                                                    ["title"],
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            new Padding(
                                              padding: new EdgeInsets.only(
                                                  left: 4.0,
                                                  right: 4.0,
                                                  bottom: 4.0),
                                              child: new Text(
                                                data["articles"][index]
                                                    ["description"],
                                                style: new TextStyle(
                                                  color: Colors.grey[500],
                                                ),
                                              ),
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
                                        new Padding(
                                          padding:
                                              new EdgeInsets.only(top: 8.0),
                                          child: new SizedBox(
                                            height: 100.0,
                                            width: 100.0,
                                            child: new Image.network(
                                              data["articles"][index]
                                                  ["urlToImage"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            new GestureDetector(
                                              child: new Padding(
                                                  padding:
                                                      new EdgeInsets.symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 5.0),
                                                  child: buildButtonColumn(
                                                      Icons.share)),
                                              onTap: () {
                                                share(data["articles"][index]
                                                    ["url"]);
                                              },
                                            ),
                                            new GestureDetector(
                                              child: new Padding(
                                                  padding:
                                                      new EdgeInsets.all(5.0),
                                                  child: _hasArticle(
                                                          data["articles"]
                                                              [index])
                                                      ? buildButtonColumn(
                                                          Icons.bookmark)
                                                      : buildButtonColumn(Icons
                                                          .bookmark_border)),
                                              onTap: () {
                                                _onBookmarkTap(
                                                    data["articles"][index]);
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
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
