import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/home.dart';
import 'package:project1/login.dart';
import 'package:project1/register.dart';
import 'package:project1/tasks.dart';

import '../add_task.dart';

final GoRouter router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
      builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
      }),
      GoRoute(
          path: '/sign-in',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage(title: 'Sign In');
          }),
      GoRoute(
          path: '/sign-up',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterPage(title: 'Sign Up');
          }),
      GoRoute(
          path: '/tasks',
          builder: (BuildContext context, GoRouterState state) {
            return const TasksPage(title: 'My tasks');
          }),
      GoRoute(
          path: '/add-task',
          builder: (BuildContext context, GoRouterState state) {
            return const AddTaskPage(title: 'Add task');
          }),
  ]
);