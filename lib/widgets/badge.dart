import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String number;
  Color? color;

  Badge({
    super.key,
    required this.child,
    required this.number,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(2),
            height: 17,
            width: 15,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(
              minHeight: 16,
              minWidth: 16,
            ),
            child: Text(
              number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
