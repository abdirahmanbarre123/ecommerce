import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'admin_screen.dart';

/// شاشة تسجيل دخول المدير مع التحقق من بيانات الاعتماد في قاعدة البيانات
class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // الحصول على قاعدة البيانات عبر singleton
        Database db = await DatabaseHelper.database;
        // استعلام للتحقق من بيانات الدخول
        List<Map<String, dynamic>> result = await db.query(
          'admin',
          where: 'username = ? AND password = ?',
          whereArgs: [_usernameController.text.trim(), _passwordController.text.trim()],
        );
        if (result.isNotEmpty) {
          // إذا كانت بيانات الدخول صحيحة، يتم الانتقال إلى شاشة الإدارة
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        } else {
          setState(() {
            errorMessage = "Invalid username or password";
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = "An error occurred. Please try again.";
        });
      }
    }
  }

 