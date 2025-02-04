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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _showAddAdminDialog,
            tooltip: "Add Admin User",
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم عرض المنتجات
            Text(
              "Products",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            products.isEmpty
                ? Center(child: Text("No Products Available"))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(products[index]['name']),
                    subtitle: Text(
                        "Price: \$${products[index]['price'].toString()}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editProductPrice(
                            products[index]['id'],
                            products[index]['price'],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteProduct(products[index]['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            // قسم عرض المدراء في جدول
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Admin Users",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddAdminDialog,
                  icon: Icon(Icons.person_add),
                  label: Text("Add Admin"),
                ),
              ],
            ),
            Divider(),
            adminUsers.isEmpty
                ? Center(child: Text("No Admin Users Available"))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Username")),
                  DataColumn(label: Text("Password")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: adminUsers.map((admin) {
                  return DataRow(
                    cells: [
                      DataCell(Text(admin['id'].toString())),
                      DataCell(Text(admin['username'])),
                      DataCell(Text(admin['password'])),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editAdminUser(
                                admin['id'],
                                admin['username'],
                                admin['password'],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteAdminUser(admin['id']),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
