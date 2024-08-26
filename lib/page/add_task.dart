import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:project1/model/task%20post/task_post.dart';

import '../api/provider.dart';
import '../model/priority/priority.dart';
import '../model/tag/tag.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  const AddTaskPage({super.key, required this.title});

  final String title;

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

  Priority _priorityController = Priority.LOW;
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
                                    enabled: false,
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
                                    // controller: _dateStartController,
                                    initialValue: DateFormat('dd/MM/yyyy')
                                        .format(DateTime.now()),
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
                                    enabled: false,
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
                                    // controller: _timeStartController,
                                    initialValue:
                                        TimeOfDay.now().format(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.black87,
                                // fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                //   if (states.contains(WidgetState.disabled)) {
                                //     return Colors.white;
                                //     // return Theme.of(context).canvasColor;
                                //   }
                                //   return const Color.fromRGBO(177, 209, 153, 1);
                                // }),
                                    fillColor: WidgetStatePropertyAll(
                                      _deadlineCheck ? const Color.fromRGBO(177, 209, 153, 1) : Theme.of(context).canvasColor
                                    ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
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
                              firstCurve: Curves.easeOut,
                                secondCurve: Curves.easeIn,
                                firstChild: Column(children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width / 2 - 30,
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
                                                          233, 241, 255, 1)),
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
                                            MediaQuery.of(context).size.width / 2 - 30,
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
                                                          233, 241, 255, 1)),
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
                                ]),
                                secondChild: SizedBox(
                                    height: 0,
                                    width: MediaQuery.of(context).size.width),
                                crossFadeState: _deadlineCheck
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: const Duration(seconds: 1)),
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
                                                    color: item.$1 == _priorityController
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.black45)),
                                                maximumSize:
                                                    WidgetStatePropertyAll(Size(
                                                        MediaQuery.of(context).size.width / 3 -
                                                            27,
                                                        50)),
                                                minimumSize: WidgetStatePropertyAll(
                                                    Size(MediaQuery.of(context).size.width / 3 - 27, 50)),
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
                                      if (_dateEndController.text.isNotEmpty) {
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
                                        // DateTime timeEnd = formatTime
                                        //     .parse(_timeEndController.text);
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
    List<TagData> tagList = tagBox.values.toList();
    for (var i in tagList) {
      menuItems.add(DropdownMenuItem(value: i, child: Text(i.name)));
    }
    return menuItems;
  }
}
