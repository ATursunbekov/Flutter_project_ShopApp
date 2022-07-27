import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/products_grid.dart';

enum FilterOptions
{
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routName = '/products_overview';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> with TickerProviderStateMixin {

  List<Color> colorList = [
    Color(0xff171B70),
    Color(0xff410D75),
    Color(0xff032340),
    Color(0xff050340),
    Color(0xff2C0340),
  ];
  List<Alignment> alignmentList = [Alignment.topCenter, Alignment.bottomCenter];
  int index = 0;
  Color bottomColor = Color(0xff092646);
  Color topColor = Color(0xff410D75);
  Alignment begin = Alignment.bottomCenter;
  Alignment end = Alignment.topCenter;


  @override
  void initState() {
    super.initState();
    Timer(
      Duration(microseconds: 0),
          () {
        setState(
              () {
            bottomColor = Color(0xff33267C);
          },
        );
      },
    );
  }

  var _showOnlyFavorites = false;
  var isInit = true;
  var isLoading = false;

  @override
  void didChangeDependencies() {
    if (isInit)
      {
        setState(() {
          isLoading = true;
        });
        Provider.of<Products>(context).fetchAndSetData().then((value) => setState((){
          isLoading = false;
        }));
      }
    isInit = false;
    super.didChangeDependencies();
  }
  
  Future<void> refresh(BuildContext context) async 
  {
    await Provider.of<Products>(context).fetchAndSetData();
  }

  @override
  Widget build(BuildContext context) {
    final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0x44000000),
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites)
                {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            itemBuilder: (_) => [
            PopupMenuItem(child: Text('Only favorites'), value: FilterOptions.Favorites,),
            PopupMenuItem(child: Text('Show all'), value: FilterOptions.All,)
          ],
            icon: Icon(Icons.more_vert),),
          Consumer<Cart>(builder: (_, cart, ch) =>
              Badge(child: ch! , value: cart.itemCount.toString(), color: Colors.redAccent,),
            child: IconButton(icon: Icon(Icons.shopping_cart),
              onPressed: (){
              Navigator.of(context).pushNamed(CartScreen.routName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body:AnimatedContainer(
        child: Padding(
          padding: EdgeInsets.only(top: AppBar().preferredSize.height),
          child: isLoading ? Center(
            child: CircularProgressIndicator(),
          ) : RefreshIndicator(
              onRefresh: () => refresh(context),
              child: ProductsGrid(_showOnlyFavorites)),
        ),
        duration: Duration(seconds: 2),
        onEnd: () {
          setState(
                () {
              index = index + 1;
              bottomColor = colorList[index % colorList.length];
              topColor = colorList[(index + 1) % colorList.length];
            },
          );
        },
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: [bottomColor, topColor],
          ),
        ),
      ),
    );
  }
}