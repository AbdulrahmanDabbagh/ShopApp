import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/http_exception.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { Singup, Login }

class AuthPage extends StatelessWidget {
  static const routeName = '/auth';
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // width: deviceData.width,
            // height: deviceData.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                    const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                    Colors.red
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0, 0.5, 1]),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: deviceData.width,
              height: deviceData.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 94),
                      transform: Matrix4.rotationZ(-0 * pi / 180)
                        ..translate(-0.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          // BoxShadow(
                          //     blurRadius: 8,
                          //     color: Colors.black26,
                          //     offset: Offset(0, 2))
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          shadows: [
                            Shadow(
                                blurRadius: 30,
                                color: Colors.black26,
                                offset: Offset(0, 2))
                          ],
                          color: Colors.deepOrange.shade900,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceData.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  bool _isloading = false;
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _animationOffset;
  late Animation<double> _animationOpacity;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationOffset =
        Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    // _animationController.addListener(() => setState(() {}));
    _animationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    // _animationController.dispose();
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Singup;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    }
  }

  void _errorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          title: Text('An Error Accure'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okey'))
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isloading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
            _authData['email'] as String, _authData['password'] as String);
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'] as String, _authData['password'] as String);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed.';
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Coudl not find a user with that email.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _errorDialog(errorMessage);
    } catch (error) {
      // print(error);
      var errorMessage = error.toString();
      // var errorMessage = 'Could not authenticate you.\nPlease try again later.';
      _errorDialog(errorMessage);
    }
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        height: _authMode == AuthMode.Login ? 280 : 340,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Login ? 280 : 340,
        ),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Invalid Email !';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['email'] = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5) {
                    return 'Password is too short !';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['password'] = value!;
                },
              ),
              AnimatedContainer(
                padding: EdgeInsets.only(top: 10),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                constraints: BoxConstraints(
                  maxHeight: _authMode == AuthMode.Singup ? 120 : 0,
                  minHeight: _authMode == AuthMode.Singup ? 60 : 0,
                ),
                child: FadeTransition(
                  opacity: _animationOpacity,
                  child: SlideTransition(
                    position: _animationOffset,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Singup,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                      ),
                      obscureText: true,
                      validator: _authMode == AuthMode.Singup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isloading)
                const CircularProgressIndicator()
              else
                Container(
                  // margin: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 8),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor:
                          Theme.of(context).primaryTextTheme.labelLarge!.color,
                    ),
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGNUP'),
                  ),
                ),
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'Signup' : 'Login'} Instead'),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
