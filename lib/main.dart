import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

var url, url1;
double fontsize = 16;
var output;
var cmd;
var cmd1;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.wanderingCubes
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.blue
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Myhome(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: EasyLoading.init(),
    );
  }
}

class Myhome extends StatefulWidget {
  @override
  _MyhomeState createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  var urlController = TextEditingController();
  var cmdController = TextEditingController();
  CollectionReference data = FirebaseFirestore.instance.collection('output');
  RunCmd() async {
    print("run cmd");
    try {
      var data = await http.get("http://$url/cgi-bin/cmd.py?cmd=$cmd");

      output =
          "Status code: ${data.statusCode.toString()} \n\n Cmd: $cmd \n\n Output : \n${data.body.toString()}";
      cmd = null;
    } catch (e) {
      output = "Failed to run this command due to : \n\n $e";
    }

    print("hello in second");
    await FirebaseFirestore.instance
        .collection("output")
        .add({"output": output, "time": DateTime.now().millisecondsSinceEpoch})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Linux Command"),
        actions: [
          PopupMenuButton(
              child: Icon(Icons.settings_applications,
                  size: MediaQuery.of(context).size.height * 7 / 100),
              itemBuilder: (_) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 50 / 100,
                              decoration: BoxDecoration(
                                color: Colors.blue[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 3.0, 9.0, 3.0),
                                child: TextField(
                                  controller: urlController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: url == null ? "IP Adress" : url,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (txt) {
                                    url1 = txt;
                                  },
                                ),
                              ),
                            ),
                            FloatingActionButton(
                              heroTag: "set url",
                              onPressed: () {
                                setState(() {
                                  url = url1;
                                });

                                urlController.clear();
                              },
                              child: Icon(Icons.done),
                            )
                          ],
                        ),
                        value: 'Doge'),
                    new PopupMenuItem<String>(
                        child: Column(
                          children: [
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
                                child: Text("Font Size"),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  color: Colors.blue[200],
                                  child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          fontsize += 1;
                                        });
                                      },
                                      child: Icon(Icons.add)),
                                ),
                                Card(
                                  color: Colors.blue[200],
                                  child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          fontsize -= 1;
                                        });
                                      },
                                      child: Icon(Icons.remove)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        value: 'Lion'),
                  ],
              onSelected: (_) {}),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: data.orderBy('time', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return GestureDetector(
                onDoubleTap: () {
                  FirebaseFirestore.instance
                      .collection('output')
                      .doc(document.id)
                      .delete();
                },
                child: Column(
                  children: [
                    new Container(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    new Container(
                      child: new Text(
                        document.data()['output'],
                        style: TextStyle(fontSize: fontsize),
                      ),
                    ),
                    Row(children: [
                      Text(
                        "double tap to delete",
                        style: TextStyle(fontSize: 9),
                      )
                    ]),
                    new Container(
                      color: Colors.black,
                      height: 3,
                      child: Row(),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 80 / 100,
            decoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 3.0, 9.0, 3.0),
              child: TextField(
                controller: cmdController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Command",
                ),
                keyboardType: TextInputType.multiline,
                onChanged: (txt) {
                  cmd1 = txt;
                },
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "run cmd",
            onPressed: () {
              cmd = cmd1;
              EasyLoading.show(status: "Running Command");
              RunCmd();
              cmdController.clear();
            },
            child: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
