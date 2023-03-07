import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersPage extends StatefulWidget {
  static const routeName = '/order';

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future _futureOrder;

  Future _obtainOrder(){
    return Provider.of<Orders>(context, listen: false).fetchOrders();
  }
  @override
  void initState() {
    _futureOrder = _obtainOrder();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _futureOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return const Center(child: Text('An Error Accured'));
          } else {
            return Consumer<Orders>(
              builder: (context, orderData, child) {
                return ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, index) =>
                      OrderItem(orderData.orders[index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
