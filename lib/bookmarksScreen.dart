import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import './globals.dart' as globals;

class BookmarksScreen extends StatefulWidget {
	BookmarksScreen({Key key}) : super(key: key);

	@override
	_BookmarksScreenState createState() => new _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
	DataSnapshot snapshot;
	bool change=false;
	final databaseReference = FirebaseDatabase.instance.reference();
	var articleDatabaseReference;
	final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

	Future updateSnapshot() async {
		articleDatabaseReference = databaseReference.child(globals.userId).child('articles');
		var snap = await articleDatabaseReference.once();
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
	pushArticle(article){
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
		if(snapshot.value!=null) {
			var value = snapshot.value;
			int flag=0;
			value.forEach((k,v) {
				if( v['url'].compareTo(article['url']) == 0 ){
					flag=1;
					articleDatabaseReference.child(k).remove();
					Scaffold.of(context).showSnackBar(new SnackBar(
						content: new Text('Bookmark removed'),
						backgroundColor: Colors.grey[600],
					));
				}
			});
			if(flag != 1){
				pushArticle(article);
				Scaffold.of(context).showSnackBar(new SnackBar(
					content: new Text('Bookmark added'),
					backgroundColor: Colors.grey[600],
				));
			}
			this.setState(() {change = true;});
		} else {
			pushArticle(article);
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
			body: new Column(children: <Widget>[
			new Flexible(
			child: new FirebaseAnimatedList(
				query: articleDatabaseReference,
				sort: (a, b) => b.key.compareTo(a.key),
				padding: new EdgeInsets.all(8.0),
				itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {
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
													new Padding(
															padding: new EdgeInsets.all(5.0),
															child: snapshot.value["author"] != null?
																new Text( "Author: ${snapshot.value["author"]}",
																	style: new TextStyle(
																			fontWeight: FontWeight.w500,
																			color: Colors.black,
																		),
																):
																null
													),
												],
											),
											onTap: () {
												flutterWebviewPlugin.launch(snapshot.value["url"], fullScreen: false);
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
														onTap: () {share(snapshot.value["url"]);},
													),
													new GestureDetector(
														child: buildButtonColumn(Icons.bookmark),
														onTap: () { _onBookmarkTap( snapshot.value);},
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
			),
		),
		],
			),
		);
	}
}