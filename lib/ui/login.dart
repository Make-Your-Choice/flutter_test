import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:project1/api/service/api_service.dart';
import 'package:project1/model/user%20login/user_login.dart';

import '../model/token/token.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Box<Token> tokenBox;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(widget.title),
        ),
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: [
                          titleTextWidget(),
                          signInFormWidget(),
                          const SizedBox(height: 40),
                          submitButtonWidget(),
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
          ),
        ));
  }

  Widget titleTextWidget() {
    return const Row(
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
    );
  }

  Widget signInFormWidget() {
    return Form(
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    var service = await ApiService.create();
                    UserLogin userLogin = UserLogin(_emailController.text,
                        _passwordController.text);
                    await service.logIn(userLogin);
                    context.go('/tasks');
                  } on DioException catch (e) {
                    showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: e.response?.data != null ? Text('Login failed!\n${e.response?.statusCode}: ${e.response?.statusMessage}\n${e.response?.data['detail']}') :
                            Text('Login failed!\n${e.response?.statusCode}: ${e.response?.statusMessage}'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // context.go('/tasks');
                                },
                                child: const Text('Return'),
                              )
                            ],
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
    );
  }

  Widget submitButtonWidget() {
    return RichText(
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
                  context.go('/sign-up');
                })
        ]));
  }
}
