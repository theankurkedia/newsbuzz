import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
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
	final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

	Future getData() async {
		var response = await http.get(Uri.encodeFull('http://newsapi.org/v1/articles?source=techcrunch&sortBy=top&apiKey=ab31ce4a49814a27bbb16dd5c5c06608'),
			headers: {
				"Accept": "application/json"
			}
		);
		var responseSources = await http.get(Uri.encodeFull('https://newsapi.org/v1/sources?language=en'),
			headers: {
				"Accept": "application/json"
			}
		);
		this.setState(() {
			data = JSON.decode(response.body);
			sources = JSON.decode(responseSources.body);
		});
		return "Success!";
	}

	_containsArticle(article){
		for( var i in globals.bookmarks){
			if( i['url'].compareTo(article['url']) == 0 )
				return globals.bookmarks.indexOf(i);
		}
		return -1;
	}
	_onBookmarkTap(article){
		int articleIndex = _containsArticle(article);
		if(articleIndex == -1) {
			globals.bookmarks.add(article);
			this.setState(() {globals.bookmarks = globals.bookmarks;});
			Scaffold.of(context).showSnackBar(new SnackBar(
				content: new Text('Bookmark added'),
				backgroundColor: Colors.grey[600],
			));
		} else {
			globals.bookmarks.removeAt(articleIndex);
			this.setState(() {globals.bookmarks = globals.bookmarks;});
			Scaffold.of(context).showSnackBar(new SnackBar(
				content: new Text('Bookmark removed'),
				backgroundColor: Colors.grey[600],
			));
		}
	}
	_findSourceName(id) {
		for( var i in sources["sources"]){
			if( i["id"].compareTo(id) == 0 )
				return i["name"];
		}
	}
	_Refresh(){
		this.getData();
	}

	@override
	void initState() {
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
				child: data==null? const Center(
					child: const CupertinoActivityIndicator(),
				):
				new ListView.builder(
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
															children: <Widget>[
																new Text(
																	"Source: ${_findSourceName(data["source"])}",
																	style: new TextStyle(
																		fontWeight: FontWeight.bold,
																		color: Colors.black,
																	),
																),
															],
														),
													],
												),
												onTap: () {
													flutterWebviewPlugin.launch(data["articles"][index]["url"], fullScreen: false);
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
															onTap: () { share(data["articles"][index]["url"]);},
														),
														new GestureDetector(
															child: (_containsArticle(data["articles"][index]) == -1)? buildButtonColumn(Icons.bookmark_border):buildButtonColumn(Icons.bookmark) ,
															onTap: () { _onBookmarkTap( data["articles"][index]);},
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
				onVerticalDragDown: _Refresh(),
			),
		);
	}
}