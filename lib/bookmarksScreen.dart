import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './globals.dart' as globals;

class BookmarksScreen extends StatefulWidget {
	BookmarksScreen({Key key}) : super(key: key);

	@override
	_BookmarksScreenState createState() => new _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
	var data;
	final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
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
			body: globals.bookmarks.isEmpty ?
				new Container(
					child: new Center(
						child: new Icon(Icons.bookmark_border, size: 150.0, color: Colors.grey[500])
					),
					color: Colors.grey[300],
				)
				:
				new ListView.builder(
					itemCount: globals.bookmarks.isEmpty ? 0 : globals.bookmarks.length,
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
																globals.bookmarks[index]["title"],
																style: new TextStyle(
																	fontWeight: FontWeight.bold,
																),
															),
															new Text(
																globals.bookmarks[index]["description"],
																style: new TextStyle(
																	color: Colors.grey[500],
																),
															),
															new Row(
																children: <Widget>[
																	new Text(
																		globals.bookmarks[index]["author"],
																		style: new TextStyle(
																			color: Colors.grey[500],
																		),
																	),
																],
															),
														],
													),
													onTap: () {
														flutterWebviewPlugin.launch(globals.bookmarks[index]["url"], fullScreen: false);
													},
												),
											),
											new Column(
												children: <Widget>[
													new SizedBox(
														height: 100.0,
														width: 100.0,
														child: new Image.network(
															globals.bookmarks[index]["urlToImage"],
															fit: BoxFit.cover,
														),
													),
													new Row(
														children: <Widget>[
															new GestureDetector(
																child: buildButtonColumn(Icons.share),
																onTap: () {share(globals.bookmarks[index]["url"]);},
															),
															new GestureDetector(
																child: buildButtonColumn(Icons.bookmark),
																onTap: () { _onBookmarkTap( globals.bookmarks[index]);},
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
		);
	}
}