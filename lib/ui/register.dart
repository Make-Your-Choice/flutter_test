
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/api/service/api_service.dart';

import '../model/user/user.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                          signUpFormWidget(),
                          const SizedBox(height: 40),
                          submitButtonWidget(),
                        ]))
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 20,
                  child: Image.asset(
                    'assets/images/dots2.png',
                    fit: BoxFit.fitHeight,
                  ),
                )
              ],
            ),
          )
      ),
    );
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
              'Create an account',
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

  Widget signUpFormWidget() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
                hintText: 'Name',
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                        Color.fromRGBO(233, 241, 255, 1)),
                    borderRadius:
                    BorderRadius.all(Radius.circular(15)))),
            controller: _nameController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Input name';
              }
              return null;
            },
          ),
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
                    User user = User(_nameController.text,
                        _emailController.text,
                        _passwordController.text);
                    await service.postUser(user);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Success'),
                            content: const Text(
                                'Registration success'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.go('/sign-in');
                                },
                                child:
                                const Text('Return'),
                              )
                            ],
                          );
                        });
                  } on DioException catch (e) {
                    showDialog(
                      useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: e.response?.data != null ? Text(
                                'Registration failed!\n${e.response?.statusCode}: ${e.response?.statusMessage}\n${e.response?.data['detail']}') :
                            Text('Registration failed!\n${e.response?.statusCode}: ${e.response?.statusMessage}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // context.go('/sign-up');
                                    },
                                    child:
                                    const Text('Return'),
                                  ),
                                ],
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
    );
  }

  Widget submitButtonWidget() {
    return RichText(
        text: TextSpan(children: [
          const TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                  color: Color.fromRGBO(141, 141, 141, 1),
                  fontSize: 16)),
          TextSpan(
              text: 'Sign In',
              style: const TextStyle(
                  color: Color.fromRGBO(117, 110, 243, 1),
                  fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.go('/sign-in');
                })
        ]));
  }
}
