import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<String> _cartItems = [];
  final List<String> _orders = [];

  List<String> get cartItems => _cartItems;
  List<String> get orders => _orders;

  void addToCart(String item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void placeOrder() {
    _orders.addAll(_cartItems);
    _cartItems.clear();
    notifyListeners();
  }
}
