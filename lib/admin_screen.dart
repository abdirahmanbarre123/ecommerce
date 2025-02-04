import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login_screen.dart'; // تأكد من وجود ملف شاشة تسجيل الدخول

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminScreen(),
  ));
}

/// شاشة المدير (AdminScreen)
/// تعرض في هذه الشاشة قسمين:
/// 1- قائمة المنتجات مع إمكانية تعديل السعر أو حذف المنتج.
/// 2- جدول (DataTable) يعرض المدراء (Admin Users) مع إمكانية التعديل والحذف،
///    ويمكنك إضافة مدير جديد عبر نافذة الحوار.
class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> adminUsers = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadAdminUsers();
  }

  /// تحميل قائمة المنتجات من قاعدة البيانات
  Future<void> loadProducts() async {
    final db = await DatabaseHelper.database;
    final productList = await db.query('products');
    setState(() {
      products = productList;
    });
  }

  /// تحميل قائمة المدراء (Admin Users) من قاعدة البيانات
  Future<void> loadAdminUsers() async {
    final users = await DatabaseHelper.getAdminUsers();
    setState(() {
      adminUsers = users;
    });
  }

  // ----------------- إدارة المنتجات -----------------

  /// دالة لتعديل سعر المنتج
  void _editProductPrice(int id, double currentPrice) {
    TextEditingController priceController =
    TextEditingController(text: currentPrice.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Price"),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter new price"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              double newPrice =
                  double.tryParse(priceController.text) ?? currentPrice;
              await DatabaseHelper.updateProductPrice(id, newPrice);
              Navigator.pop(context);
              loadProducts();
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  /// دالة لحذف المنتج
  void _deleteProduct(int id) async {
    await DatabaseHelper.deleteProduct(id);
    loadProducts();
  }

  // ----------------- إدارة المدراء -----------------

  /// نافذة حوار لإضافة مدير جديد
  void _showAddAdminDialog() {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Admin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(hintText: "Enter username"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(hintText: "Enter password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String username = usernameController.text.trim();
              String password = passwordController.text.trim();
              if (username.isNotEmpty && password.isNotEmpty) {
                await DatabaseHelper.addAdmin({
                  'username': username,
                  'password': password,
                });
                Navigator.pop(context);
                loadAdminUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Admin user created successfully!")),
                );
              }
            },
            child: Text("Add"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  /// دالة لتعديل بيانات المدير
  void _editAdminUser(int id, String currentUsername, String currentPassword) {
    TextEditingController usernameController =
    TextEditingController(text: currentUsername);
    TextEditingController passwordController =
    TextEditingController(text: currentPassword);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Admin User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(hintText: "Enter username"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(hintText: "Enter password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String newUsername = usernameController.text.trim();
              String newPassword = passwordController.text.trim();
              if (newUsername.isNotEmpty && newPassword.isNotEmpty) {
                await DatabaseHelper.updateAdmin(id, newUsername, newPassword);
                Navigator.pop(context);
                loadAdminUsers();
              }
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  /// دالة لحذف المدير
  void _deleteAdminUser(int id) async {
    await DatabaseHelper.deleteAdmin(id);
    loadAdminUsers();
  }

  /// دالة لتسجيل الخروج والانتقال إلى شاشة تسجيل الدخول
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  