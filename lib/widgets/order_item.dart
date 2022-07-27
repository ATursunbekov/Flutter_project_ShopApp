import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/providers/orders.dart' as item;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final item.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(DateFormat('dd/MM/yyyy hh::mm').format(widget.order.dateTime)),
            trailing: IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: (){
              setState(() {
                _expanded = ! _expanded;
              });
              },
            ),
          ),
          if (_expanded) Container(
            height: min(widget.order.products.length * 20 + 10, 100),
            padding: EdgeInsets.all(10),
            child: ListView(
              children: widget.order.products.map((e) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                children: [
                  Text(e.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  Text('${e.quantity}x \$${e.price}', style: TextStyle(fontSize: 18, color: Colors.grey),)
                ],
              )).toList(),
            ),
          )
        ],
      ),
    );
  }
}
