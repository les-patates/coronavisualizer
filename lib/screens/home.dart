import 'package:flutter/material.dart';
import 'package:flutterapp/models/covid_model.dart';
import 'package:flutterapp/util/getCovid.dart';
import 'package:flutterapp/widgets/BarChartWidget.dart';

import 'barScreen.dart';

String country = "Italy";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isTyping = false;
  FocusNode researchNode;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Corona live cases'),
        ),
        body: Column(children: <Widget>[
          new Flexible(
            child: ListView.builder(
              itemCount: _covids.length,
              itemBuilder: (context, index) {
                return Card(
                    child: ListTile(
                  title: Text(_covids[index].country +
                      ", " +
                      _covids[index].province +
                      ", " +
                      _covids[index].lastUpdate),
                  subtitle: Text(Covid.stringBuilder(_covids[index])),
                ));
              },
            ),
          ),
          new Container(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              focusNode: researchNode,
            )
          )
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.search),
          onPressed: () {
            researchNode.requestFocus();
          },
          heroTag: "btn1",
        ),
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 4.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Container(
                  child: _isTyping ? _buildTextComposer() : Text(""),
                ),
                IconButton(
                    icon: Icon(Icons.data_usage),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AppScreen(country)));
                    }),
              ],
            )),
      );

  List<Covid> _covids = <Covid>[];

  @override
  void initState() {
    super.initState();
    listenForCovid(country);
    researchNode = FocusNode();
  }
  @override
  void dispose() {
    researchNode.dispose();
    super.dispose();
  }

  void listenForCovid(String country) async {
    final Stream<Covid> stream = await getCovid(country);
    stream.listen((Covid covid) {
      setState(() => _covids.add(covid));
    });
  }

  void _handleSubmitted(String text) {
    country = _textController.text;
    _textController.clear();
    _covids = [];
    listenForCovid(country);
  }

  final TextEditingController _textController = new TextEditingController();

  Widget _buildTextComposer() {
    return new Row(
      children: <Widget>[
        new Flexible(
          child: new TextField(
            controller: _textController,
            onSubmitted: _handleSubmitted,
            decoration: new InputDecoration(
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30.0),
                  ),
                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                ),
                filled: true,
                hintText: "Taper message",
                contentPadding: EdgeInsets.only(left: 5.0)),
          ),
        ),
        new Container(
          margin: new EdgeInsets.all(3.0),
          child: new FloatingActionButton(
            heroTag: "btn2",
            onPressed: () => _handleSubmitted(_textController.text),
            child: new Icon(Icons.send),
            backgroundColor: Colors.green,
          ),
        ),
      ], //new
    );
  }
}
