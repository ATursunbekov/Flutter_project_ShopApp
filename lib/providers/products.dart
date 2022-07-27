import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';
import 'package:shop_app/models/http_exeption.dart';
class Products with ChangeNotifier {//ChangeNotifier just allows to create communication tunnels between classes
  //with it allows kind a mix classes, I mean use only some properties of class without inheriting anything
  List<Product> _items = [];

  final String authToken;
  final String userId;


  Products(this.authToken,this.userId, this._items) {
    // if (authToken == '') {
    //   throw HttpException('TOKEN EQUAL TO NULL');
    // }
  }

  List<Product> get items{
       return [..._items];
  }

  List<Product> get favoriteItems
  {
    return [...items.where((element) => element.isFavorite).toList()];
  }

  Product findById(String id)
  {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetData([bool filterByUser = false]) async
  {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try{
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      final uri = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');

      final favoriteRes = await http.get(uri);
      final favoriteData = json.decode(favoriteRes.body);
      final List<Product> loadedData = [];
      extractedData.forEach((prodId, prodData) {
        loadedData.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
        _items = loadedData;
        notifyListeners();
      });
    } catch (err){
      throw(err);
    }
  }

  Future<void> addProduct(Product product) async
  {
    final url = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final res = await http.post(url, body: json.encode({
        'title' : product.title,
        'description' : product.description,
        'imageUrl' : product.imageUrl,
        'price' : product.price,
        'creatorId': userId,
      }));
      final newProduct = Product(
          id:   json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
    } catch (err){
      print(err);
      throw err;
    }
      notifyListeners();
      //return Future.value();
  }

  Future<void> updateProduct(String id, Product newProduct) async
  {
    final url = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    await http.patch(url, body: json.encode({
      'title' : newProduct.title,
      'description' : newProduct.description,
      'imageUrl' : newProduct.imageUrl,
      'price' : newProduct.price,
    }));
   final prodIndex = _items.indexWhere((element) => element.id == id);
   if (prodIndex >= 0)
     {
       _items[prodIndex] = newProduct;
       notifyListeners();
     } else {
     print('...');
   }
  }

  Future<void> deleteProduct(String id) async
  {
    final url = Uri.parse('https://shopapp-47610-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((e) => e.id == id);
    var existingProduct = _items[existingProductIndex];
    final res = await http.delete(url);
    _items.removeAt(existingProductIndex);
    notifyListeners();
      if (res.statusCode >= 400)
        {
          _items.insert(existingProductIndex, existingProduct);
          notifyListeners();
          throw HttpException('Could not delete product!');
        }
  }
}