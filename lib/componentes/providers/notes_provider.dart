import 'package:flutter/material.dart';

class NotesProvider extends ChangeNotifier {
  List<DateTime?> reminders = [];

  void addReminder(DateTime? reminderDate) {
    reminders.add(reminderDate);
    notifyListeners();
  }

  List<DateTime?> get getReminders => reminders;
}
