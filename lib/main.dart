import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp(
    model: CounterModel(),
  ));
}

class MyApp extends StatelessWidget {
  final CounterModel model;

  const MyApp({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // At the top level of our app, we'll, create a ScopedModel Widget. This
    // will provide the CounterModel to all children in the app that request it
    // using a ScopedModelDescendant.
    return ScopedModel<CounterModel>(
      model: model,
      child: MaterialApp(
        title: 'Scoped Model Demo',
        home: CounterHome('Scoped Model Demo'),
      ),
    );
  }
}

// Start by creating a class that has a counter and a method to increment it.
//
// Note: It must extend from Model.
class CounterModel extends Model {
  int _counter = 0;
  dynamic _url = "http://www.google.de/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png";

  int get counter => _counter;
  dynamic get urlget => _url;
  List<String> _imagesToLabel = [];


  CounterModel() {
    HttpClient()
    .getUrl(Uri.parse('https://raw.githubusercontent.com/uchidalab/book-dataset/master/Task1/book30-listing-train.csv')) // produces a request object
    .then((request) => request.close()) // sends the request
    .then((HttpClientResponse response) {
          response.transform(utf8.decoder).transform(new LineSplitter()).listen(
		(line) {
      List<String> ll = line.split(',');
      _imagesToLabel.add(ll[2]);
      },
		onError:(err) => print('my bad $err')
	  );
      },
    );  
  }


  void increment() {
    // First, increment the counter
    _counter++;

    _url = _imagesToLabel[_counter];

    // Then notify all the listeners.
    notifyListeners();
  }
}

class CounterHome extends StatelessWidget {
  final String title;

  CounterHome(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            // Create a ScopedModelDescendant. This widget will get the
            // CounterModel from the nearest parent ScopedModel<CounterModel>.
            // It will hand that CounterModel to our builder method, and
            // rebuild any time the CounterModel changes (i.e. after we
            // `notifyListeners` in the Model).
            ScopedModelDescendant<CounterModel>(
              builder: (context, child, model) {
                return Text(
                  model.counter.toString(),
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
	    ScopedModelDescendant<CounterModel>(
              builder: (context, child, model) {
                String imageUrl = model.urlget.toString();
                imageUrl = imageUrl.substring(1,imageUrl.length-1);
                return new Image.network(imageUrl);
	            },
	    ),

          ],
        ),
      ),
      // Use the ScopedModelDescendant again in order to use the increment
      // method from the CounterModel
      floatingActionButton: ScopedModelDescendant<CounterModel>(
        builder: (context, child, model) {
          return FloatingActionButton(
            onPressed: model.increment,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
