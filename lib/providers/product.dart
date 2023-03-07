import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorites;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorites = false,
  });

  void _isFavValue(oldState) {
    isFavorites = oldState;
    notifyListeners();
  }

  Future<void> toggelFavorite(String token, String userId) async {
    final url = Uri.parse(
        'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');
    final oldState = isFavorites;
    isFavorites = !isFavorites;
    notifyListeners();
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorites,
          ));
      if (response.statusCode >= 400) {
        _isFavValue(oldState);
      }
    } catch (error) {
      _isFavValue(oldState);
    }
  }
}
