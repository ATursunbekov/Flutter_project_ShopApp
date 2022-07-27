import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import 'providers/products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  Auth auth = Auth();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (ctx) => Auth(),
      ),
      ChangeNotifierProxyProvider<Auth, Products>(update: (ctx, auth,prevProduct) =>
          Products(auth.token,auth.userId ,prevProduct == null ? [] : prevProduct.items), create: (ctx) => Products('','', [])),
      ChangeNotifierProvider( //It is one of the types of Provider
        create: (ctx) =>Cart(),),
      //ChangeNotifierProvider(create: (ctx) => Orders()),
      ChangeNotifierProxyProvider<Auth, Orders>(create: (ctx) => Orders([], '', ''),
          update: (ctx, auth, prevOrders) => Orders(prevOrders == null ? [] : prevOrders.orders, auth.token, auth.userId)),
    ], //Creating instance of class Products
      child: Consumer<Auth>(builder: (ctx, auth, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        home: auth.isAuth ? ProductsOverviewScreen() : FutureBuilder(future: auth.tryAutoLogin(), builder: (ctx, authResSnapshot) =>
            authResSnapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),),
        routes: {
          ProductsOverviewScreen.routName: (ctx) => ProductsOverviewScreen(),
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routName: (ctx) => CartScreen(),
          OrdersScreen.routName: (ctx) => OrdersScreen(),
          UserProductScreen.routeName: (ctx) => UserProductScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),),
    );
  }
}
