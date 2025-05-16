import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('unverified_email', email);
}
