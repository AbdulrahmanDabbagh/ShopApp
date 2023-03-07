import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> product;
  final DateTime dateTime;
  OrderItem({
    required this.id,
    required this.amount,
    required this.product,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String token;
  List<OrderItem> _orders = [];
  final String userId;
  Orders(this.token, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$token');
    final response = await http.get(url);
    List<OrderItem> loadedOrder = [];
    final extractOrder = json.decode(response.body) as Map<String, dynamic>?;
    if (extractOrder == null) {
      return;
    }
    extractOrder.forEach((orderId, orderData) {
      loadedOrder.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        product: (orderData['product'] as List<dynamic>).map((item) {
          return CartItem(
            id: item['id'],
            title: item['title'],
            price: item['price'],
            quantity: item['quantity'],
          );
        }).toList(),
      ));
    });
    _orders = loadedOrder.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> product, double total) async {
    final currentTime = DateTime.now();
    final url = Uri.parse(
        'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$token');
    await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': currentTime.toIso8601String(),
          'product': product.map((ci) {
            return {
              'id': ci.id,
              'title': ci.title,
              'price': ci.price,
              'quantity': ci.quantity,
            };
          }).toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        product: product,
        dateTime: currentTime,
      ),
    );
    notifyListeners();
  }
}
