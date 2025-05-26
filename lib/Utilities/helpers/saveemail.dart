import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveCredentials(String email , String name , String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
  await prefs.setString('name', name);
  await prefs.setString('password', password);
}
