import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'model/task.dart';
import 'model/token.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.title});

  final String title;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Box<Task> tasksBox;
  late Future<List<Task>> _tasks;

  // late Box<Token> tokenBox;

  @override
  void initState() {
    super.initState();
    tasksBox = Hive.box<Task>('taskBox');
    // tokenBox = Hive.box<Token>('tokenBox');
    try {
      _tasks = getTasks();
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Text('No tasks found'),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Return'),
                      ),
                    ],
                  )),
            );
          });
    }
  }

  // final dio = Dio(BaseOptions(
  //     baseUrl: 'https://test-mobile.estesis.tech/api/v1',
  //     headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       HttpHeaders.acceptHeader: 'application/json',
  //       HttpHeaders.authorizationHeader: 'Basic ${Hive.box<Token>('tokenBox').getAt(0)?.accessToken}'
  //     }
  // ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () => {},
                icon: const Icon(
                  Icons.add,
                  size: 35,
                ))
          ],
        ),
        body: buildColumn());
    //(_futureToken == null) ? buildColumn() : buildFutureBuilder());
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              SearchBar(
                shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surface),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary))),
                hintText: 'Search',
                leading: const Icon(
                  Icons.search,
                  size: 35,
                ),
              ),
              const SizedBox(height: 40),
              EasyDateTimeLine(
                initialDate: DateTime.now(),
                headerProps: const EasyHeaderProps(
                    selectedDateStyle:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                    dateFormatter: DateFormatter.custom('dd MMMM'),
                    monthPickerType: MonthPickerType.switcher),
                dayProps: const EasyDayProps(
                    height: 118,
                    width: 64,
                    dayStructure: DayStructure.dayNumDayStr,
                    todayStyle: DayStyle(
                        dayNumStyle:
                            TextStyle(color: Colors.black, fontSize: 25),
                        dayStrStyle:
                            TextStyle(color: Colors.black, fontSize: 14)),
                    activeDayStyle: DayStyle(
                        dayNumStyle:
                            TextStyle(color: Colors.white, fontSize: 25),
                        dayStrStyle:
                            TextStyle(color: Colors.white, fontSize: 14)),
                    inactiveDayStyle: DayStyle(
                        dayNumStyle: TextStyle(
                            color: Color.fromRGBO(132, 138, 148, 1),
                            fontSize: 25),
                        dayStrStyle: TextStyle(
                            color: Color.fromRGBO(132, 138, 148, 1),
                            fontSize: 14))),
              ),
              ValueListenableBuilder<Box<Task>>(
                valueListenable: tasksBox.listenable(),
                builder:
                    (BuildContext context, Box<Task> value, Widget? child) {
                  return buildFutureBuilder();
                    // tasksBox.isEmpty
                    //   ? const Text('No tasks found')
                    //   : RefreshIndicator(
                    //       child: ListView.builder(
                    //           shrinkWrap: true,
                    //           physics: const AlwaysScrollableScrollPhysics(),
                    //           itemCount: tasksBox.length,
                    //           itemBuilder: (context, listIndex) {
                    //             return Card(
                    //               color: Theme.of(context).colorScheme.surface,
                    //               shadowColor: Colors.transparent,
                    //               shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(15),
                    //                   side: const BorderSide(
                    //                       color: Color.fromRGBO(
                    //                           233, 241, 255, 1))),
                    //               child: Column(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 children: [
                    //                   Row(
                    //                     children: [
                    //                       Checkbox(
                    //                         value: true,
                    //                         onChanged: (bool? value) {},
                    //                       ),
                    //                       // const Text('Text text text')
                    //                       Text(tasksBox.getAt(listIndex)!.title)
                    //                     ],
                    //                   ),
                    //                   Row(
                    //                     children: [
                    //                       const Chip(label: Text('tag text')),
                    //                       Text(DateFormat('dd MMMM HH:mm')
                    //                           .format(DateTime.now()))
                    //                     ],
                    //                   )
                    //                 ],
                    //               ),
                    //             );
                    //           }),
                    //       onRefresh: () {
                    //         return Future.delayed(const Duration(seconds: 1), () {
                    //           setState(() {
                    //             _tasks = getTasks();
                    //           });
                    //         });
                    //       });
                },
              )
            ]))
      ],
    );
  }

  Future<List<Task>> getTasks(
      {String? maxCreatedDate, String? minCreatedDate}) async {
    List<Task> tasks;
    FlutterSecureStorage storage = const FlutterSecureStorage();
    Response<dynamic> response;
    var token = await storage.read(key: 'access_token');
    var dio = Dio(BaseOptions(
        baseUrl: 'https://test-mobile.estesis.tech/api/v1',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        }));
    try {
      response = await dio.get(
        '/tasks',
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        tasks = (response.data['items'] as List)
            .map((i) => Task.fromJson(i))
            .toList();
        // if (tasksBox.isNotEmpty) {
        //   tasksBox.clear();
        // }
        // tasksBox.addAll(tasks);
        return tasks;
      } else {
        throw Exception('Tasks not found!');
      }
    } catch (e) {
      rethrow;
    }
  }

  FutureBuilder<List<Task>> buildFutureBuilder() {
    return FutureBuilder<List<Task>>(
      future: _tasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, listIndex) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
                  color: Theme.of(context).colorScheme.surface,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                          color: Color.fromRGBO(
                              233, 241, 255, 1))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (bool? value) {
                              //TODO implement task completion
                            },
                          ),
                          // const Text('Text text text')
                          Text(snapshot.data!.elementAt(listIndex).title,
                          style: const TextStyle(
                            fontSize: 16
                          ),)
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sell_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 15,
                              ),
                              const SizedBox(width: 5,),
                              Text(snapshot.data!.elementAt(listIndex).tag.name,
                              style: const TextStyle(
                                color: Color.fromRGBO(141, 141, 141, 1),
                              ),),
                              // const Chip(label: Text('tag text')),
                              const SizedBox(width: 10,),
                              Text(DateFormat('dd MMMM HH:mm')
                                  .format(snapshot.data!.elementAt(listIndex).createdAt),
                              style: const TextStyle(
                                color: Color.fromRGBO(254, 181, 189, 1)
                              ),),
                            ],
                          )
                      )
                    ],
                  ),
                );
              });
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
