import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/simple_button.dart';
import 'package:shop_app/widgets/user_pruct_item.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async
  {
    await Provider.of<Products>(context, listen: false).fetchAndSetData(true);
  }
  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          }, icon: Icon(Icons.add)),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx,snapshot) => snapshot.connectionState == ConnectionState.waiting ?
        Center(child: CircularProgressIndicator(),) :
        RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Consumer<Products>(
            builder: (ctx, productsData, _) => Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(itemCount: productsData.items.length,
                  itemBuilder: (_, index) => Column(
                    children: [
                      UserProductItem(
                          productsData.items[index].id,
                          productsData.items[index].title,
                          productsData.items[index].imageUrl),
                      Divider(),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
