import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _name = 'Name';
  static const String _userImg = 'userImg';
  static const String _loggedInKey = 'loggedIn';

  // Set user type
  static Future<void> setLoggedIn(bool isLogIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, isLogIn);
  }

  // Get user type
  static Future<bool?> getLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey);
  }

  static Future<void> setName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_name, name);
  }

  // Get phone
  static Future<String?> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_name);
  }
  static Future<void> setUserImg(Uint8List imgBytes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String imgBase64 = base64Encode(imgBytes);
    await prefs.setString(_userImg, imgBase64);
  }

  // Get image as Uint8List
  static Future<Uint8List?> getUserImg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imgBase64 = prefs.getString(_userImg);
    if (imgBase64 != null) {
      return base64Decode(imgBase64);
    }
    return null;
  }
}
