import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'model/token.dart';
import 'model/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<User>? _futureToken;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Email',
                      ),
                      controller: _emailController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Пароль',
                      ),
                      controller: _passwordController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          if(_formKey.currentState!.validate()) {
            // TODO получить токен и передать его в корень приложения(?)
            //createUser(_nameController.text, _emailController.text, _passwordController.text);
          }
        },
        // tooltip: 'Increment',
        child: const Text('Сохранить'),
      ),
    );
  }
}

Future<Token> getToken (String name, String email, String password) async {
  final response = await post(
      Uri.parse('https://test-mobile.estesis.tech/api/v1/login'),
      headers: <String, String> {
        'Content-Type':'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'username': email,
        'password': password
      })
  );
  if (response.statusCode == 200) {
    return Token.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Ошибка входа в систему!');
  }
}

