import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:battery_info/battery_info_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sprintf/sprintf.dart';
import 'package:call_log/call_log.dart';
import '../data/task.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime _dateTime = DateTime.now();
  late Timer _timer;
  final day = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final mon = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  int _battery = 0;
  int fromSpecal = 0;
  bool fromOther = false;
  bool fromFrind = false;
  List<String> spetial = ["XXXXXXX"];
  List<Task> taskData = [];
  List<Map<String, dynamic>> CodeChefTask = [];
  List<String> friends = ["XXXXXXXX"];
  late Database db;
  @override
  void initState() {
    _updateTimer();
    _missCall();
    openDatabase(
      "contact.db",
      version: 1,
      onCreate: (Database contactdb, int version) async {
        await contactdb.execute(
            'CREATE TABLE Contact (id INTEGER PRIMARY KEY, no TEXT,spetial BOOLEAN)');
        // await contactdb
        //     .insert("Contact", {"id": 1, "no": "XXXXXXXXXX", "spetial": false});
      },
    ).then((contactdb) {
      contactdb.query("Contact", where: "id = ?", whereArgs: [1]).then((value) {
        if (value.isNotEmpty) {
          for (var i in value) {
            bool isSpeatal = i["spetial"] as bool;
            if (isSpeatal) {
              spetial.add(i["no"] as String);
            } else {
              friends.add(i["no"] as String);
            }
          }
        }
      });
    });
    openDatabase("task_db.db", version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Task_table (id INTEGER PRIMARY KEY, data TEXT)');
      await db.insert("Task_table", {"id": 1, "data": ""});
    }).then((value) {
      db = value;
      db.query("Task_table", where: "id = ?", whereArgs: [1]).then((value) {
        if (value.isNotEmpty && (value.first["data"] as String).isNotEmpty) {
          var temData =
              (jsonDecode(value.first["data"] as String)["data"] as List)
                  .map((e) => Task.fromJson(e as Map<String, dynamic>))
                  .toList();
          setState(() {
            taskData = temData;
          });
        }
      });
    });
    http
        .get(Uri.parse('https://www.codechef.com/api/list/contests/all'))
        .then((value) {
      if (value.statusCode == 200) {
        Map data = jsonDecode(value.body);
        List<Map<String, dynamic>> future =
            List<Map<String, dynamic>>.from(data["future_contests"]);
        List<Map<String, dynamic>> current =
            List<Map<String, dynamic>>.from(data["present_contests"]);
        debugPrint(current.toString());
        debugPrint(future.toString());
        setState(() {
          CodeChefTask.addAll(future);
          CodeChefTask.addAll(current);
        });
      }
    });
    // SharedPreferences.setMockInitialValues({});
    // print(jsonDecode(storage.getItem("data")));
    // taskData = storage.getItem("data") != null
    //     ? jsonDecode(storage.getItem("data"))["data"]
    //     : taskData;
    // SharedPreferences.getInstance().then((value) {
    //   setState(() {
    //     pref = value;
    //     print("op");
    //     if (pref.containsKey("data")) {
    //       var temp = jsonDecode(pref.getString("data")!);
    //       print(temp);
    //       taskData = temp["data"];
    //     }
    //   });
    // });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    db.close();
    super.dispose();
  }

  void _missCall() async {
    var now = DateTime.now();

    CallLog.query(
            type: CallType.missed,
            dateFrom: now.subtract(Duration(hours: 2)).microsecondsSinceEpoch)
        .then((value) => {
              setState(() {
                fromSpecal = 0;
                for (var element in value) {
                  var number = element.number!;
                  if (friends.contains(number) ||
                      friends.contains(number
                          .replaceFirst("+91", "")
                          .replaceFirst("91", ""))) {
                    fromFrind = true;
                  } else {
                    fromOther = true;
                  }

                  if (spetial.contains(number) ||
                      spetial.contains(number
                          .replaceFirst("+91", "")
                          .replaceFirst("91", ""))) {
                    fromSpecal++;
                  }
                }
              })
            });
  }

  void _updateTimer() async {
    var bt = await BatteryInfoPlugin().androidBatteryInfo;
    setState(() {
      _dateTime = DateTime.now();
      _battery = bt!.batteryLevel!;
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTimer,
      );
    });
  }

  _SpetialNo(
    BuildContext context,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        var text = "";
        bool isSpecial = false;
        List<Map> allPart = [];
        return StatefulBuilder(builder: (context, setState2) {
          // TextEditingController _textFieldController = TextEditingController();
          return AlertDialog(
            title: Text("Add Your Friends and Special"),
            content: Stack(
              children: [
                Column(children: [
                  TextField(
                    // controller: _textFieldController,
                    onChanged: (value) {
                      setState2(() {
                        text = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Enter No (Select For Special)",
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        value: isSpecial,
                        onChanged: (bool? value) {
                          setState2(() {
                            isSpecial = value!;
                          });
                        },
                      ),
                      TextButton(
                          onPressed: () {
                            setState2(
                              () {
                                allPart
                                    .add({"no": text, "isSpecial": isSpecial});
                              },
                            );
                          },
                          child: Text("Add"))
                    ],
                  ),
                  for (var i in allPart)
                    Row(
                      children: [
                        Text(i["no"]),
                        if (i["isSpecial"])
                          IconButton(
                              onPressed: () {
                                int k = allPart.indexOf(i);
                                setState2(() {
                                  allPart[k]["isSpecial"] =
                                      !allPart[k]["isSpecial"];
                                });
                              },
                              icon: Icon(Icons.star))
                      ],
                    )
                ]),
                Positioned(
                  right: 30,
                  bottom: 20,
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      openDatabase("contact.db").then((mydb) async {
                        await mydb.delete("Contact");
                        for (var i in allPart) {
                          mydb.insert("Contact",
                              {"spetial": i["isSpecial"], "no": i["no"]});
                          if (i["isSpecial"]) {
                            spetial.add(i["no"]);
                          } else {
                            friends.add(i["no"]);
                          }
                        }
                        setState(() {});
                      });

                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  _displayDialog(
    BuildContext context,
  ) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            TextEditingController _textFieldController =
                TextEditingController();
            bool isTask = false;
            bool isCompleated = false;
            return AlertDialog(
              title: Text('Enter Your task'),
              content: Column(
                children: [
                  TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(hintText: "Enter Text"),
                  ),
                  Row(
                    children: [
                      Text(
                        "Is Task",
                        style: TextStyle(color: Colors.black),
                      ),
                      Checkbox(
                        checkColor: Colors.white,
                        value: isTask,
                        onChanged: (bool? value) {
                          setState(() {
                            isTask = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Is Completed",
                        style: TextStyle(color: Colors.black),
                      ),
                      Checkbox(
                        checkColor: Colors.white,
                        value: isCompleated,
                        onChanged: (bool? value) {
                          setState(() {
                            isCompleated = value!;
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('SUBMIT'),
                  onPressed: () {
                    List<Map> newData = [];
                    for (var taskI in taskData) {
                      newData.add(taskI.toJson());
                    }
                    newData.add(Task(_textFieldController.text, isTask,
                            isCompleated, newData.isEmpty)
                        .toJson());
                    // storage.setItem("data", );
                    var data = {
                      "data": json.encode({"data": newData}) as String
                    };

                    print("\n1\n2\n3\n");
                    print(data["data"]);
                    db.update("Task_table", data, where: "id = ?", whereArgs: [
                      1
                    ]).then((value) => print("Some Out $value"));
                    setState(() {
                      taskData.add(
                          Task.fromJson(newData.last as Map<String, dynamic>));
                    });
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 46.h,
        ),
        GestureDetector(
          onLongPress: () {
            _displayDialog(context);
          },
          child: Text(
            "${sprintf("%02d", [
                  _dateTime.hour > 12 ? _dateTime.hour - 12 : _dateTime.hour
                ])}:${sprintf("%02d", [_dateTime.minute])}",
            style: TextStyle(
                fontFamily: "Inter",
                fontSize: 53.sp,
                color: Colors.white,
                decoration: TextDecoration.none),
          ),
        ),
        Text(
          "${day[_dateTime.weekday - 1]} ${_dateTime.day} ${mon[_dateTime.month - 1]} ${_dateTime.year - 2000}",
          style: TextStyle(
              color: Colors.white,
              fontSize: 27.sp,
              fontFamily: "Inter",
              decoration: TextDecoration.none),
        ),
        SizedBox(
          height: 30.h,
        ),
        Text(
          "Ram Ram",
          style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontFamily: "Itim",
              fontSize: 22.sp),
        ),
        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: SizedBox(
            height: 500.h,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (var i in CodeChefTask) CodeChef(data: i),
                for (var i in taskData)
                  GestureDetector(
                    onDoubleTap: () {
                      List<Map> newData = [];

                      for (var taskI in taskData) {
                        if (taskI.name == i.name) {
                          continue;
                        }
                        newData.add(taskI.toJson());
                      }

                      // storage.setItem("data", json.encode({"data": newData}));
                      db.update("Task_table", {
                        "id": 1,
                        "data": json.encode({"data": newData})
                      });
                      setState(() {
                        taskData.remove(i);
                      });
                    },
                    onTap: () {
                      List<Map> newData = [];
                      for (var taskI in taskData) {
                        if (taskI.name == i.name) {
                          taskI.taskStatus = !taskI.taskStatus;
                          taskData[taskData.indexOf(taskI)] = taskI;
                        }
                        newData.add(taskI.toJson());
                      }

                      // storage.setItem("data", json.encode({"data": newData}));
                      db.update("Task_table", {
                        "id": 1,
                        "data": json.encode({"data": newData})
                      });
                      setState(() {});
                    },
                    child: TaskList(
                        task: Task(i.name, i.isTask, i.taskStatus,
                            i == taskData.first)),
                  ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: (68).r,
              width: (68).r,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular((68).r)),
              child: Center(
                  child: Text(
                "$_battery%",
                style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontSize: 20.sp),
              )

                  // StreamBuilder<AndroidBatteryInfo?>(
                  //     stream: ,
                  //     builder: (context, snapshot) {
                  //       if (snapshot.hasData) {

                  //       }
                  //       return CircularProgressIndicator();
                  //     }),
                  ),
            ),
            GestureDetector(
              onLongPress: () {
                _SpetialNo(context);
              },
              child: Container(
                height: (68).r,
                width: (68).r,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular((68).r)),
                child: Center(
                  child: Text(
                    "$fromSpecal",
                    style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontSize: 20.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Center(
            child: Column(children: [
              if (fromFrind)
                Text(
                  "Friends Miss-call",
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 15.sp),
                ),
              if (fromOther)
                Text(
                  "Unknown Miss-call",
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 15.sp),
                )
            ]),
          ),
        )
      ],
    );
  }
}

class TaskList extends StatelessWidget {
  TaskList({Key? key, required this.task}) : super(key: key);
  Task task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: task.frist ? 0 : 9.h, left: 6.w),
      child: Row(
        children: [
          Text(
            task.name,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                decoration: TextDecoration.none),
          ),
          task.isTask
              ? Icon(
                  task.taskStatus ? Icons.check : Icons.close,
                  color: Colors.white,
                )
              : Container()
        ],
      ),
    );
  }
}

class CodeChef extends StatelessWidget {
  CodeChef({Key? key, required this.data}) : super(key: key);
  Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int startIn = -now
        .difference(DateTime.parse(data["contest_start_date_iso"]!))
        .inMinutes;
    int endingIn = -now
        .difference(DateTime.parse(data["contest_end_date_iso"]!))
        .inMinutes;

    return Column(
      children: [
        Text(
          data["contest_name"]!,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              decoration: TextDecoration.none),
        ),
        Text(
          "Start in ${startIn > 60 ? (startIn / 60).floor() : 0}:${startIn > 60 ? (startIn % 60) : startIn} and Ending in ${endingIn > 60 ? (endingIn / 60).floor() : 0}:${endingIn > 60 ? (endingIn % 60) : endingIn}",
          style: TextStyle(
            color: (startIn < 0 && endingIn > 0) ? Colors.red : Colors.white,
            fontSize: 12.sp,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
