import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'cart_screen.dart';
import 'login_screen.dart'; // إضافة الاستيراد هنا

/// شاشة عرض المنتجات للمستخدم العادي، يتم تمرير اسم المستخدم ليظهر في AppBar
class ProductListScreen extends StatefulWidget {
  final String userName;
  ProductListScreen({required this.userName});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List products = [];
  Map<int, int> productQuantities = {}; // لتخزين الكميات لكل منتج
  bool isLoading = true;
  final String apiUrl = 'https://fakestoreapi.com/products';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /// تحميل المنتجات من API
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            products = data;
            isLoading = false;
          });
        } else {
          setState(() {
            products = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          products = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        products = [];
        isLoading = false;
      });
    }
  }

  /// إضافة المنتج إلى السلة
  void addToCart(int productId) async {
    var product = products.firstWhere((p) => p['id'] == productId);
    int quantity = productQuantities[productId] ?? 1;

    await DatabaseHelper.addToCart({
      'id': product['id'],
      'name': product['title'],
      'price': product['price'],
      'image': product['image'],
      'quantity': quantity,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product['title']} added to cart!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void increaseQuantity(int productId) {
    setState(() {
      productQuantities[productId] = (productQuantities[productId] ?? 1) + 1;
    });
  }

  void decreaseQuantity(int productId) {
    setState(() {
      if (productQuantities[productId] != null && productQuantities[productId]! > 1) {
        productQuantities[productId] = productQuantities[productId]! - 1;
      }
    });
  }

  // زر تسجيل الخروج يقوم بالعودة إلى شاشة الدخول الرئيسية
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
      // خلفية متدرجة للشاشة
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade200, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar مخصص مع خلفية شفافة
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Products",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                      tooltip: "Logout",
                    )
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : products.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No products available",
                        style: TextStyle(
                            fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchProducts,
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.blue),
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    int productId = products[index]['id'];
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                products[index]['image'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    height: 180,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              products[index]['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Text(
                              "\$${products[index]['price']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      decreaseQuantity(productId),
                                ),
                                Text(
                                  productQuantities[productId]
                                      ?.toString() ??
                                      "1",
                                  style: TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      increaseQuantity(productId),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  addToCart(productId),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                                onPrimary: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Add to Cart",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // زر أسفل الشاشة للانتقال إلى شاشة السلة
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CartScreen(userName: widget.userName),
              ),
            );
          },
          icon: Icon(Icons.shopping_cart),
          label: Text("Go to Cart", style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
