import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project1/login.dart';
import 'package:project1/model/tag.dart';
import 'package:project1/model/task.dart';

import 'model/user.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<User>('userBox');
  await Hive.openBox<Task>('taskBox');
  await Hive.openBox<Tag>('tagBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(title),
      // ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
            Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.fitHeight,
              height: 375,
            ),
              Container(
                 // height: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.redAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const LoginPage(title: 'Flutter Demo Home Page'))
                        );
                      },
                      child: const Text('Начать'),
                    ),
                  ],
                ),
                // child: Padding(
                //   padding: const EdgeInsets.only(
                //       left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                //
                //
                // )
              )
            ])
          )

          //)
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   Future<User>? _futureUser;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Padding(
//                 padding: const EdgeInsets.all(20.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column (
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     TextFormField(
//                       decoration: const InputDecoration(
//                         hintText: 'Имя',
//                       ),
//                       controller: _nameController,
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Введите имя';
//                         }
//                         return null;
//                       },
//                     ),
//                     TextFormField(
//                       decoration: const InputDecoration(
//                         hintText: 'Email',
//                       ),
//                       controller: _emailController,
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Введите email';
//                         }
//                         return null;
//                       },
//                     ),
//                     TextFormField(
//                       decoration: const InputDecoration(
//                         hintText: 'Пароль',
//                       ),
//                       controller: _passwordController,
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Введите пароль';
//                         }
//                         return null;
//                       },
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         if(_formKey.currentState!.validate()) {
//                           _futureUser = createUser(_nameController.text, _emailController.text, _passwordController.text);
//                         }
//                       },
//                       child: const Text('Сохранить'),
//                     ),
//                   ],
//                 ),
//               ),
//
//             )
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// Future<User> createUser (String name, String email, String password) async {
//   final response = await post(
//       Uri.parse('https://test-mobile.estesis.tech/api/v1/register'),
//       headers: <String, String> {
//         'Content-Type':'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String> {
//         'name': name,
//         'email': email,
//         'password': password
//       })
//   );
//   if (response.statusCode == 200) {
//     return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
//   } else {
//     throw Exception('Ошибка регистрации!');
//   }
// }
//
