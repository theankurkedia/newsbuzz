// Screen for the grid of choices and then redirect to the webview for each Grid Tile related URL
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './SourcesScreen.dart' as SourcesScreen;
import './globalStore.dart' as globalStore;

class CategoriesScreen extends StatefulWidget {
  CategoriesScreen({Key key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => new _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[200],
      body: globalStore.categories == null
          ? const Center(
              child: const CupertinoActivityIndicator(),
            )
          : new GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 25.0),
              padding: const EdgeInsets.all(10.0),
              itemCount: globalStore.categories.length,
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
                              globalStore.categories[index]["name"],
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
                                          backgroundColor: Colors.white,
                                          radius: 40.0,
                                          child: new Icon(
                                              globalStore.categories[index]
                                                  ["icon"],
                                              size: 50.0,
                                              color: Colors.blueGrey),
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10.0, right: 10.0),
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
                                builder: (_) => new SourcesScreen.SourcesScreen(
                                      sourceId: globalStore.categories[index]
                                          ['id'],
                                      sourceName: globalStore.categories[index]
                                          ["name"],
                                      isCategory: true,
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
