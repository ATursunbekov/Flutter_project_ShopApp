import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart' ;
import 'package:shop_app/widgets/order_item.dart' as items;

import '../providers/orders.dart';

class OrdersScreen extends StatefulWidget {
  static const routName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body:FutureBuilder(future: Provider.of<Orders>(context, listen: false).fetchAndSetData(),
      builder: (ctx, dataSnapshot) {
        if(dataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(),);
        } else if (dataSnapshot.error != null) {
          return Center(
            child: Text('Error has occured'),
          );
        } else {
          return Consumer<Orders>(builder: (ctx, orderData, child) => ListView.builder(itemCount: orderData.orders.length,
              itemBuilder: (_, index) => items.OrderItem(orderData.orders.toList()[index])),
          );
        }
      },
      )
    );
  }
}
