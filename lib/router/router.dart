import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/model/task/task.dart';

import '../ui/add_task.dart';
import '../ui/home.dart';
import '../ui/login.dart';
import '../ui/register.dart';
import '../ui/tasks.dart';

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