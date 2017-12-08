import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
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

    this.setState(() {
      data = JSON.decode(response.body);
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
          if (v['url'].compareTo(article['url']) == 0) flag = 1;
        });
        if (flag == 1)
          return true;
        else
          return false;
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
      this.setState(() {
        change = true;
      });
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
                          child: new Row(
                            children: [
                              new Expanded(
                                child: new GestureDetector(
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        children: <Widget>[
                                          new Text(
                                            "Source: ${ data["articles"][index]["source"]["name"]}",
                                            style: new TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          )
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
                                        child: _hasArticle(
                                                data["articles"][index])
                                            ? buildButtonColumn(Icons.bookmark)
                                            : buildButtonColumn(
                                                Icons.bookmark_border),
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
                        ),
                      );
                    },
                  ),
        onVerticalDragDown: _refresh(),
      ),
    );
  }
}
