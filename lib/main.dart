
import 'package:flutter/material.dart';
import './homeScreen.dart' as homeScreeen;
import './bookmarksScreen.dart' as bookmarkScreen;

void main() {
	runApp(new MaterialApp(
		home: new NewsApp()
	));
}

class  NewsApp extends StatefulWidget {
	@override
	 createState() => new NewsAppState();
}

class NewsAppState extends State<NewsApp> with SingleTickerProviderStateMixin {
	TabController controller;

	@override
	void initState() {
		super.initState();
		controller = new TabController(vsync: this, length: 2);
	}

	@override
	void dispose() {
		controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: new AppBar(
				title: new Text("News App"),
			),
			bottomNavigationBar: new Material(
				color: Colors.blue[600],
				child: new TabBar(
					controller: controller,
					tabs: <Tab>[
						new Tab(icon: new Icon(Icons.home), text: "For You"),
						new Tab(icon: new Icon(Icons.bookmark), text: "Read Later"),
					]
				)
			),
			body: new TabBarView(
				controller: controller,
				children: <Widget>[
					new homeScreeen.HomeScreen(),
					new bookmarkScreen.BookmarksScreen()
				]
			)
		);
	}
}