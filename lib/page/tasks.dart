import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project1/api/provider.dart';

import '../model/tag/tag.dart';
import '../model/task put/task_put.dart';
import '../model/task/task.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final tasks = ref.read(taskProvider);
    var taskData = ref.watch(taskProvider);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(title),
          actions: [
            IconButton(
                onPressed: () => {context.go('/add-task')},
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ))
          ],
        ),
        body: Consumer(builder: (context, ref, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    SearchBar(
                      shadowColor:
                          const WidgetStatePropertyAll(Colors.transparent),
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
                          selectedDateStyle: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w700),
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
                    taskData.when(
                        data: (data) => RefreshIndicator(
                            onRefresh: () => ref.refresh(taskProvider.future),
                            child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                clipBehavior: Clip.hardEdge,
                                shrinkWrap: true,
                                // physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (context, listIndex) {
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                          child: Row(children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  177, 209, 153, 1),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: const Color.fromRGBO(
                                                    254, 181, 189, 1),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                        ),
                                      ])),
                                      Slidable(
                                        key: Key(data.elementAt(listIndex).sid!),
                                        direction: Axis.horizontal,
                                        startActionPane: ActionPane(
                                            motion: const BehindMotion(),
                                            extentRatio: 0.3,
                                            children: [
                                              SlidableAction(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  autoClose: false,
                                                  icon: Icons.check,
                                                  onPressed: (context) {
                                                    TaskPutData upd = TaskPutData(
                                                        data.elementAt(listIndex).sid!,
                                                        data.elementAt(listIndex).title,
                                                        data.elementAt(listIndex).text,
                                                        data.elementAt(listIndex).isDone,
                                                        data.elementAt(listIndex).tag.sid);
                                                    upd.isDone = true;
                                                    ref.watch(taskProvider.notifier).completeTask(upd);
                                                  }),
                                            ]),
                                        endActionPane: ActionPane(
                                            motion: const BehindMotion(),
                                            extentRatio: 0.3,
                                            children: [
                                              SlidableAction(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  autoClose: false,
                                                  icon: Icons.delete_outline,
                                                  onPressed: (context) {}),
                                            ]),
                                        child: Builder(builder: (context) {
                                          SlidableController? controller =
                                              Slidable.of(context);
                                          return ValueListenableBuilder<int>(
                                              valueListenable:
                                                  controller?.direction ??
                                                      ValueNotifier<int>(0),
                                              builder: (context, value, _) {
                                                var borderRadius =
                                                    BorderRadius.horizontal(
                                                  right: Radius.circular(
                                                      value == -1 ? 15 : 0),
                                                  left: Radius.circular(
                                                      value == 1 ? 15 : 0),
                                                );
                                                return Container(
                                                    height: 80,
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .canvasColor,
                                                        borderRadius:
                                                            borderRadius,
                                                        // border: Border.all(
                                                        //     color: const Color.fromRGBO(
                                                        //         233, 241, 255, 1))
                                                    ),
                                                    child: ListTile(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    15),
                                                            // side: const BorderSide(
                                                            //     color: Color.fromRGBO(
                                                            //         233,
                                                            //         241,
                                                            //         255,
                                                            //         1))
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets.all(0),
                                                        title: Row(
                                                          children: [
                                                            Checkbox(
                                                              value: data.elementAt(listIndex).isDone,
                                                              onChanged: (bool?
                                                                  value) {
                                                                //TODO implement task completion
                                                              },
                                                            ),
                                                            Text(
                                                              data
                                                                  .elementAt(
                                                                      listIndex)
                                                                  .title,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            )
                                                          ],
                                                        ),
                                                        subtitle: Padding(
                                                            padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
                                                            child: Row(children: [
                                                              Icon(
                                                                Icons
                                                                    .sell_outlined,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                size: 15,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                data
                                                                    .elementAt(
                                                                        listIndex)
                                                                    .tag
                                                                    .name,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          141,
                                                                          141,
                                                                          141,
                                                                          1),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        'dd MMMM HH:mm')
                                                                    .format(data
                                                                        .elementAt(
                                                                            listIndex)
                                                                        .createdAt!),
                                                                style: const TextStyle(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            254,
                                                                            181,
                                                                            189,
                                                                            1)),
                                                              )
                                                            ]))));
                                              });
                                        }),
                                      )
                                    ],
                                  );
                                  // Dismissible(
                                  //   background: Container(
                                  //     decoration: BoxDecoration(
                                  //       borderRadius:
                                  //           BorderRadius.circular(15),
                                  //       color: const Color.fromRGBO(
                                  //           254, 181, 189, 1),
                                  //     ),
                                  //   ),
                                  //   key: Key(data.elementAt(listIndex).sid),
                                  //   child: ClipRRect(
                                  //     clipBehavior: Clip.antiAlias,
                                  //     borderRadius: BorderRadius.circular(15),
                                  //       child: ListTile(
                                  //         shape: RoundedRectangleBorder(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(15),
                                  //             side: const BorderSide(
                                  //                 color: Color.fromRGBO(
                                  //                     233, 241, 255, 1))),
                                  //         contentPadding:
                                  //             const EdgeInsets.all(0),
                                  //         title: Row(
                                  //           children: [
                                  //             Checkbox(
                                  //               value: true,
                                  //               onChanged: (bool? value) {
                                  //                 //TODO implement task completion
                                  //               },
                                  //             ),
                                  //             Text(
                                  //               data
                                  //                   .elementAt(listIndex)
                                  //                   .title,
                                  //               style: const TextStyle(
                                  //                   fontSize: 16),
                                  //             )
                                  //           ],
                                  //         ),
                                  //         subtitle: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 left: 50,
                                  //                 right: 50,
                                  //                 bottom: 20),
                                  //             child: Row(
                                  //               children: [
                                  //                 Icon(
                                  //                   Icons.sell_outlined,
                                  //                   color: Theme.of(context)
                                  //                       .colorScheme
                                  //                       .primary,
                                  //                   size: 15,
                                  //                 ),
                                  //                 const SizedBox(
                                  //                   width: 5,
                                  //                 ),
                                  //                 Text(
                                  //                   data
                                  //                       .elementAt(listIndex)
                                  //                       .tag
                                  //                       .name,
                                  //                   style: const TextStyle(
                                  //                     color: Color.fromRGBO(
                                  //                         141, 141, 141, 1),
                                  //                   ),
                                  //                 ),
                                  //                 const SizedBox(
                                  //                   width: 10,
                                  //                 ),
                                  //                 Text(
                                  //                   DateFormat(
                                  //                           'dd MMMM HH:mm')
                                  //                       .format(data
                                  //                           .elementAt(
                                  //                               listIndex)
                                  //                           .createdAt),
                                  //                   style: const TextStyle(
                                  //                       color: Color.fromRGBO(
                                  //                           254,
                                  //                           181,
                                  //                           189,
                                  //                           1)),
                                  //                 ),
                                  //               ],
                                  //             )),
                                  //       ))

                                  // Card(
                                  //   margin: const EdgeInsets.symmetric(
                                  //       vertical: 10, horizontal: 1),
                                  //   color: Theme.of(context)
                                  //       .colorScheme
                                  //       .surface,
                                  //   shadowColor: Colors.transparent,
                                  //   shape: RoundedRectangleBorder(
                                  //       borderRadius:
                                  //           BorderRadius.circular(15),
                                  //       side: const BorderSide(
                                  //           color: Color.fromRGBO(
                                  //               233, 241, 255, 1))),
                                  //   child: Column(
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     children: [
                                  //       Row(
                                  //         children: [
                                  //           Checkbox(
                                  //             value: true,
                                  //             onChanged: (bool? value) {
                                  //               //TODO implement task completion
                                  //             },
                                  //           ),
                                  //           Text(
                                  //             data
                                  //                 .elementAt(listIndex)
                                  //                 .title,
                                  //             style: const TextStyle(
                                  //                 fontSize: 16),
                                  //           )
                                  //         ],
                                  //       ),
                                  //       Padding(
                                  //           padding: const EdgeInsets.only(
                                  //               left: 50,
                                  //               right: 50,
                                  //               bottom: 20),
                                  //           child: Row(
                                  //             children: [
                                  //               Icon(
                                  //                 Icons.sell_outlined,
                                  //                 color: Theme.of(context)
                                  //                     .colorScheme
                                  //                     .primary,
                                  //                 size: 15,
                                  //               ),
                                  //               const SizedBox(
                                  //                 width: 5,
                                  //               ),
                                  //               Text(
                                  //                 data
                                  //                     .elementAt(listIndex)
                                  //                     .tag
                                  //                     .name,
                                  //                 style: const TextStyle(
                                  //                   color: Color.fromRGBO(
                                  //                       141, 141, 141, 1),
                                  //                 ),
                                  //               ),
                                  //               const SizedBox(
                                  //                 width: 10,
                                  //               ),
                                  //               Text(
                                  //                 DateFormat(
                                  //                         'dd MMMM HH:mm')
                                  //                     .format(data
                                  //                         .elementAt(
                                  //                             listIndex)
                                  //                         .createdAt),
                                  //                 style: const TextStyle(
                                  //                     color: Color.fromRGBO(
                                  //                         254,
                                  //                         181,
                                  //                         189,
                                  //                         1)),
                                  //               ),
                                  //             ],
                                  //           ))
                                  //     ],
                                  //   ),
                                  // )
                                  //);
                                })),
                        error: (error, stacktrace) => Text(error.toString()),
                        loading: () => const CircularProgressIndicator())
                  ]))
            ],
          );
        }));
  }

