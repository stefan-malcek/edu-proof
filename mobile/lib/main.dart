import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final appAuth = FlutterAppAuth();

  Object? _idToken;

  Future<void> _callAzureDefaultView() async {
    try {
      final AuthorizationTokenRequest request = AuthorizationTokenRequest(
        'c00aa7fb-c8d3-4e49-b29a-05f454896e0a',
        'com.example.eduproof://oauthredirect',
        discoveryUrl:
            'https://eduproofofconcept.b2clogin.com/eduproofofconcept.onmicrosoft.com/v2.0/.well-known/openid-configuration?p=B2C_1_susi',
        scopes: ['openid', 'profile', 'email', 'offline_access'],
        promptValues: ['login'],
      );
      final result = await appAuth.authorizeAndExchangeCode(request);
      setState(() {
        _idToken = _decodeToken(result?.idToken);
        print(_formatJson(_idToken));
      });
    } catch (e) {
      print(e);
    }
  }

  String? _decodeToken(String? token) {
    if (token == null) {
      return null;
    }

    final parts = token.split('.');
    final payload = parts[1];
    return B64urlEncRfc7515.decodeUtf8(payload);
  }

  String? _formatJson(Object? data) {
    if (data == null) {
      return null;
    }
    var encoder = const JsonEncoder.withIndent("     ");
    return encoder.convert(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Azure AD B2C Default View'),
              onPressed: _callAzureDefaultView,
            ),
            const Text(
              'User data',
            ),
            Text(
              '$_idToken',
            ),
          ],
        ),
      ),
    );
  }
}
