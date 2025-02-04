import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

/// شاشة السلة مع عرض المنتجات المضافة وحساب الإجمالي
class CartScreen extends StatefulWidget {
  final String userName;
  CartScreen({required this.userName});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final items = await DatabaseHelper.getCartItems();
    setState(() {
      cartItems = items.map((item) {
        return {
          'id': item['id'] ?? 0,
          'name': item['name'] ?? "Unknown Product",
          'price': (item['price'] is num) ? item['price'].toDouble() : 0.0,
          'image': item['image'] ?? "https://via.placeholder.com/150",
          'quantity': item['quantity'] ?? 1,
        };
      }).toList();

      totalPrice = cartItems.fold(
          0, (sum, item) => sum + (item['price'] * item['quantity']));
    });
  }

  void removeFromCart(int productId) async {
    await DatabaseHelper.removeFromCart(productId);
    loadCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Item removed from cart")),
    );
  }

  void updateQuantity(int index, int newQuantity) async {
    if (newQuantity > 0) {
      setState(() {
        cartItems[index]['quantity'] = newQuantity;
        totalPrice = cartItems.fold(
            0, (sum, item) => sum + (item['price'] * item['quantity']));
      });
      // تحديث السعر إذا لزم الأمر عبر قاعدة البيانات
      await DatabaseHelper.updateProductPrice(
          cartItems[index]['id'], cartItems[index]['price']);
    }
  }

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
        title: Text("Cart - ${widget.userName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Image.network(
                          cartItems[index]['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey);
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItems[index]['name'],
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text("\$${cartItems[index]['price']}"),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if (cartItems[index]['quantity'] > 1) {
                                        updateQuantity(index,
                                            cartItems[index]['quantity'] - 1);
                                      }
                                    },
                                  ),
                                  Text(cartItems[index]['quantity'].toString()),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      updateQuantity(index,
                                          cartItems[index]['quantity'] + 1);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeFromCart(cartItems[index]['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total: \$${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(userName: widget.userName),
                      ),
                    );
                  },
                  child: Text("Checkout"),
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
