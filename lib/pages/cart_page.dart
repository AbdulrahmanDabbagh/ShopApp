import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class Cartpage extends StatelessWidget {
  static const routeName = '/cart';
  const Cartpage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(children: [
        Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    '\$ ${cart.totalPrice}',
                    style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.titleLarge!.color,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                OrderButton(cart: cart),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) => CartItem(
              id: cart.items.values.toList()[index].id,
              productId: cart.items.keys.toList()[index],
              title: cart.items.values.toList()[index].title,
              price: cart.items.values.toList()[index].price,
              quantity: cart.items.values.toList()[index].quantity,
            ),
            itemCount: cart.items.length,
          ),
        )
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cart.totalPrice <= 0 || _isloading)
            ? null
            : () async {
                setState(() {
                  _isloading = true;
                });
                await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(),
                  widget.cart.totalPrice,
                );
                widget.cart.clearCart();
                setState(() {
                  _isloading = false;
                });
              },
        child: _isloading
            ? const CircularProgressIndicator()
            : const Text('ORDER NOW'));
  }
}
