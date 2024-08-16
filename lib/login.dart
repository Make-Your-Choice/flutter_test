import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:project1/register.dart';
import 'package:project1/tasks.dart';

import 'model/token.dart';
import 'model/user_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // late Box<Token> tokenBox;
  final dio = Dio(
      BaseOptions(baseUrl: 'https://test-mobile.estesis.tech/api/v1', headers: {
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    HttpHeaders.acceptHeader: 'application/json'
  }));
  Future<Token>? _futureToken;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   tokenBox = Hive.box<Token>('tokenBox');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(widget.title),
      ),
      body: Center(
          child: (_futureToken == null) ? buildColumn() : buildFutureBuilder()),
    );
  }

  SizedBox buildColumn() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Fill all the fields',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(141, 141, 141, 1),
                              ),
                            ),
                            SizedBox(height: 60),
                          ],
                        )
                      ],
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          TextFormField(
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 10.0),
                                hintText: 'Email',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(233, 241, 255, 1)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)))),
                            controller: _emailController,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Input email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 10.0),
                                hintText: 'Password',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(233, 241, 255, 1)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)))),
                            controller: _passwordController,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Input password';
                              }
                              return null;
                            },
                          ),
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
                                    _futureToken = getToken(
                                        _emailController.text,
                                        _passwordController.text);
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TasksPage(
                                                    title: 'My tasks')));
                                  } catch (e) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Error'),
                                            content: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                        'Registration failed'),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Return'),
                                                    ),
                                                  ],
                                                )),
                                          );
                                        });
                                  }
                                }
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 20),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    RichText(
                        text: TextSpan(children: [
                      const TextSpan(
                          text: 'Don\'t have an account? ',
                          style: TextStyle(
                              color: Color.fromRGBO(141, 141, 141, 1),
                              fontSize: 16)),
                      TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                              color: Color.fromRGBO(117, 110, 243, 1),
                              fontSize: 16),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RegisterPage(
                                          title: 'Sign Up')));
                            })
                    ]))
                  ]))
            ],
          ),
          Positioned(
            top: 0,
            right: 20,
            child: Image.asset(
              'assets/images/dots1.png',
              fit: BoxFit.fitHeight,
            ),
          )
        ],
      ),
    );
  }

  Future<Token> getToken(String email, String password) async {
    UserLogin userLogin = UserLogin(email, password);
    Response<dynamic> response;
    try {
      response = await dio.post('/login', data: userLogin.toJson());
      if (response.statusCode == 200) {
        FlutterSecureStorage storage = const FlutterSecureStorage();
        String accessToken = Token.fromJson(response.data).accessToken;
        storage.write(key: 'access_token', value: accessToken);
        // tokenBox.put('current_token', Token.fromJson(response.data));
        // Hive.box<Token>('tokenBox').put('current_token', Token.fromJson(response.data));
        return Token.fromJson(response.data);
      } else {
        throw Exception('Login error!');
      }
    } catch (e) {
      rethrow;
    }
  }

  FutureBuilder<Token> buildFutureBuilder() {
    return FutureBuilder<Token>(
      future: _futureToken,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.accessToken);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
