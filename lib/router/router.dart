import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/model/task/task.dart';
import 'package:project1/page/home.dart';
import 'package:project1/page/login.dart';
import 'package:project1/page/register.dart';
import 'package:project1/page/tasks.dart';

import '../page/add_task.dart';

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
      GoRoute(
          path: '/edit-task',
          builder: (BuildContext context, GoRouterState state) {
            TaskData task = state.extra as TaskData;
            return AddTaskPage(title: 'Edit task', task: task);
          }),
  ]
);