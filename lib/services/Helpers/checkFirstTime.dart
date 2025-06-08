import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkIfFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  final alreadyUsed = prefs.getBool('alreadyUsed') ?? false;

  if (!alreadyUsed) {
    await prefs.setBool('alreadyUsed', true);
  }

  return !alreadyUsed;
}