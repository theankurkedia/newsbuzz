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

class ArticleSourceScreen extends StatefulWidget {
  ArticleSourceScreen(
      {Key key,
      this.sourceId = "techcrunch",
      this.sourceName = "TechCrunch",
      this.isCategory: false})
      : super(key: key);
  final sourceId;
  final sourceName;
  final isCategory;
  @override
  _ArticleSourceScreenState createState() => new _ArticleSourceScreenState(
      sourceId: this.sourceId,
      sourceName: this.sourceName,
      isCategory: this.isCategory);
}

class _ArticleSourceScreenState extends State<ArticleSourceScreen> {
  _ArticleSourceScreenState({this.sourceId, this.sourceName, this.isCategory});
  var data;
  final sourceId;
  final sourceName;
  final isCategory;
  bool change = false;
  DataSnapshot snapshot;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  final auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  var userDatabaseReference;
  var articleDatabaseReference;

  Future getData() async {
    var response;

    if (isCategory) {
      response = await http.get(
          Uri.encodeFull('https://newsapi.org/v2/top-headlines?category=' +
              sourceId +
              '&language=en'),
          headers: {
            "Accept": "application/json",
            "X-Api-Key": "ab31ce4a49814a27bbb16dd5c5c06608"
          });
    } else {
      response = await http.get(
          Uri.encodeFull(
              'https://newsapi.org/v2/top-headlines?sources=' + sourceId),
          headers: {
            "Accept": "application/json",
            "X-Api-Key": "ab31ce4a49814a27bbb16dd5c5c06608"
          });
    }
    userDatabaseReference = databaseReference.child(globalStore.user.id);
    articleDatabaseReference = userDatabaseReference.child('articles');
    var snap = await articleDatabaseReference.once();
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
                content: new Text('Article removed'),
                backgroundColor: Colors.grey[600],
              ));
        }
      });
      if (flag != 1) {
        pushArticle(article);
        Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text('Article added'),
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
      appBar: new AppBar(
        title: new Text(sourceName),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: data == null
          ? const Center(child: const CircularProgressIndicator())
          : data["articles"].length != 0
              ? new ListView.builder(
                  itemCount: data == null ? 0 : data["articles"].length,
                  padding: new EdgeInsets.all(8.0),
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                      child: new Card(
                        elevation: 1.7,
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
                                      data["articles"][index]["source"]["name"],
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
                                              data["articles"][index]["title"],
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
                                        padding: new EdgeInsets.only(top: 8.0),
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
                                                        data["articles"][index])
                                                    ? buildButtonColumn(
                                                        Icons.bookmark)
                                                    : buildButtonColumn(
                                                        Icons.bookmark_border)),
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
                )
              : new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new Icon(Icons.chrome_reader_mode,
                          color: Colors.grey, size: 60.0),
                      new Text(
                        "No articles saved",
                        style:
                            new TextStyle(fontSize: 24.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
    );
  }
}
