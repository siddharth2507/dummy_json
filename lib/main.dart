import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'data/api_client.dart';
import 'data/product.dart';
import 'data/product_repository.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';

void main() => runApp(const ShopApp());

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient(http.Client());
    const storage = FlutterSecureStorage();
    return MaterialApp(
      title: 'Daily Goods',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315C4B)),
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F7F2),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: SessionGate(api: api, storage: storage),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key, required this.api, required this.storage});
  final ApiClient api;
  final FlutterSecureStorage storage;

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  String? _token;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await widget.storage.read(key: 'accessToken');
    if (!mounted) return;
    setState(() {
      _token = token;
      _loading = false;
    });
  }

  Future<void> _signIn(String token) async {
    await widget.storage.write(key: 'accessToken', value: token);
    if (mounted) setState(() => _token = token);
  }

  Future<void> _signOut() async {
    await widget.storage.delete(key: 'accessToken');
    if (mounted) setState(() => _token = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_token == null) {
      return LoginScreen(api: widget.api, onSignedIn: _signIn);
    }
    return ProductsScreen(
      repository: ProductRepository(widget.api),
      onSignOut: _signOut,
    );
  }
}

// Shared detail route entry point for typed product navigation.
Product productFromJson(Map<String, dynamic> json) => Product.fromJson(json);
