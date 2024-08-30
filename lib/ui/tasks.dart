import 'package:dio/dio.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project1/model/sync%20status/sync_status.dart';
import 'package:project1/model/task/task.dart';

import '../api/provider/connection state/connection_state_provider.dart';
import '../api/provider/tag/tag_provider.dart';
import '../api/provider/task/task_provider.dart';
import '../api/provider/token state/token_state_provider.dart';
import '../model/tag/tag.dart';
import '../model/task put/task_put.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskPageState();
}
class _TaskPageState extends ConsumerState<TasksPage> {
  late final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String _selectedFilter = '';
  DateTime _selectedDate = DateTime.now();
  bool isOffline = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var taskData = ref.watch(taskProvider);
    var tagData = ref.watch(tagProvider);
    var tokenState = ref.watch(tokenStateProvider);
    var connectionState = ref.watch(connectionStateProvider);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(widget.title),
          leading: IconButton(
              onPressed: () async {
                try {
                  if(await ref.watch(tokenStateProvider.notifier).logOut()) {
                    return context.go('/sign-in');
                  }
                } on DioException catch(e) {
                  if(e.type == DioExceptionType.connectionError) {
                    // showDialog(
                    //     useSafeArea: true,
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return AlertDialog(
                    //         title: const Text('Error'),
                    //         content: Text('Connection lost!\n${e.response?.statusCode}: ${e.response?.statusMessage}'),
                    //         actions: [
                    //           TextButton(
                    //             onPressed: () {
                    //               Navigator.pop(context);
                    //             },
                    //             child: const Text('Return'),
                    //           )
                    //         ],
                    //       );
                    //     });
                  }
                  else if(e.response?.statusCode == 401 || e.type == DioExceptionType.badResponse) {
                    context.go('/sign-in');
                  }
                  showDialog(
                      useSafeArea: true,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text('Error!\n${e.response?.statusCode}: ${e.response?.statusMessage}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Return'),
                            )
                          ],
                        );
                      });
                }
              },
              icon: const Icon(
                Icons.logout,
                size: 25,
              )),
          actions: [
            IconButton(
                onPressed: () => {context.go('/add-task')},
                icon: const Icon(
                  Icons.add,
                  size: 30,
                )),
            connectionState.when(
                data: (data) =>
                  IconButton(
                      onPressed: () => {},
                      icon: Icon(
                        data ? Icons.wifi : Icons.wifi_off,
                        size: 30,
                      )),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const CircularProgressIndicator()),

          ],
        ),
        body: Consumer(builder: (context, ref, child) {
          return RefreshIndicator(
              onRefresh: () async {
                tokenState.when(
                    data: (data) => {
                      if(data == false) {
                        context.go('/sign-in')
                      }
                    },
                    error: (error, stackTrace) {
                      processTokenStateErrors(error, stackTrace);
                    },
                    loading: () => const CircularProgressIndicator());
                return ref.refresh(taskProvider.future);
                },
          child: SingleChildScrollView(
            child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    searchFilterWidget(tagData),
                    EasyDateTimeLine(
                      initialDate: DateTime.now(),
                      onDateChange: (selectedDate) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      },
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
                    Container(
                      // padding: const EdgeInsets.all(16),
                        child:
                    taskData.when(
                        data: (data) {
                          return taskDataWidget(data);
                        },
                        error: (error, stacktrace)  {
                          // if(error is DioException) {
                          //   if(error.type == DioExceptionType.connectionError) {
                          //     return const Text('yyyyyyy');
                          //   }
                          //   return Text('uuuuu');
                          // } else {
                          //   return Text('oooooo');
                          // }
                          // }
                          // if((error as DioException).type == DioExceptionType.connectionError ||
                          //     (error).type == DioExceptionType.connectionTimeout) {
                          //   ref.watch(connectionStateProvider.notifier).fetchNewState(false);
                          //
                          // }

                          // return (error).type == DioExceptionType.connectionError ||
                          //     (error).type == DioExceptionType.connectionTimeout ?

                          // const Text('offline!')

                          // offlineData.when(
                          //     data: (data) => taskDataWidget(data),
                          //     error: (error, stacktrace) => Text(error.toString()),
                          //     loading: () => const CircularProgressIndicator())
                          //     :  Text('$error');

                          if (error is DioException) {
                            // if(error.response?.statusCode == 401 || error.type == DioExceptionType.badResponse) {
                              context.go('/sign-in');
                            // } else {
                            //   return Text('Error! ${error.response
                            //       ?.statusCode}: ${error.response
                            //       ?.statusMessage}');
                            // }
                          }
                          return null;
                        },
                        loading: () => const CircularProgressIndicator()))



                  ]))
          ])));
        }));
  }

  Widget searchFilterWidget(AsyncValue<List<TagData>> tagData) {
    return Column(
      children: [
        SearchBar(
          onChanged: (query) {
            setState(() {
              _searchController.text = query;
            });
          },
          onTap: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          controller: _searchController,
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
        const SizedBox(height: 30),
        AnimatedCrossFade(
          firstCurve: Curves.easeInOutQuart,
          secondCurve: Curves.easeInOutQuart,
          duration: const Duration(milliseconds: 600),
          firstChild: Column(
              children: [
                tagData.when(
                    data: (data) {
                      return SizedBox(
                          width: MediaQuery.of(context).size.width - 20,
                          height: 40,
                          child:
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            // clipBehavior: Clip.hardEdge,
                            // physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, listIndex) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    right: listIndex == data.length - 1 ? 0 : 5),
                                child: OutlinedButton(
                                    style: ButtonStyle(
                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        foregroundColor:
                                        const WidgetStatePropertyAll(
                                            Colors.black),
                                        side: WidgetStatePropertyAll(BorderSide(
                                            width: 2,
                                            color:
                                            data.elementAt(listIndex).sid == _selectedFilter
                                                ? Theme.of(context)
                                                .primaryColor
                                                :
                                            Colors.black45)),
                                        minimumSize: WidgetStatePropertyAll(
                                          Size(data.elementAt(listIndex).name.length.toDouble(), 30.0),
                                        )
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        if(_selectedFilter == data.elementAt(listIndex).sid) {
                                          _selectedFilter = '';
                                        } else{
                                          _selectedFilter = data.elementAt(listIndex).sid;
                                        }
                                      });
                                    },
                                    child: Text(data.elementAt(listIndex).name)
                                ),
                              );
                            },
                            //),
                          ));
                    },
                    error: (error, stackTrace) => const Text('Error!!!!!'),
                    loading: () => const CircularProgressIndicator()
                ),
                const SizedBox(height: 30)]),
          secondChild: SizedBox(
              height: 0,
              width: MediaQuery
                  .of(context)
                  .size
                  .width),
          crossFadeState: _showFilters ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }

  Widget taskDataWidget(List<TaskData> data) {
    // for(var item in data) {
    //   int offset = item.createdAt!.toLocal().timeZoneOffset.inMinutes;
    //   item.createdAt!.toLocal().add(Duration(days: offset));
    // }
    // data = data.where((item) => item.createdAt?.toLocal().day == _selectedDate.day &&
    //     item.createdAt?.toLocal().month == _selectedDate.month &&
    //     item.createdAt?.toLocal().year == _selectedDate.year).toList();
    // if(_searchController.text.isNotEmpty) {
    //   data = data.where((item) => item.title.contains(_searchController.text)).toList();
    // }
    // if(_selectedFilter.isNotEmpty) {
    //   data = data.where((item) => item.tag.sid.contains(_selectedFilter)).toList();
    // }
    data = filterData(data);
    return ListView.builder(
        padding:
        const EdgeInsets.symmetric(vertical: 30),
        clipBehavior: Clip.hardEdge,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                            completeTask(data.elementAt(listIndex));
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
                          onPressed: (context) {
                            ref
                                .watch(taskProvider.notifier)
                                .deleteTask(data.elementAt(listIndex).sid!);
                          }),
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
                            height: 90,
                            width:
                            MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius:
                              BorderRadius.circular(15),
                              border: Border.all(
                                  color: const Color.fromRGBO(233, 241, 255, 1))
                            ),
                            child: taskBodyWidget(data.elementAt(listIndex)),
                        );
                      });
                }),
              )
            ],
          );
        });
  }

  Widget taskBodyWidget(TaskData task) {
    return ListTile(
        onTap: () {
          context.go('/edit-task', extra: task);
        },
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
        contentPadding:
        const EdgeInsets.all(0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.black87,
                  fillColor: WidgetStatePropertyAll(
                      task.isDone ? const Color.fromRGBO(177, 209, 153, 1) : Theme.of(context).canvasColor
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                  value: task.isDone,
                  onChanged: (bool? value) {
                    completeTask(task);
                  },
                ),
                Text(
                  task.title,
                  style: TextStyle(
                      fontSize: 16,
                      decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      color: task.finishAt != null &&
                          task.finishAt?.compareTo(DateTime.now()) == -1 ? Colors.redAccent : Colors.black87),
                ),
              ]
          ),
            syncStatusIconWidget(task),
          ],
        ),
        subtitle: Padding(
            padding:
            const EdgeInsets.only(
                left: 50,
                right: 50,
                bottom: 30),
            child: Row(
                children: [
                  Icon(
                    Icons.sell_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 15,
                  ),
                  const SizedBox(width: 5,),
                  Text(
                    task.tag.name,
                    style:
                    const TextStyle(
                      color: Color.fromRGBO(141, 141, 141, 1),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    task.finishAt != null ?
                    DateFormat('dd MMMM HH:mm').format(task.finishAt!.add(const Duration(minutes: 180))) :
                    '',
                    style: const TextStyle(
                        color: Color.fromRGBO(254, 181, 189, 1)),
                  ),
                ])));
  }

  Widget syncStatusIconWidget(TaskData task) {
    return task.syncStatus != SyncStatus.BOTH?
    IconButton(
        icon: const Icon(
            Icons.sync_outlined,
            color: Color.fromRGBO(254, 181, 189, 1)
        ),
        onPressed: () {
          if(task.syncStatus == SyncStatus.LOCAL_ONLY) {
            ref.watch(taskProvider.notifier).retryTask(task);
          } else if(task.syncStatus == SyncStatus.SERVER_ONLY) {
            ref.watch(taskProvider.notifier).deleteTask(task.sid!);
          }}
    ) : IconButton(
      highlightColor: Colors.transparent,
      icon: const Icon(
        Icons.check,
        color: Colors.transparent,
        // color: Color.fromRGBO(176, 217, 127, 1),
      ),
      onPressed: () {  },
    );
  }

  void completeTask(TaskData task) {
    TaskPutData upd =
    TaskPutData(
        sid: task.sid!,
        title: task.title,
        text: task.text,
        isDone: task.isDone,
        tagSid: task.tag.sid,
        syncStatus: task.syncStatus,
        priority: task.priority
    );
    upd.isDone = true;

    ref
        .watch(taskProvider.notifier)
        .updateTask(upd);
  }

  void processTokenStateErrors(Object error, StackTrace stackTrace) {
    if(error is DioException) {
      if(error.response?.statusCode == 401 || error.type == DioExceptionType.badResponse) {
        context.go('/sign-in');
      } else {
        showDialog(
            useSafeArea: true,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Error!\n${error.response?.statusCode}: ${error.response?.statusMessage}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Return'),
                  )
                ],
              );
            });
      }
    }
  }

  List<TaskData> filterData (List<TaskData> data) {
    for(var item in data) {
      int offset = item.createdAt!.toLocal().timeZoneOffset.inMinutes;
      item.createdAt!.toLocal().add(Duration(days: offset));
    }
    data = data.where((item) => item.createdAt?.toLocal().day == _selectedDate.day &&
        item.createdAt?.toLocal().month == _selectedDate.month &&
        item.createdAt?.toLocal().year == _selectedDate.year).toList();
    if(_searchController.text.isNotEmpty) {
      data = data.where((item) => item.title.contains(_searchController.text)).toList();
    }
    if(_selectedFilter.isNotEmpty) {
      data = data.where((item) => item.tag.sid.contains(_selectedFilter)).toList();
    }
    return data;
  }
}
