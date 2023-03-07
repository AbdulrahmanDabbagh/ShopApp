import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/auth_page.dart';
import 'package:shop/pages/splash_page.dart';
import 'package:shop/providers/auth.dart';

import '../pages/cart_page.dart';
import '../pages/edit_product_page.dart';
import '../pages/orders_page.dart';
import '../pages/user_products_page.dart';
import '../providers/cart.dart';
import '../pages/products_details_page.dart';
import '../providers/orders.dart';
import './pages/products_overview_page.dart';
import './providers/products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData theme = ThemeData(
    primarySwatch: Colors.purple,
    fontFamily: 'Lato',
    // primaryTextTheme: TextTheme(),
  );

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    print('mutiprovider');
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products('', [], ''),
            update: (context, auth, previousProducts) => Products(
              auth.token ?? '',
              previousProducts == null ? [] : previousProducts.item,
              auth.userId ?? '',
            ),
          ),
          ChangeNotifierProvider(create: (_) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders('', [], ''),
            update: (context, auth, previousOrders) => Orders(
              auth.token ?? '',
              previousOrders == null ? [] : previousOrders.orders,
              auth.userId ?? '',
            ),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, child) => MaterialApp(
            title: 'Shop',
            theme: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                secondary: Colors.deepOrange,
              ),
            ),
            home: auth.isAuth
                ? const ProductOverviewPage()
                : FutureBuilder(
                    future: auth.autoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? const SplashPage()
                            : const AuthPage()),
            debugShowCheckedModeBanner: false,
            routes: {
              ProductDetailsPage.routeName: (context) => ProductDetailsPage(),
              Cartpage.routeName: (context) => const Cartpage(),
              OrdersPage.routeName: (context) => OrdersPage(),
              UserProductsPage.routeName: (context) => const UserProductsPage(),
              EditProductPage.routeName: (context) => const EditProductPage(),
            },
          ),
        ));
  }
}
