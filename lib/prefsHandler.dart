import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

const String PREFS_LAST = "PREFS_LAST";
const String PREFS_LIST = "PREFS_LIST";
const String PREFS_VALUE = "PREFS_VALUE_";

Future<SharedPreferences> getPrefs() => SharedPreferences.getInstance();

Future<String> readLastCounter() async {
  SharedPreferences prefs = await getPrefs();
  return prefs.getString(PREFS_LAST) ?? null;
}

Future<int> readCounterValue(String counterName) async {
  final SharedPreferences prefs = await getPrefs();
  return prefs.getInt(PREFS_VALUE + counterName) ?? null;
}

Future<List<String>> readAllCountersNames() async {
  final SharedPreferences prefs = await getPrefs();
  return await prefs.getStringList(PREFS_LIST) ?? null;
}

void deleteCounterValue(String name) async {
  SharedPreferences prefs = await getPrefs();
  prefs.remove(name);
}

void writeAllCounterNames(List<Counter> cs) async {
  SharedPreferences prefs = await getPrefs();
  await prefs.setStringList(PREFS_LIST, cs.map((c) => c.name).toList());
}

void writeCounterValue(String name, int value) async {
  SharedPreferences prefs = await getPrefs();
  await prefs.setString(PREFS_LAST, name);
  await prefs.setInt(PREFS_VALUE + name, value);
}
