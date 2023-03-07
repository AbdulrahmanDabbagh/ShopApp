import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/edit_product_page.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductsPage extends StatelessWidget {
  static const routeName = '/user-product';
  const UserProductsPage({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final providerData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Product'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductPage.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<Products>(
                    builder: (ctx, providerData, child) => ListView.builder(
                      itemBuilder: (_, index) => Column(
                        children: [
                          UserProductItem(
                            id: providerData.item[index].id,
                            title: providerData.item[index].title,
                            imageUrl: providerData.item[index].imageUrl,
                          ),
                          const Divider(),
                        ],
                      ),
                      itemCount: providerData.item.length,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
