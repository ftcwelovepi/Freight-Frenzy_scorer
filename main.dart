import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'dart:developer';
import 'dart:async';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test_app/dbhelper.dart';
import 'dart:convert';
import 'dart:math';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner

      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Center(
              child: Text(
            "Test Change",
            style: TextStyle(color: Colors.white),
          )),
          backgroundColor: Colors.red.shade900,
        ),
        body: new Column(
          children: [
            new Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Score New Round",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                new IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (contexttxt) => new ScorerPage(),
                          ));
                    },
                    icon: const Icon(Icons.add, color: Colors.white))
              ],
            ),
            new Row(
              children: [
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("View my Rounds",
                        style: TextStyle(color: Colors.white, fontSize: 16))),
                new IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (contexttxt) => new StoragePage(),
                          ));
                    },
                    icon: const Icon(Icons.add, color: Colors.white))
              ],
            )
          ],
        ));
  }
}

class StoragePage extends StatefulWidget {
  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  String title = "My Saved Rounds";
  var rounds = [];
  var titles = [];
  var auto = [];
  var driver = [];
  var endGame = [];
  void _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final test = prefs.getKeys();
      print(test);
      for (String key in test) {
        rounds.add(jsonDecode(prefs.get(key).toString())['score']);
        titles.add(jsonDecode(prefs.get(key).toString())['title']);
        auto.add(jsonDecode(prefs.get(key).toString())['autonomous']);
        driver.add(jsonDecode(prefs.get(key).toString())['driverControl']);
        endGame.add(jsonDecode(prefs.get(key).toString())['endGame']);
      }
      // title = rounds.toString();
      print(title);
    });
  }

  Widget listToWidget() {
    List<Widget> list = [];
    list.add(new Row(children: [
      Padding(
          padding: EdgeInsets.all(15.0),
          child: Text("Title",
              style: TextStyle(color: Colors.white, fontSize: 18))),
      Padding(
          padding: EdgeInsets.all(15.0),
          child: Text("Score",
              style: TextStyle(color: Colors.white, fontSize: 18))),
      Padding(
          padding: EdgeInsets.all(15.0),
          child: Text("Autonomous",
              style: TextStyle(color: Colors.white, fontSize: 18))),
      Padding(
          padding: EdgeInsets.all(15.0),
          child: Text("Driver Control",
              style: TextStyle(color: Colors.white, fontSize: 18))),
      Padding(
          padding: EdgeInsets.all(15.0),
          child: Text("End Game",
              style: TextStyle(color: Colors.white, fontSize: 18)))
    ]));
    for (int i = 0; i < rounds.length; i++) {
      list.add(new Row(children: [
        Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(titles[i].toString(),
                style: TextStyle(color: Colors.white, fontSize: 18))),
        Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(rounds[i].toString(),
                style: TextStyle(color: Colors.white, fontSize: 18))),
        Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(auto[i].toString(),
                style: TextStyle(color: Colors.white, fontSize: 18))),
        Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(driver[i].toString(),
                style: TextStyle(color: Colors.white, fontSize: 18))),
        Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(endGame[i].toString(),
                style: TextStyle(color: Colors.white, fontSize: 18)))
      ]));
    }
    return new ListView(children: list);
  }

  void initState() {
    super.initState();
    _loadScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(title, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade900,
          centerTitle: true,
        ),
        body: listToWidget());
  }
}

class ScorerPage extends StatefulWidget {
  @override
  _ScorerPageState createState() => _ScorerPageState();
}

