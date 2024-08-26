import 'package:dio/dio.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project1/api/provider.dart';
import 'package:project1/model/sync%20status/sync_status.dart';
import 'package:project1/model/task%20post/task_post.dart';

import '../model/task put/task_put.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskPageState();
}
class _TaskPageState extends ConsumerState<TasksPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // final tasks = ref.read(taskProvider);
    var taskData = ref.watch(taskProvider);
    var tagData = ref.watch(tagProvider);
    // ref.watch(tagProvider.notifier).fetchTags();
    return Scaffold(
        appBar: AppBar(
          // backgroundColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(widget.title),
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
          return RefreshIndicator(
              onRefresh: () => ref.refresh(taskProvider.future),
          child: SingleChildScrollView(
            child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    SearchBar(
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
                    // tagData.when(
                    //     data: (data) =>
                    //     Row(
                    //       children: [
                    //         ListView.builder(
                    //           itemBuilder: (context, index) {
                    //             return OutlinedButton(
                    //                 onPressed: () {
                    //                   //TODO implement filters
                    //                 },
                    //                 child: Text(data.elementAt(index).name));
                    //           },
                    //
                    //         )
                    //       ]
                    //     ),
                    //     error: (error, stackTrace) => Text(error.toString()),
                    //     loading: () => const CircularProgressIndicator()),
                    const SizedBox(height: 40),
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
                    taskData.when(
                        data: (data) {
                          data = data.where((item) => item.createdAt?.day == _selectedDate.day &&
                          item.createdAt?.month == _selectedDate.month &&
                          item.createdAt?.year == _selectedDate.year).toList();
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
                                        key:
                                            Key(data.elementAt(listIndex).sid!),
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
                                                    TaskPutData upd =
                                                        TaskPutData(
                                                            data.elementAt(listIndex).sid!,
                                                            data.elementAt(listIndex).title,
                                                            data.elementAt(listIndex).text,
                                                            data.elementAt(listIndex).isDone,
                                                            data.elementAt(listIndex).tag.sid,
                                                          data.elementAt(listIndex).syncStatus
                                                        );
                                                    upd.isDone = true;

                                                    ref
                                                        .watch(taskProvider.notifier)
                                                        .completeTask(upd);
                                                    ref.
                                                        refresh(taskProvider);
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
                                                    height: 80,
                                                    width:
                                                        MediaQuery.of(context).size.width,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).canvasColor,
                                                      borderRadius:
                                                          borderRadius,
                                                      // border: Border.all(
                                                      //     color: const Color.fromRGBO(
                                                      //         233, 241, 255, 1))
                                                    ),
                                                    child: ListTile(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(15),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets.all(0),
                                                        title: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [Row(
                                                            children: [
                                                              Checkbox(
                                                                value: data.elementAt(listIndex).isDone,
                                                                onChanged: (bool?
                                                                value) {
                                                                  //TODO implement task completion
                                                                  TaskPutData upd =
                                                                  TaskPutData(
                                                                      data.elementAt(listIndex).sid!,
                                                                      data.elementAt(listIndex).title,
                                                                      data.elementAt(listIndex).text,
                                                                      data.elementAt(listIndex).isDone,
                                                                      data.elementAt(listIndex).tag.sid,
                                                                    data.elementAt(listIndex).syncStatus
                                                                  );
                                                                  upd.isDone = true;
                                                                  ref
                                                                      .watch(taskProvider
                                                                      .notifier)
                                                                      .completeTask(upd);
                                                                },
                                                              ),
                                                              Text(
                                                                data.elementAt(listIndex).title,
                                                                style:
                                                                TextStyle(
                                                                    fontSize: 16,
                                                                decoration: data.elementAt(listIndex).isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                                                color: data.elementAt(listIndex).finishAt != null &&
                                                                    data.elementAt(listIndex).finishAt?.compareTo(DateTime.now()) == -1 ? Colors.redAccent : Colors.black87),
                                                              ),
                                                            ]
                                                          ),
                                                            data.elementAt(listIndex).syncStatus != SyncStatus.BOTH?
                                                              IconButton(
                                                                icon: const Icon(
                                                                    Icons.sync_outlined,
                                                                    color: Color.fromRGBO(254, 181, 189, 1)
                                                                ),
                                                                onPressed: () {
                                                                  if(data.elementAt(listIndex).syncStatus == SyncStatus.LOCAL_ONLY) {
                                                                  TaskPostData taskPost = TaskPostData(
                                                                      title: data.elementAt(listIndex).title,
                                                                      text: data.elementAt(listIndex).text,
                                                                      tagSid: data.elementAt(listIndex).tag.sid,
                                                                      priority: data.elementAt(listIndex).priority);
                                                                  ref.watch(taskProvider.notifier).retryCreateTask(taskPost, data.elementAt(listIndex));
                                                                } else {
                                                                    ref.watch(taskProvider.notifier).deleteTask(data.elementAt(listIndex).sid!);
                                                                }}
                                                              ) : IconButton(
                                                              highlightColor: Colors.transparent,
                                                                icon: const Icon(
                                                                  Icons.check,
                                                                color: Color.fromRGBO(176, 217, 127, 1),
                                                              ),
                                                              onPressed: () {  },
                                                            )

                                                          ],
                                                        ),
                                                        subtitle: Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                    left: 50,
                                                                    right: 50,
                                                                    bottom: 20),
                                                            child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.sell_outlined,
                                                                    color: Theme.of(context).colorScheme.primary,
                                                                    size: 15,
                                                                  ),
                                                                  const SizedBox(width: 5,),
                                                                  Text(
                                                                    data.elementAt(listIndex).tag.name,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Color.fromRGBO(141, 141, 141, 1),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 10,),
                                                                  Text(
                                                                      data.elementAt(listIndex).finishAt != null ?
                                                                        DateFormat('dd MMMM HH:mm').format(data.elementAt(listIndex).finishAt!) :
                                                                          '',
                                                                    style: const TextStyle(
                                                                        color: Color.fromRGBO(254, 181, 189, 1)),
                                                                  )
                                                                ]))));
                                              });
                                        }),
                                      )
                                    ],
                                  );
                                });},
                        error: (error, stacktrace)  {
                            if (error is DioException) {
                              if(error.response?.statusCode == 401) {
                                context.go('/sign-in');
                              } else {
                                return Text('Error! ${error.response
                                    ?.statusCode}: ${error.response
                                    ?.statusMessage}');
                              }
                            }
                            return const Text('Error! Unexpected error!');
                        },
          loading: () => const CircularProgressIndicator())
                  ]))
          ])));
        }));
  }
}
