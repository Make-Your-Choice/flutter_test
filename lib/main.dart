import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project1/model/tag.dart';
import 'package:project1/model/task.dart';
import 'package:project1/model/token.dart';

import 'login.dart';
import 'model/user.dart';

void main() async {
  await Hive.initFlutter();
  // final encryptionKey = Hive.generateSecureKey();
  // Hive.registerAdapter(TokenAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<User>('userBox');
  await Hive.openBox<Task>('taskBox');
  await Hive.openBox<Tag>('tagBox');
  // await Hive.openBox<Token>('tokenBox',
  //     encryptionCipher: HiveAesCipher(encryptionKey));
  // Hive.box<Token>('tokenBox').clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            primary: const Color.fromRGBO(117, 110, 243, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(102, 82, 255, 1),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.fitHeight,
              height: 400,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 80.0, horizontal: 40.0),
                height: MediaQuery.of(context).size.height - 370,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white,
                ),
                child: Column(children: [
                  Image.asset('assets/images/logo.png', fit: BoxFit.fitHeight),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Personal task tracker',
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Bottom text - bottom text',
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(141, 141, 141, 1)),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LoginPage(title: 'Sign In')));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.2, 0.5],
                          colors: [
                            Color.fromRGBO(139, 120, 255, 1),
                            Color.fromRGBO(84, 81, 214, 0.8)
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: const Text(
                        'Continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 1.35,
                            color: Colors.white),
                      ),
                    ),
                  )
                ]),
              ),
            )
          ]),
        ));
  }
}
