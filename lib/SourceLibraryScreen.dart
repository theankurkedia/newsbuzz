import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './ArticleSourceScreen.dart' as ArticleSourceScreen;
import './globalStore.dart' as globalStore;

class SourceLibraryScreen extends StatefulWidget {
  SourceLibraryScreen({Key key}) : super(key: key);

  @override
  _SourceLibraryScreenState createState() => new _SourceLibraryScreenState();
}

class _SourceLibraryScreenState extends State<SourceLibraryScreen> {
  DataSnapshot snapshot;
  var sources;
  bool change = false;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

  Future getData() async {
    var libSources = await http.get(
        Uri.encodeFull('https://newsapi.org/v2/sources?language=en'),
        headers: {
          "Accept": "application/json",
          "X-Api-Key": "ab31ce4a49814a27bbb16dd5c5c06608"
        });

    var snap = await globalStore.articleSourcesDatabaseReference.once();
    this.setState(() {
      sources = JSON.decode(libSources.body);
      snapshot = snap;
    });
    return "Success!";
  }

  _hasSource(id) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      if (value != null) {
        value.forEach((k, v) {
          if (v['id'].compareTo(id) == 0) {
            flag = 1;
          }
        });
        if (flag == 1) return true;
      }
    }
    return false;
  }

  pushSource(name, id) {
    globalStore.articleSourcesDatabaseReference.push().set({
      'name': name,
      'id': id,
    });
  }

  _onAddTap(name, id) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      value.forEach((k, v) {
        if (v['id'].compareTo(id) == 0) {
          flag = 1;
          Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text('News source removed'),
                backgroundColor: Colors.grey[600],
              ));
          globalStore.articleSourcesDatabaseReference.child(k).remove();
        }
      });
      if (flag != 1) {
        Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text('News source added'),
              backgroundColor: Colors.grey[600],
            ));
        pushSource(name, id);
      }
    } else {
      pushSource(name, id);
    }
    this.getData();
    this.setState(() {
      change = true;
    });
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[200],
      body: sources == null
          ? const Center(
              child: const CupertinoActivityIndicator(),
            )
          : new GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 25.0),
              padding: const EdgeInsets.all(10.0),
              itemCount: sources == null ? 0 : sources['sources'].length,
              itemBuilder: (BuildContext context, int index) {
                return new GridTile(
                  footer: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Flexible(
                          child: new SizedBox(
                            height: 16.0,
                            width: 100.0,
                            child: new Text(
                              sources['sources'][index]['name'],
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ]),
                  child: new Container(
                    height: 500.0,
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: new GestureDetector(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new SizedBox(
                            height: 100.0,
                            width: 100.0,
                            child: new Row(
                              children: <Widget>[
                                new Stack(
                                  children: <Widget>[
                                    new SizedBox(
                                      child: new Container(
                                        child: new CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: new NetworkImage(
                                              "https://icons.better-idea.org/icon?url=" +
                                                  sources['sources'][index]
                                                      ['url'] +
                                                  "&size=120"),
                                          radius: 40.0,
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 20.0, right: 10.0),
                                      ),
                                    ),
                                    new Positioned(
                                      right: 0.0,
                                      child: new GestureDetector(
                                        child: _hasSource(
                                                sources['sources'][index]['id'])
                                            ? new Icon(Icons.check_circle)
                                            : new Icon(
                                                Icons.add_circle_outline),
                                        onTap: () {
                                          _onAddTap(
                                              sources['sources'][index]['name'],
                                              sources['sources'][index]['id']);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (_) =>
                                    new ArticleSourceScreen.ArticleSourceScreen(
                                      sourceId: sources['sources'][index]['id'],
                                      sourceName: sources['sources'][index]
                                          ['name'],
                                      isCategory: false,
                                    )));
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
