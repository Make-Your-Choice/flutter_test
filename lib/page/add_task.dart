import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project1/model/task%20post/task_post.dart';
import 'package:project1/model/task/task.dart';

import '../api/provider.dart';
import 'login.dart';
import '../model/priority/priority.dart';
import '../model/tag/tag.dart';
import '../model/user/user.dart';
import '../model/user create/user_create.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  const AddTaskPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final dio = Dio(
  //     BaseOptions(baseUrl: 'https://test-mobile.estesis.tech/api/v1', headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       HttpHeaders.acceptHeader: 'application/json'
  //     }));
  Box<TagData> tagBox = Hive.box<TagData>('tagBox');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _timeStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _timeEndController = TextEditingController();
  Priority _priorityController = Priority.LOW;
  final List<bool> _selectedPriority = <bool>[false, false, true];
  bool _deadlineCheck = false;
  TagData _tagController = Hive.box<TagData>('tagBox').values.first;

  @override
  Widget build(BuildContext context) {
    // bool _deadlineCheck = false;
    List<(Priority, String)> priorityList = [
      (Priority.HIGH, 'High'),
      (Priority.MID, 'Medium'),
      (Priority.LOW, 'Low')
    ];

    var taskData = ref.watch(taskProvider);
    // int selectedPriority = 2;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children: [
                      Form(
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
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  child: TextFormField(
                                    readOnly: true,
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
                                    controller: _dateStartController,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                              context: context,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(3000),
                                              initialDate: DateTime.now());
                                      if (pickedDate != null) {
                                        String formattedDate =
                                            DateFormat('dd/MM/yyyy')
                                                .format(pickedDate);
                                        setState(() {
                                          _dateStartController.text =
                                              formattedDate;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 10.0),
                                        hintText: 'Time',
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    233, 241, 255, 1)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)))),
                                    controller: _timeStartController,
                                    onTap: () async {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());
                                      if (pickedTime != null) {
                                        String formattedDate =
                                            pickedTime.format(context);
                                        setState(() {
                                          _timeStartController.text =
                                              formattedDate;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Checkbox(
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
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  child: TextFormField(
                                    readOnly: true,
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
                                    controller: _dateEndController,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                              context: context,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(3000),
                                              initialDate: DateTime.now());
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
                                const SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 10.0),
                                        hintText: 'Time',
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    233, 241, 255, 1)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)))),
                                    controller: _timeEndController,
                                    onTap: () async {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());
                                      if (pickedTime != null) {
                                        String formattedDate =
                                            pickedTime.format(context);
                                        setState(() {
                                          _timeEndController.text =
                                              formattedDate;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Row(
                                children: priorityList
                                    .map((item) => Padding(
                                        padding: item.$1 == Priority.LOW
                                            ? const EdgeInsets.all(0)
                                            : const EdgeInsets.only(right: 20),
                                        child: OutlinedButton(
                                            style: ButtonStyle(
                                                foregroundColor:
                                                    const WidgetStatePropertyAll(
                                                        Colors.black),
                                                side: WidgetStatePropertyAll(BorderSide(
                                                    width: 2,
                                                    color: item.$1 ==
                                                            _priorityController
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.black45)),
                                                // backgroundColor: WidgetStatePropertyAll(
                                                //   item.$1 == _priorityController ? Theme.of(context).primaryColor : Theme.of(context).canvasColor
                                                // ),
                                                maximumSize:
                                                    WidgetStatePropertyAll(Size(
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                3 -
                                                            27,
                                                        50)),
                                                minimumSize: WidgetStatePropertyAll(
                                                    Size(MediaQuery.of(context).size.width / 3 - 27, 50)),
                                                // padding: const WidgetStatePropertyAll(
                                                //   EdgeInsets.all(20)
                                                // ),
                                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
                                            onPressed: () {
                                              setState(() {
                                                _priorityController = item.$1;
                                              });
                                            },
                                            child: Text(
                                              item.$2,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ))))
                                    .toList()),
                            // ToggleButtons(
                            //     isSelected: _selectedPriority,
                            //     onPressed: (int index) {
                            //       setState(() {
                            //         for(int i = 0; i < _selectedPriority.length; i++) {
                            //           _selectedPriority[i] = i == index;
                            //         }
                            //       });
                            //     },
                            //     selectedBorderColor: Theme.of(context).primaryColor,
                            //     selectedColor: Colors.black,
                            //     fillColor: Theme.of(context).canvasColor,
                            //     borderRadius: BorderRadius.circular(15),
                            //     borderColor: Colors.black45,
                            //     borderWidth: 2,
                            //     constraints: BoxConstraints(
                            //       minWidth: MediaQuery.of(context).size.width / 3 - 17,
                            //       minHeight: 60.0
                            //     ),
                            //     children: priorityList
                            //         .map(((Priority, String) item) =>
                            //           Text(
                            //             item.$2,
                            //             style: const TextStyle(
                            //             fontSize: 16
                            //           ),))
                            //         .toList()),
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
                                          BorderRadius.all(Radius.circular(15)),
                                    )),
                                    foregroundColor:
                                        WidgetStatePropertyAll(Colors.white),
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color.fromRGBO(117, 110, 243, 1))),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      TaskPostData task = TaskPostData(
                                          title: _nameController.text,
                                          text: _descriptionController.text,
                                          tagSid: _tagController.sid,
                                          priority: _priorityController);
                                      if(_dateEndController.text.isNotEmpty && _timeEndController.text.isNotEmpty) {
                                        DateFormat formatDate =
                                        DateFormat('dd/MM/yyyy');
                                        DateFormat formatTime =
                                        DateFormat('HH:mm');
                                        DateTime dateEnd = formatDate
                                            .parse(_dateEndController.text);
                                        DateTime timeEnd = formatTime
                                            .parse(_timeEndController.text);
                                        DateTime dateTime = DateTime(
                                            dateEnd.year,
                                            dateEnd.month,
                                            dateEnd.day,
                                            timeEnd.hour,
                                            timeEnd.minute);
                                        task.finishAt = dateTime;
                                      }
                                      ref
                                          .watch(taskProvider.notifier)
                                          .createTask(task);
                                      ref.refresh(taskProvider);
                                      // ref.refresh(taskProvider);
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Success'),
                                              content: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                          'Added new task'),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          context.go('/tasks');
                                                          // Navigator.pop(
                                                          //     context);
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(
                                                          //         builder: (context) =>
                                                          //             const LoginPage(
                                                          //                 title:
                                                          //                     'Flutter Demo Home Page')));
                                                        },
                                                        child: const Text(
                                                            'Return'),
                                                      ),
                                                    ],
                                                  )),
                                            );
                                          });
                                    } catch (e) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Error'),
                                              content: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                          'Task creation failed!'),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Return'),
                                                      ),
                                                    ],
                                                  )),
                                            );
                                          });
                                    }
                                  }
                                },
                                child: const Text(
                                  'Create',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]))
              ],
            ),
          ),
        ));
  }

  List<DropdownMenuItem<TagData>> get dropdownItems {
    List<DropdownMenuItem<TagData>> menuItems = [];
    // menuItems.add(const DropdownMenuItem(value: null, child: Text('-')));
    List<TagData> tagList = tagBox.values.toList();
    for (var i in tagList) {
      menuItems.add(DropdownMenuItem(value: i, child: Text(i.name)));
    }
    return menuItems;
  }
}