// Consumer buildColumn() {
//   return Consumer(builder: (context, ref, child) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(children: [
//               SearchBar(
//                 shadowColor: const WidgetStatePropertyAll(Colors.transparent),
//                 backgroundColor: WidgetStatePropertyAll(
//                     Theme.of(context).colorScheme.surface),
//                 shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     side: BorderSide(
//                         color: Theme.of(context).colorScheme.primary))),
//                 hintText: 'Search',
//                 leading: const Icon(
//                   Icons.search,
//                   size: 35,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               EasyDateTimeLine(
//                 initialDate: DateTime.now(),
//                 headerProps: const EasyHeaderProps(
//                     selectedDateStyle:
//                         TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
//                     dateFormatter: DateFormatter.custom('dd MMMM'),
//                     monthPickerType: MonthPickerType.switcher),
//                 dayProps: const EasyDayProps(
//                     height: 118,
//                     width: 64,
//                     dayStructure: DayStructure.dayNumDayStr,
//                     todayStyle: DayStyle(
//                         dayNumStyle:
//                             TextStyle(color: Colors.black, fontSize: 25),
//                         dayStrStyle:
//                             TextStyle(color: Colors.black, fontSize: 14)),
//                     activeDayStyle: DayStyle(
//                         dayNumStyle:
//                             TextStyle(color: Colors.white, fontSize: 25),
//                         dayStrStyle:
//                             TextStyle(color: Colors.white, fontSize: 14)),
//                     inactiveDayStyle: DayStyle(
//                         dayNumStyle: TextStyle(
//                             color: Color.fromRGBO(132, 138, 148, 1),
//                             fontSize: 25),
//                         dayStrStyle: TextStyle(
//                             color: Color.fromRGBO(132, 138, 148, 1),
//                             fontSize: 14))),
//               ),
//             ]))
//       ],
//     );
//   });
// }

