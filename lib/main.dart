import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'user_login_screen.dart';
import 'admin_login_screen.dart';

void main() {
  runApp(MyApp());
}

/// التطبيق الرئيسي مع تعريف المسارات
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Store',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/userLogin': (context) => UserLoginScreen(),
        '/adminLogin': (context) => AdminLoginScreen(),
      },
    );
  }
}
