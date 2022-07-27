import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem
{
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({required this.id,required this.amount,required this.products,required this.dateTime});
}

class Orders with ChangeNotifier
{
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;


  Orders(this._orders, this.authToken, this.userId);

  List<OrderItem> get orders{
    return [..._orders];
  } 

  Future<void> fetchAndSetData() async
  {
    final url = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final res = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(res.body) as Map<String, dynamic>;
    if (extractedData == null)
      {
        return;
      }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>).map((e) => CartItem(id: e['id'], title: e['title'],
            price: e['price'], quantity: e['quantity'])).toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async
  {
    final url = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    final res = await http.post(url, body: json.encode({
      'amount' : total,
      'dateTime' : timestamp.toIso8601String(),
      'products' : cartProducts.map((e) => {
        'id' : e.id,
        'title' : e.title,
        'quantity' : e.quantity,
        'price' : e.price
      }).toList(),
    }),);
    _orders.insert(0, OrderItem(id: json.decode(res.body)['name'],
        amount: total,
        products: cartProducts, dateTime: DateTime.now()));
    notifyListeners();
  }
}