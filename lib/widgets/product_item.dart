import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';

import '../providers/cart.dart';
import '../pages/products_details_page.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final products = Provider.of<Products>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .pushNamed(ProductDetailsPage.routeName, arguments: product.id),
        child: GridTile(
            footer: GridTileBar(
              backgroundColor: Colors.black87,
              title: Text(product.title),
              leading: Consumer<Product>(
                builder: (ctx, product, child) {
                  return IconButton(
                    icon: Icon(
                      product.isFavorites
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      product.toggelFavorite(products.token, products.userId);
                    },
                  );
                },
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  cart.addItem(
                    product.id,
                    product.title,
                    product.price,
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added item to cart!'),
                      action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            cart.removeItem(product.id);
                          }),
                    ),
                  );
                },
              ),
            ),
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: const AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}
