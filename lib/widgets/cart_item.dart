import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;
  const CartItem({
    super.key,
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).deleteItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('ARE YOU SURE?'),
              content: const Text('Do you want to delete this item ?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                    child: const Text('Yes')),
              ],
            );
          },
        );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 15,
        ),
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.error,
        child: const Padding(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 15,
        ),
        child: ListTile(
          leading: CircleAvatar(
              child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FittedBox(child: Text('\$$price')),
          )),
          title: Text(title),
          subtitle: Text('\$${(price * quantity)}'),
          trailing: Text('$quantity x'),
        ),
      ),
    );
  }
}
