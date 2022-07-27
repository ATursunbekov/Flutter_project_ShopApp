import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product extends ChangeNotifier
{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({required this.id,required this.title,required this.description,required this.price,required this.imageUrl,
    this.isFavorite = false});

  // void toggleFavoriteStatus()
  // {
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userID) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    if (id == null) {
      print('NOOOOOOOOOOOOOOOOOOOOOOOOO');
    }
    final url = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/userFavorites/$userID/$id.json?auth=$token');
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}