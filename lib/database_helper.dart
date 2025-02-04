import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// كلاس مساعد للتعامل مع قاعدة البيانات باستخدام نمط الـ singleton
class DatabaseHelper {
  static Database? _database;

  /// getter لإرجاع قاعدة البيانات، إذا كانت موجودة يتم إرجاعها، وإلا يتم إنشاؤها
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// دالة لإنشاء وفتح قاعدة البيانات
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fashion_store.db');
    return openDatabase(
      path,
      version: 2, // رفع النسخة إلى 2
      onCreate: (db, version) async {
        // إنشاء جدول السلة
        await db.execute(
          "CREATE TABLE IF NOT EXISTS cart(id INTEGER PRIMARY KEY, name TEXT, price DOUBLE, quantity INTEGER, image TEXT);",
        );
        // إنشاء جدول المنتجات
        await db.execute(
          "CREATE TABLE IF NOT EXISTS products(id INTEGER PRIMARY KEY, name TEXT, price DOUBLE, image TEXT);",
        );
        // إنشاء جدول المدراء
        await db.execute(
          "CREATE TABLE IF NOT EXISTS admin(id INTEGER PRIMARY KEY, username TEXT, password TEXT);",
        );
        // إدخال مدير افتراضي
        await db.insert(
          'admin',
          {'username': 'admin', 'password': 'admin123'},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "CREATE TABLE IF NOT EXISTS admin(id INTEGER PRIMARY KEY, username TEXT, password TEXT);",
          );
          await db.insert(
            'admin',
            {'username': 'admin', 'password': 'admin123'},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      },
    );
  }

  /// دالة لإضافة منتج إلى جدول السلة (للاستخدام في وظائف أخرى)
  static Future<void> addToCart(Map<String, dynamic> product) async {
    final db = await database;
    await db.insert(
      'cart',
      {
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': product['quantity'] ?? 1,
        'image': product['image']
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// الحصول على عناصر السلة
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return db.query('cart');
  }

  /// إزالة عنصر من السلة
  static Future<void> removeFromCart(int id) async {
    final db = await database;
    await db.delete(
      'cart',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// تحديث سعر المنتج
  static Future<void> updateProductPrice(int id, double newPrice) async {
    final db = await database;
    await db.update(
      'products',
      {'price': newPrice},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// حذف المنتج
  static Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// إضافة مدير جديد
  static Future<void> addAdmin(Map<String, dynamic> adminUser) async {
    final db = await database;
    await db.insert(
      'admin',
      adminUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// تحديث بيانات المدير
  static Future<void> updateAdmin(
      int id, String username, String password) async {
    final db = await database;
    await db.update(
      'admin',
      {'username': username, 'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// حذف المدير
  static Future<void> deleteAdmin(int id) async {
    final db = await database;
    await db.delete(
      'admin',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// الحصول على قائمة المدراء
  static Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final db = await database;
    return db.query('admin');
  }
}