// Future<List<Task>> getTasks(
//     {String? maxCreatedDate, String? minCreatedDate}) async {
//   List<Task> tasks;
//   FlutterSecureStorage storage = const FlutterSecureStorage();
//   Response<dynamic> response;
//   var token = await storage.read(key: 'access_token');
//   var dio = Dio(BaseOptions(
//       baseUrl: 'https://test-mobile.estesis.tech/api/v1',
//       headers: {
//         HttpHeaders.contentTypeHeader: 'application/json',
//         HttpHeaders.acceptHeader: 'application/json',
//         HttpHeaders.authorizationHeader: 'Bearer $token'
//       }));
//   try {
//     response = await dio.get(
//       '/tasks',
//     );
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       tasks = (response.data['items'] as List)
//           .map((i) => Task.fromJson(i))
//           .toList();
//       if (tasksBox.isEmpty) {
//         tasksBox.addAll(tasks);
//       }
//       return tasks;
//     } else {
//       throw Exception('Tasks not found!');
//     }
//   } catch (e) {
//     rethrow;
//   }
// }

// Future<List<Tag>> getTags() async {
//   List<Tag> tags;
//   FlutterSecureStorage storage = const FlutterSecureStorage();
//   Response<dynamic> response;
//   var token = await storage.read(key: 'access_token');
//   var dio = Dio(BaseOptions(
//       baseUrl: 'https://test-mobile.estesis.tech/api/v1',
//       headers: {
//         HttpHeaders.contentTypeHeader: 'application/json',
//         HttpHeaders.acceptHeader: 'application/json',
//         HttpHeaders.authorizationHeader: 'Bearer $token'
//       }));
//   try {
//     response = await dio.get(
//       '/tags',
//     );
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       tags = (response.data['items'] as List)
//           .map((i) => Tag.fromJson(i))
//           .toList();
//       if (tagsBox.isEmpty) {
//         tagsBox.addAll(tags);
//       }
//       return tags;
//     } else {
//       throw Exception('Tags not found!');
//     }
//   } catch (e) {
//     rethrow;
//   }
// }
//
// FutureBuilder<List<TaskData>> buildFutureBuilder() {
//   return FutureBuilder<List<TaskData>>(
//     future: _tasks,
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         return ListView.builder(
//             shrinkWrap: true,
//             physics: const AlwaysScrollableScrollPhysics(),
//             itemCount: snapshot.data?.length,
//             itemBuilder: (context, listIndex) {
//               return Card(
//                 margin:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
//                 color: Theme.of(context).colorScheme.surface,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     side: const BorderSide(
//                         color: Color.fromRGBO(233, 241, 255, 1))),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: true,
//                           onChanged: (bool? value) {
//                             //TODO implement task completion
//                           },
//                         ),
//                         // const Text('Text text text')
//                         Text(
//                           snapshot.data!.elementAt(listIndex).title,
//                           style: const TextStyle(fontSize: 16),
//                         )
//                       ],
//                     ),
//                     Padding(
//                         padding: const EdgeInsets.only(
//                             left: 50, right: 50, bottom: 20),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.sell_outlined,
//                               color: Theme.of(context).colorScheme.primary,
//                               size: 15,
//                             ),
//                             const SizedBox(
//                               width: 5,
//                             ),
//                             Text(
//                               snapshot.data!.elementAt(listIndex).tag.name,
//                               style: const TextStyle(
//                                 color: Color.fromRGBO(141, 141, 141, 1),
//                               ),
//                             ),
//                             // const Chip(label: Text('tag text')),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               DateFormat('dd MMMM HH:mm').format(snapshot
//                                   .data!
//                                   .elementAt(listIndex)
//                                   .createdAt),
//                               style: const TextStyle(
//                                   color: Color.fromRGBO(254, 181, 189, 1)),
//                             ),
//                           ],
//                         ))
//                   ],
//                 ),
//               );
//             });
//       } else if (snapshot.hasError) {
//         return Text('${snapshot.error}');
//       }
//       return const CircularProgressIndicator();
//     },
//   );
// }
}
