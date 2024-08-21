import 'package:hive_flutter/adapters.dart';

import '../model/priority/priority.dart';
import '../model/tag/tag.dart';
import '../model/task/task.dart';
import '../model/user/user.dart';

void init() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskDataAdapter());
  Hive.registerAdapter(TagDataAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<User>('userBox');
  await Hive.openBox<TaskData>('taskBox');
  await Hive.openBox<TagData>('tagBox');
}