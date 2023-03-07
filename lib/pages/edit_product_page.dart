import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class EditProductPage extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductPage({super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _priceFocesNode = FocusNode();
  final _descriptionFocesNode = FocusNode();
  final _imageTextController = TextEditingController();
  final _imageFocesNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var product = Product(
    id: DateTime.now().toString(),
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _init = true;
  var _editProduct = false;
  var _isLoading = false;

  @override
  void initState() {
    _imageFocesNode.addListener(_getUpdate);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_init == true) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final productId = ModalRoute.of(context)!.settings.arguments as String;
        product = Provider.of<Products>(context, listen: false)
            .findeProduct(productId);
        _editProduct = true;
        _imageTextController.text = product.imageUrl;
      }
      _init = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocesNode.removeListener(_getUpdate);
    _priceFocesNode.dispose();
    _descriptionFocesNode.dispose();
    _imageFocesNode.dispose();
    super.dispose();
  }

  void _getUpdate() {
    if (!_imageFocesNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();
    if (_editProduct == false) {
      try {
        await Provider.of<Products>(context, listen: false).addProduct(product);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('An Error Occured'),
                content: const Text('Something Went Wrong!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Okey'),
                  )
                ],
              );
            });
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    } else {
      _isLoading = true;
      await Provider.of<Products>(context, listen: false)
          .editProduct(product.id, product);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [IconButton(onPressed: _onSave, icon: const Icon(Icons.save))],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: product.title,
                        decoration: const InputDecoration(
                          label: Text('Title'),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) => FocusScope.of(context)
                            .requestFocus(_priceFocesNode),
                        onSaved: (value) {
                          product = Product(
                            id: product.id,
                            title: value!,
                            description: product.description,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            isFavorites: product.isFavorites,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a Title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: product.price.toString(),
                        decoration: const InputDecoration(label: Text('Price')),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocesNode,
                        onFieldSubmitted: (value) => FocusScope.of(context)
                            .requestFocus(_descriptionFocesNode),
                        onSaved: (value) {
                          product = Product(
                            id: product.id,
                            title: product.title,
                            description: product.description,
                            price: double.parse(value!),
                            imageUrl: product.imageUrl,
                            isFavorites: product.isFavorites,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a Price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid Price.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Enter Price > 0.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: product.description,
                        decoration:
                            const InputDecoration(label: Text('Description')),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        focusNode: _descriptionFocesNode,
                        onSaved: (value) {
                          product = Product(
                            id: product.id,
                            title: product.title,
                            description: value!,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            isFavorites: product.isFavorites,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a Description.';
                          }
                          if (value.length < 10) {
                            return 'Enter Longer Description.';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8, top: 10),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageTextController.text.isNotEmpty
                                ? Image.network(_imageTextController.text)
                                : const Text('Input Url'),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  label: Text('Image Url')),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              controller: _imageTextController,
                              focusNode: _imageFocesNode,
                              onSaved: (value) {
                                product = Product(
                                  id: product.id,
                                  title: product.title,
                                  description: product.description,
                                  price: product.price,
                                  imageUrl: value!,
                                  isFavorites: product.isFavorites,
                                );
                              },
                              onFieldSubmitted: (value) {
                                _onSave();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter an Image Url.';
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
