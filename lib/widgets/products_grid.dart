import 'package:flutter/material.dart';
import 'package:shop_app/widgets/product_item.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;


  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFavs ? productData.favoriteItems :  productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3/2,
          crossAxisSpacing: 10, mainAxisSpacing: 10
      ),
    );
  }
}
