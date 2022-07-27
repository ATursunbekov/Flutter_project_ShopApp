import 'package:flutter/foundation.dart';

class CartItem
{
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({required this.id,required this.title,this.quantity = 1,required this.price});
}

class Cart extends ChangeNotifier
{
  Map<String, CartItem> _items = {};

    Map<String, CartItem> get items
  {
    return {..._items};
  }

  int get itemCount
  {
    return _items.length;
  }

  double get totalAmount
  {
    double total = 0;
    _items.forEach((key, val) {
      total+= val.price * val.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title)
  {
    if(_items.containsKey(productId))
    {
      _items.update(productId, (value) => CartItem(id: value.id, title: value.title, price: price, quantity: value.quantity + 1));
    } else {
      _items.putIfAbsent(productId,() => CartItem(id: DateTime.now().toString(), title: title, price: price));
    }
    notifyListeners();
  }

  void removeItem(String productId)
  {
    _items.remove(productId);
    notifyListeners();
  }
  
  void removeSingleItem(String productId)
  {
    if(!_items.containsKey(productId))
      {
        return;
      }
    if(_items[productId]!.quantity > 1)
      {
        _items.update(productId, (val) => CartItem(id: val.id, title: val.title, price: val.price, quantity: val.quantity -1));
      }else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear()
  {
    _items = {};
    notifyListeners();
  }

}