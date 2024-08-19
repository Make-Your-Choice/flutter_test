import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'login.dart';
import 'model/tag/tag.dart';
import 'model/user/user.dart';
import 'model/user create/user_create.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key, required this.title});

  final String title;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final dio = Dio(
  //     BaseOptions(baseUrl: 'https://test-mobile.estesis.tech/api/v1', headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       HttpHeaders.acceptHeader: 'application/json'
  //     }));
  Future<UserCreate>? _futureUser;
  Box<Tag> tagBox = Hive.box<Tag>('tagBox');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _timeStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  late bool _deadlineCheck = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(widget.title),
        leading: IconButton(
            onPressed: () => {
                  context.go('/tasks')
                },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 30,
            )),
      ),
      body: Center(
          child: (_futureUser == null) ? buildColumn() : buildFutureBuilder()),
    );
  }

  SizedBox buildColumn() {
    return SizedBox(
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
                                    color: Color.fromRGBO(233, 241, 255, 1)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)))),
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
                                    color: Color.fromRGBO(233, 241, 255, 1)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)))),
                        controller: _descriptionController,
                        // validator: (String? value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Input email';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 40),
                      DropdownMenu<String>(
                        hintText: 'Tag',
                        controller: _tagController,
                        dropdownMenuEntries: dropdownItems(),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: TextFormField(
                              readOnly: true,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 10.0),
                                  hintText: 'Date',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(233, 241, 255, 1)),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15)))),
                              controller: _dateStartController,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(3000),
                                    initialDate: DateTime.now());
                                if (pickedDate != null) {
                                  String formattedDate =
                                      DateFormat('dd/MM/yyyy')
                                          .format(pickedDate);
                                  setState(() {
                                    _dateStartController.text = formattedDate;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            child: TextFormField(
                              readOnly: true,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 10.0),
                                  hintText: 'Time',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(233, 241, 255, 1)),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15)))),
                              controller: _timeStartController,
                              onTap: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                if (pickedTime != null) {
                                  String formattedDate =
                                      pickedTime.format(context);
                                  setState(() {
                                    _timeStartController.text = formattedDate;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
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
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                              shape:
                                  WidgetStatePropertyAll(RoundedRectangleBorder(
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
                                _futureUser = createUser(
                                    _nameController.text,
                                    _descriptionController.text,
                                    _tagController.text);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Success'),
                                        content: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                const Text(
                                                    'Registration success'),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const LoginPage(
                                                                    title:
                                                                        'Flutter Demo Home Page')));
                                                  },
                                                  child: const Text('Return'),
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
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                const Text(
                                                    'Registration failed'),
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
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]))
        ],
      ),
    );
  }

  Future<UserCreate> createUser(
      String name, String email, String password) async {
    User user = User(name, email, password);
    Dio dio = Dio();
    Response<dynamic> response;
    try {
      response = await dio.post('/register', data: user);
      if (response.statusCode == 200) {
        return UserCreate.fromJson(response.data);
      } else {
        throw Exception('Registration error!');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<UserCreate> createUser (String name, String email, String password) async {
  //   UserCreate userCreate = UserCreate(name, email, password);
  //   final response = await post(
  //       Uri.parse('https://test-mobile.estesis.tech/api/v1/register'),
  //       headers: <String, String> {
  //         'Content-Type':'application/json',
  //         'accept' : 'application/json'
  //       },
  //     body: jsonEncode(userCreate.toJson())
  //   );
  //   if (response.statusCode == 200) {
  //     return UserCreate.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  //   } else {
  //     print(response);
  //     throw Exception('Ошибка регистрации!');
  //   }
  // }

  FutureBuilder<UserCreate> buildFutureBuilder() {
    return FutureBuilder<UserCreate>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.name);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }

  List<DropdownMenuEntry<String>> dropdownItems() {
    List<DropdownMenuEntry<String>> menuItems = [];
    List<Tag> tagList = tagBox.values.toList();
    for (var i in tagList) {
      menuItems.add(DropdownMenuEntry(value: i.sid, label: i.name));
    }
    return menuItems;
  }
}
