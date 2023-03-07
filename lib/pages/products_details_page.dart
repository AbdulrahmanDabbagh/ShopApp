import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';

class ProductDetailsPage extends StatelessWidget {
  static const routeName = '/product-details-page';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context).findeProduct(productId);
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(loadedProduct.title),
        // ),
        body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            // actionsIconTheme: ,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
            shadowColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  child: Text(loadedProduct.title)),
              // collapseMode: CollapseMode.parallax,
              background: Hero(
                tag: productId,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Text(
                  '\$ ${loadedProduct.price}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    loadedProduct.description,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 800,
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
