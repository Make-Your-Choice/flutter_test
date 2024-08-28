import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project1/model/task%20post/task_post.dart';
import 'package:project1/model/task%20put/task_put.dart';
import 'package:project1/model/task/task.dart';

import '../api/provider.dart';
import '../model/priority/priority.dart';
import '../model/tag/tag.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  const AddTaskPage({super.key, required this.title, this.task});

  final String title;
  final TaskData? task;

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Box<TagData> tagBox = Hive.box<TagData>('tagBox');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _timeEndController = TextEditingController();

  DateTime _dateStart = DateTime.now();
  TimeOfDay _timeStart = TimeOfDay.now();

  Priority _priorityController = Priority.LOW;
  bool _deadlineCheck = false;
  TagData _tagController = Hive.box<TagData>('tagBox').values.first;
  List<(Priority, String)> priorityList = [
    (Priority.HIGH, 'High'),
    (Priority.MID, 'Medium'),
    (Priority.LOW, 'Low')
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateEndController.dispose();
    _timeEndController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (widget.task != null) {
          _nameController.text = widget.task!.title;
          _descriptionController.text = widget.task!.text;
          _tagController = Hive
              .box<TagData>('tagBox')
              .values
              .firstWhere((item) => item.sid == widget.task!.tag.sid);

          _dateStart =
              widget.task!.createdAt!.toLocal().add(
                  const Duration(minutes: 180));
          TimeOfDay time = TimeOfDay(
              hour: _dateStart.hour, minute: _dateStart.minute);
          _timeStart = time;

          _priorityController = widget.task!.priority;

          if (widget.task?.finishAt != null) {
            _deadlineCheck = true;
            DateTime endDate = widget.task!.finishAt!.add(
                const Duration(minutes: 180));
            // offset = widget.task!.finishAt!.toLocal().timeZoneOffset.inMinutes;
            _dateEndController.text = DateFormat('dd/MM/yyyy')
                .format(endDate);
            time = TimeOfDay(hour: endDate.hour, minute: endDate.minute);
            _timeEndController.text = time.format(context);
          }
      }
    //});
  }

  @override
  Widget build(BuildContext context) {
    // bool _deadlineCheck = false;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(widget.title),
          leading: IconButton(
              onPressed: () => {context.go('/tasks')},
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 30,
              )),
        ),
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Consumer(
            builder: (context, ref, child) {
              return
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: [
                          formWidget(),
                        ]))
                  ],
                );
            }),
        )));
  }

  Widget formWidget() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
                hintText: 'Title',
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                        Color.fromRGBO(233, 241, 255, 1)),
                    borderRadius: BorderRadius.all(
                        Radius.circular(15)))),
            controller: _nameController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Input title';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          TextFormField(
            // initialValue: widget.task != null ? widget.task?.text : '',
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
                hintText: 'Description',
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                        Color.fromRGBO(233, 241, 255, 1)),
                    borderRadius: BorderRadius.all(
                        Radius.circular(15)))),
            controller: _descriptionController,
          ),
          const SizedBox(height: 40),
          DropdownButtonFormField<TagData>(
              value: _tagController,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 10.0),
                  hintText: 'Date',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(
                              233, 241, 255, 1)),
                      borderRadius: BorderRadius.all(
                          Radius.circular(15)))),
              hint: const Text('Tag'),
              items: dropdownItems,
              onChanged: (value) {
                setState(() => _tagController = value!);
              }),
          const SizedBox(height: 40),
          dateTimeStart(),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                  checkColor: Colors.black87,
                  fillColor: WidgetStatePropertyAll(
                      _deadlineCheck
                          ? const Color.fromRGBO(
                          177, 209, 153, 1)
                          : Theme
                          .of(context)
                          .canvasColor
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5)
                  ),
                  value: _deadlineCheck,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _deadlineCheck = newValue!;
                    });
                  }),
              const Text('Deadline?')
            ],
          ),
          const SizedBox(height: 20),
          AnimatedCrossFade(
              firstCurve: Curves.easeInOutQuart,
              secondCurve: Curves.easeInOutQuart,
              firstChild: dateTimeEnd(),
              secondChild: SizedBox(
                  height: 0,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width),
              crossFadeState: _deadlineCheck
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 600)),
          priorityWidget(),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 60,
            decoration: const BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(15)),
            ),
            child: ElevatedButton(
              style: const ButtonStyle(
                  shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(
                            Radius.circular(15)),
                      )),
                  foregroundColor:
                  WidgetStatePropertyAll(Colors.white),
                  backgroundColor: WidgetStatePropertyAll(
                      Color.fromRGBO(117, 110, 243, 1))),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  try {
                    if (widget.task != null) {
                      updateTask();
                    } else {
                      createTask();
                    }

                    // ref.refresh(taskProvider);
                    showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Success'),
                            content:  Text(
                                widget.task != null ? 'Changes saved' : 'New task added'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context);
                                  context.go('/tasks');
                                },
                                child: const Text(
                                    'Return'),
                              )
                            ],
                          );
                        });
                  } on DioException catch (e) {
                    processErrors(e);
                  }
                }
              },
              child: Text(
                widget.task != null ? 'Save' : 'Create',
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget dateTimeStart() {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 30,
          child: TextFormField(
            readOnly: true,
            enabled: false,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 10.0
                ),
                hintText: 'Date',
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromRGBO(233, 241, 255, 1)),
                    borderRadius: BorderRadius.all(
                        Radius.circular(15)
                    )
                )
            ),
            initialValue: DateFormat('dd/MM/yyyy').format(_dateStart),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 30,
          child: TextFormField(
            readOnly: true,
            enabled: false,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 10.0
                ),
                hintText: 'Time',
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromRGBO(233, 241, 255, 1)),
                    borderRadius: BorderRadius.all(
                        Radius.circular(15)))),
            initialValue: _timeStart.format(context),
          ),
        ),
      ],
    );
  }

  Widget dateTimeEnd() {
    return Column(children: [
      Row(
        children: [
          SizedBox(
            width:
            MediaQuery
                .of(context)
                .size
                .width / 2 - 30,
            child: TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 10.0),
                  hintText: 'Date',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(
                              233, 241, 255,
                              1)),
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              15)))),
              controller: _dateEndController,
              onTap: () async {
                DateTime? pickedDate =
                await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(3000),
                    initialDate:
                    DateTime.now());
                if (pickedDate != null) {
                  String formattedDate =
                  DateFormat('dd/MM/yyyy')
                      .format(pickedDate);
                  setState(() {
                    _dateEndController.text =
                        formattedDate;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width:
            MediaQuery
                .of(context)
                .size
                .width / 2 - 30,
            child: TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 10.0),
                  hintText: 'Time',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(
                              233, 241, 255,
                              1)),
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              15)))),
              controller: _timeEndController,
              onTap: () async {
                TimeOfDay? pickedTime =
                await showTimePicker(
                    context: context,
                    initialTime:
                    TimeOfDay.now());
                setState(() {
                  if (pickedTime != null) {
                    String formattedDate =
                    pickedTime.format(context);
                    _timeEndController.text =
                        formattedDate;
                  }
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 40),
    ]);
  }

  Widget priorityWidget() {
    return Row(
        children: priorityList
            .map((item) =>
            Padding(
                padding: item.$1 == Priority.LOW
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.only(right: 20),
                child: OutlinedButton(
                    style: ButtonStyle(
                        foregroundColor: const WidgetStatePropertyAll(Colors.black),
                        side: WidgetStatePropertyAll(
                            BorderSide(
                                width: 2,
                                color: item.$1 == _priorityController
                                    ? Theme.of(context).primaryColor
                                    : Colors.black45)),
                        maximumSize: WidgetStatePropertyAll(Size(
                            MediaQuery.of(context).size.width / 3 - 27, 50)),
                        minimumSize: WidgetStatePropertyAll(
                            Size(MediaQuery.of(context).size.width / 3 - 27, 50)),
                        shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)))),
                    onPressed: () {
                      setState(() {
                        _priorityController = item.$1;
                      });
                    },
                    child: Text(
                      item.$2,
                      style: const TextStyle(fontSize: 16),
                    ))))
            .toList());
  }

  List<DropdownMenuItem<TagData>> get dropdownItems {

    List<DropdownMenuItem<TagData>> menuItems = [];
    List<TagData> tagList = tagBox.values.toList();
    for (var i in tagList) {
      menuItems.add(DropdownMenuItem(value: i, child: Text(i.name)));
    }
    return menuItems;
  }

  void createTask() {
    TaskPostData task = TaskPostData(
        title: _nameController.text,
        text: _descriptionController
            .text,
        tagSid: _tagController.sid,
        priority: _priorityController);
    if (_dateEndController.text
        .isNotEmpty) {
      task.finishAt =
          createFinishAtDateTime();
    }
    ref
        .watch(taskProvider.notifier)
        .createTask(task);
  }

  void updateTask() {
    TaskPutData task = TaskPutData(
        sid: widget.task!.sid!,
        title: _nameController.text,
        text: _descriptionController
            .text,
        isDone: widget.task!.isDone,
        tagSid: _tagController.sid,
        priority: _priorityController,
        syncStatus: widget.task!.syncStatus);
    if (_dateEndController.text
        .isNotEmpty) {
      task.finishAt =
          createFinishAtDateTime();
    }
    ref
        .watch(taskProvider.notifier)
        .updateTask(task);
  }

  DateTime createFinishAtDateTime() {
    DateFormat formatDate =
    DateFormat('dd/MM/yyyy');
    DateFormat formatTime =
    DateFormat('HH:mm');
    DateTime dateEnd = formatDate
        .parse(_dateEndController.text);
    DateTime timeEnd;

    if(_timeEndController.text.isNotEmpty) {
      timeEnd = formatTime
          .parse(_timeEndController.text);
    } else {
      timeEnd = formatTime.parse('23:59');
    }
    return DateTime(
        dateEnd.year,
        dateEnd.month,
        dateEnd.day,
        timeEnd.hour,
        timeEnd.minute);
  }

  void processErrors(DioException e) {
    showDialog(
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Error!\n${e.response
                    ?.statusCode}: ${e
                    .response
                    ?.statusMessage}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                    'Return'),
              )
            ],
          );
        });
  }
}