class _ScorerPageState extends State<ScorerPage> {
  // final dbhelper = DBHelper.instance;
  TextEditingController _textFieldController = TextEditingController();
  bool exit = false;
  String _title = 'Score: 0';
  String _auto = 'Autonomous Period: 0';
  var currVals = [0, 0, 0, 0, 0, 0, 0, 0];
  num Score = 0;
  var sections = [4, 9, 14]
  num autoScore = 0;
  Object val = 0;
  Object val2 = 0;
  Object val3 = 0;
  var scores = <num>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  var weights = <num>[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
  var sectionTitles = <String>[
    "Autonomous Period: 0",
    "Driver Control Period: 0",
    "End Game: 0"
  ];
  String roundTitle = "";
  Round currRound = new Round(
      title: "test title",
      score: 0,
      autonomous: 0,
      driverControl: 0,
      endGame: 0);
  int roundID = new Random().nextInt(100000);
  // void insertData() async {
  //   Map<String, dynamic> row = {
  //     DBHelper.columnName: "Round 1",
  //     DBHelper.columnScore: 100,
  //   };
  //   final id = await dbhelper.insert(row);
  //   print(id);
  // }

  void saveRound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currRound.title = roundTitle;
      currRound.score = Score.toInt();
      currRound.autonomous = sections[0].toInt();
      currRound.driverControl = sections[1].toInt();
      currRound.endGame = sections[2].toInt();
      Map jsonRound = currRound.toMap();
      String round = jsonEncode(jsonRound);
      prefs.setString(roundID.toString(), round);
      prefs.reload();
    });
  }

  void _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final test = prefs.getString(roundID.toString());
      print(test);
      _title = test.toString();
      print(_title);
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Name Your Round Before Saving'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Round Name"),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  Text('CANCEL', style: TextStyle(color: Colors.red.shade900)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.red.shade900)),
              onPressed: () async {
                roundTitle = _textFieldController.text;

                Navigator.pop(context);
                exit = true;
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Center(
            child: Text(_title, style: TextStyle(fontWeight: FontWeight.bold))),
        backgroundColor: Colors.red.shade900,
        actions: [
          TextButton(
              onPressed: () async {
                await _displayTextInputDialog(context);
                if (exit) {
                  saveRound();
                  Navigator.pop(context);
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.white)))
        ],
      ),
      // the TextField widget lets the user enter text in
      body: SingleChildScrollView(
          child: new Column(children: <Widget>[
        new Padding(
          padding:
              EdgeInsets.only(top: 15.0, left: 10.0, bottom: 10.0, right: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitles[0],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textScaleFactor: 2,
              )
            ],
          ),
        ),
        new CheckDiv(
          text: "Delivered Duck via Carousel",
          weight: 10,
          callback: (int val) {
            updateSection(val, 0);
            updateTitle(val);
          },
        ),
        new Div(
          title: "Freight in Storage Unit: ",
          callback: (int val) {
            updateSection(val, 1);
            updateTitle(val);
          },
          weight: 2,
        ),
        new Div(
            title: "Freight on Shipping Hub: ",
            callback: (int val) {
              updateSection(val, 2);
              updateTitle(val);
            },
            weight: 3),
        new Row(
          children: [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Parking",
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.5,
                ))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white,
              ),
              child: Column(children: [
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("In Alliance Storage Unit",
                        style: TextStyle(color: Colors.white)),
                    value: 3,
                    groupValue: val,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val, 3);
                          updateTitle2(val);
                          val = value;
                          updateTitle(val);
                          updateSection(val, 3);
                        });
                      }
                    }),
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("Completely in Alliance Storage Unit",
                        style: TextStyle(color: Colors.white)),
                    value: 6,
                    groupValue: val,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val, 4);
                          updateTitle2(val);
                          val = value;
                          updateTitle(val);
                          updateSection(val, 4);
                        });
                      }
                    }),
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("In Warehouse",
                        style: TextStyle(color: Colors.white)),
                    value: 5,
                    groupValue: val,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val, 5);
                          updateTitle2(val);
                          val = value;
                          updateTitle(val);
                          updateSection(val, 5);
                        });
                      }
                    }),
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("Completely in Warehouse",
                        style: TextStyle(color: Colors.white)),
                    value: 10,
                    groupValue: val,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val, 6);
                          updateTitle2(val);
                          val = value;
                          updateTitle(val);
                          updateSection(val, 6);
                        });
                      }
                    }),
              ]),
            )),
        new Row(
          children: [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Shupping Hub Level Bonus",
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.5,
                ))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white,
              ),
              child: Column(children: [
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("Duck", style: TextStyle(color: Colors.white)),
                    value: 10,
                    groupValue: val3,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val3, 7);
                          updateTitle2(val3);
                          val3 = value;
                          updateTitle(val3);
                          updateSection(val3, 7);
                        });
                      }
                    }),
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("Team Shipping Element",
                        style: TextStyle(color: Colors.white)),
                    value: 20,
                    groupValue: val3,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val3, 8);
                          updateTitle2(val3);
                          val3 = value;
                          updateTitle(val3);
                          updateSection(val3, 8);
                        });
                      }
                    }),
              ]),
            )),
        new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitles[1],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textScaleFactor: 2,
              )
            ],
          ),
        ),
        new Div(
          title: "Freight in Storage Unit: ",
          callback: (int val) {
            updateSection(val, 9);
            updateTitle(val);
          },
          weight: 1,
        ),
        new Row(
          children: [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Freight in Alliance Shipping Hub",
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.5,
                ))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: [
                new Div(
                  title: "Level 1: ",
                  callback: (int val) {
                    updateSection(val, 10);
                    updateTitle(val);
                  },
                  weight: 2,
                ),
                new Div(
                  title: "Level 2: ",
                  callback: (int val) {
                    updateSection(val, 11);
                    updateTitle(val);
                  },
                  weight: 4,
                ),
                new Div(
                  title: "Level 3: ",
                  callback: (int val) {
                    updateSection(val, 12);
                    updateTitle(val);
                  },
                  weight: 6,
                ),
              ],
            )),
        new Div(
          title: "Freight on Shared Shipping Hub: ",
          callback: (int val) {
            updateSection(val, 1);
            updateTitle(val);
          },
          weight: 4,
        ),
        new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitles[2],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textScaleFactor: 2,
              )
            ],
          ),
        ),
        new Div(
          title: "Ducks/Elements delivered via Carousel: ",
          callback: (int val) {
            updateSection(val, 13);
            updateTitle(val);
          },
          weight: 6,
        ),
        new Row(
          children: [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Alliance Shipping Hub",
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.5,
                ))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: [
                new CheckDiv(
                  text: "Balanced",
                  weight: 10,
                  callback: (int val) {
                    updateSection(val, 14);
                    updateTitle(val);
                  },
                ),
                new CheckDiv(
                  text: "Capped",
                  weight: 15,
                  callback: (int val) {
                    updateSection(val, 15);
                    updateTitle(val);
                  },
                ),
              ],
            )),
        new Row(
          children: [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Shared Shipping Hub",
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.5,
                ))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: [
                new CheckDiv(
                  text: "Tipped Towards Alliance",
                  weight: 20,
                  callback: (int val) {
                    updateSection(val, 16);
                    updateTitle(val);
                  },
                ),
              ],
            )),
        new Row(
          children: [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Parking",
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.5,
                ))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white,
              ),
              child: Column(children: [
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("In a Warehouse",
                        style: TextStyle(color: Colors.white)),
                    value: 3,
                    groupValue: val2,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val2, 17);
                          updateTitle2(val2);
                          val2 = value;
                          updateTitle(val2);
                          updateSection(val2, 17);
                        });
                      }
                    }),
                RadioListTile(
                    activeColor: Colors.red.shade900,
                    title: Text("Completely in a Warehouse",
                        style: TextStyle(color: Colors.white)),
                    value: 6,
                    groupValue: val2,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          updateSection2(val2, 18);
                          updateTitle2(val2);
                          val2 = value;
                          updateTitle(val2);
                          updateSection(val2, 19);
                        });
                      }
                    }),
              ]),
            )),
        new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Comments",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textScaleFactor: 2,
              )
            ],
          ),
        ),
        SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              new TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ),
              new TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ),
              new TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ),
              new TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ), // your body code
            ],
          ),
        ),
      ])),
    );
  }

  void calculateScores(x, y){
    counter = 0;
    for( var i = x; i <= y; i++ ) {
      counter += weights[i];
    }
    return counter;
  }
  void updateSection(val, section) { //really update scores
    setState(() {
      if (scores[section] + 1 >= 0) {
        scores[section] += 1;
      }
      if ((section >= 0)&(section <=sections[0])) {
        sectionTitles[section] =
            "Autonomous Period: " + calculateScores(0,sections[0]).toString();
      }

      if ((section <= sections[1])&(sections >= sections[0])) {
        sectionTitles[section] =
            "Driver Control Period: " + calculateScores(sections[0],sections[1]).toString();
      }

      if ((section <= sections[2])&(sections >= sections[1])) {
        sectionTitles[section] = "End Game: " + calculateScores(sections[1],sections[2]).toString();
      }
    });
  }

  void updateSection2(val, section) {
    setState(() {
      if (scores[section] - 1 >= 0) {
        scores[section] -= 1;
      }

      if ((section >= 0)&(section <=sections[0])) {
        sectionTitles[0] =
            "Autonomous Period: " + calculateScores(0,sections[0]).toString();
      }

      if ((section <= sections[1])&(sections >= sections[0])) {
        sectionTitles[1] =
            "Driver Control Period: " + calculateScores(sections[0],sections[1]).toString();
      }

      if ((section <= sections[2])&(sections >= sections[1])) {
        sectionTitles[2] = "End Game: " + calculateScores(sections[1],sections[2]).toString();
      }
    });
  }

  void updateTitle2(val) {
    setState(() {
      if (Score - val >= 0) {
        Score -= val;
      }

      _title = "Score: " + Score.toString();
    });
  }

  void updateTitle(val) {
    setState(() {
      if (Score + val >= 0) {
        Score += val;
      }

      _title = "Score: " + Score.toString();
    });
  }
}

