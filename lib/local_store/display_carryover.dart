import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isAlreadyDisplayed() async {
  final prefs = await SharedPreferences.getInstance();
  final lastDate = prefs.getString("last_carryover_date");
  final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());

  return lastDate == todayStr;
}

void setDisplay() async {
  final prefs = await SharedPreferences.getInstance();
  final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());
  await prefs.setString("last_carryover_date", todayStr);
}