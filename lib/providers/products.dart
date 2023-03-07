import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String token;
  final String userId;
  Products(this.token, this._items, this.userId);

  List<Product> get item {
    return [..._items];
  }

  List<Product> favoriteProduct() {
    return _items.where((product) => product.isFavorites).toList();
  }

  Product findeProduct(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$token&$filterString');
    try {
      final response = await http.get(url);
      url = Uri.parse(
          'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$token');
      final productsData = json.decode(response.body) as Map<String, dynamic>;
      final favoritesResponse = await http.get(url);
      final favoritesData = json.decode(favoritesResponse.body);
      final List<Product> loadedProduct = [];
      productsData.forEach((productId, productData) {
        loadedProduct.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorites:
              favoritesData == null ? false : favoritesData[productId] ?? false,
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$token');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          }));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> editProduct(String productId, Product editedProduct) async {
    final productIndex = _items.indexWhere((pro) => pro.id == productId);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/products/$productId.json?auth=$token');
      await http.patch(
        url,
        body: json.encode({
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price,
          'imageUrl': editedProduct.imageUrl,
        }),
      );
      _items[productIndex] = editedProduct;
    } else {
      print('....');
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    final url = Uri.parse(
        'https://shop-app-data-base-default-rtdb.europe-west1.firebasedatabase.app/products/$productId.json?auth=$token');
    final existingProductIndex =
        _items.indexWhere((prod) => prod.id == productId);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw const HttpException('Could Not Delete The Product!');
    }
    existingProduct = null;
  }
}