class Div extends StatefulWidget {
  final IntCallBack callback;
  final int weight;
  final String title;
  Div({required this.callback, required this.weight, required this.title});
  @override
  _DivState createState() =>
      _DivState(callback: callback, weight: weight, title: title);
}

typedef void IntCallBack(int val);

class _DivState extends State<Div> {
  final IntCallBack callback;
  final int weight;
  final String title;
  _DivState(
      {required this.callback, required this.weight, required this.title});

  int val = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 15.0),
        color: Colors.transparent,
        child: new Row(children: <Widget>[
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
          Ink(
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  val++;
                });
                callback(weight);
              },
            ),
          ),
          Text(val.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Ink(
            child: IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (val > 0) {
                      val--;
                    }
                  });
                  callback(-1 * weight);
                }),
          )
        ]));
  }
}

class CheckDiv extends StatefulWidget {
  final IntCallBack callback;
  final int weight;
  final String text;
  CheckDiv({required this.weight, required this.callback, required this.text});
  @override
  _CheckDivState createState() =>
      _CheckDivState(weight: weight, callback: callback, text: text);
}

class _CheckDivState extends State<CheckDiv> {
  final int weight;
  final IntCallBack callback;
  final String text;
  _CheckDivState(
      {required this.weight, required this.callback, required this.text});
  int val = 0;
  bool checkedValue = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.white,
            ),
            child: CheckboxListTile(
              checkColor: Colors.white,
              activeColor: Colors.red.shade900,
              title: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              value: checkedValue,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    checkedValue = newValue;
                    print(checkedValue);
                    if (checkedValue == false) {
                      callback(-1 * weight);
                    } else {
                      callback(weight);
                    }
                  });
                }
              },
            )));
  }
}

class Round {
  String title;
  int score;
  int autonomous;
  int driverControl;
  int endGame;
  Round(
      {required this.title,
      required this.score,
      required this.autonomous,
      required this.driverControl,
      required this.endGame});
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'score': score,
      'autonomous': autonomous,
      'driverControl': driverControl,
      'endGame': endGame,
    };
  }

  @override
  String toString() {
    return 'Round{score: $score}';
  }
}
