import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: 'Image Labeler Demo',
        home: CounterHome('Image Labeler Demo'),
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
    //Firestore db = Firestore.instance;
    //CollectionReference notesCollectionRef = db.collection('baby');
    //QuerySnapshot querySnapshot = await notesCollectionRef.getDocuments();
    //print(querySnapshot);
    //    print(notesCollectionRef.toString());
    print("** CounterModel printing ****");
    Firestore.instance.collection("baby").snapshots().listen((snapshot) 
    { snapshot.documents.forEach((doc) => debugPrint("debugger "+doc.data.toString()));
    });

    HttpClient()
    .getUrl(Uri.parse('https://raw.githubusercontent.com/uchidalab/book-dataset/master/Task1/book30-listing-train.csv')) // produces a request object
    .then((request) => request.close()) // sends the request
    .then((HttpClientResponse response) {
          response.transform(utf8.decoder).transform(new LineSplitter()).listen(
		(line) {
      List<String> ll = line.split(',');
      _imagesToLabel.add(ll[2]);
      },
		onError:(err) {print('my bad $err');print('duplicate my bad $err');},
	  );
      },
    );  
  }


  void increment() {
    // First, increment the counter
    _counter++;

    _url = _imagesToLabel[_counter];

    // add the image URL and dummy counter to collection\
    Map<String, Object> labeledImageRec = {
      'image_handle': _url,
      'votes':_counter,
    };
    Firestore.instance.collection("baby").add(labeledImageRec).then((doc) {
      print("check that new record added");
      doc.setData(labeledImageRec);
    });

    // Then notify all the listeners.
    notifyListeners();

  }


  void setCounterLabelDislike() {
    _url = _imagesToLabel[_counter];

    Map<String, Object> labeledImageRec = {
        'image_handle': _url,
        'vote':"Dislike",
    };

    Firestore.instance.collection("labeledSet").add(labeledImageRec).then((doc) {
      print("check that new record added");
      doc.setData(labeledImageRec);
    });

    _counter++;

    notifyListeners();

  }

    void setCounterLabelLike() {
    _url = _imagesToLabel[_counter];

    Map<String, Object> labeledImageRec = {
        'image_handle': _url,
        'vote':"Like",
    };

    Firestore.instance.collection("labeledSet").add(labeledImageRec).then((doc) {
      print("check that new record added");
      doc.setData(labeledImageRec);
    });

    _counter++;

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

     // adding a comment to fool git
      floatingActionButton: Row( 
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget> [
         new ScopedModelDescendant<CounterModel>(
           builder: (context,child,model){
            return FloatingActionButton(
                  onPressed: model.setCounterLabelDislike,
                  tooltip: 'Dislike',
                  child: new Icon(Icons.trending_down),
                );
           }
         ),
          new ScopedModelDescendant<CounterModel>(
            builder: (context,child,model){
            return FloatingActionButton(
                onPressed: model.setCounterLabelLike,
                tooltip: 'Like',
                child: new Icon(Icons.trending_up),
            );
            }
          )          
        ]
      ),  
    );
  }
}
