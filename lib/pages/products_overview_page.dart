import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/cart_page.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/app_drawer.dart';

import '../widgets/product_grid_view.dart';
import '../widgets/badge.dart' as me;

enum FiltersOptions {
  favorite,
  all,
}

class ProductOverviewPage extends StatefulWidget {
  const ProductOverviewPage({super.key});

  @override
  State<ProductOverviewPage> createState() => _ProductOverviewPageState();
}

class _ProductOverviewPageState extends State<ProductOverviewPage> {
  bool _showOnlyFavorites = false;
  bool _init = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies(){
    if(_init){
      _isLoading=true;
      Provider.of<Products>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading=false;
        });
      });
    }
    _init=false;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Myshop'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == FiltersOptions.favorite) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            child: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Favorites'),
                  value: FiltersOptions.favorite,
                ),
                PopupMenuItem(
                  child: Text('All'),
                  value: FiltersOptions.all,
                )
              ];
            },
          ),
          Consumer<Cart>(
            builder: (context, cart, child) {
              return me.Badge(
                number: cart.itemsCount.toString(),
                child: child!,
              );
            },
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(Cartpage.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading? const Center(child: CircularProgressIndicator(),) : ProductGridView(_showOnlyFavorites),
    );
  }
}
