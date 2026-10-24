import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String expensesBoxName = 'expenses';

  static Future<Box<Map>> openExpensesBox() async {
    await Hive.initFlutter();
    return Hive.openBox<Map>(expensesBoxName);
  }
}
