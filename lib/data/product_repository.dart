import 'api_client.dart';
import 'product.dart';

class ProductPage {
  const ProductPage({required this.products, required this.total});
  final List<Product> products;
  final int total;
}

class ProductRepository {
  ProductRepository(this._api);
  final ApiClient _api;

  Future<ProductPage> fetchProducts({required int skip, int limit = 20}) async {
    final json = await _api.get('/products?limit=$limit&skip=$skip');
    final products = (json['products'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
    return ProductPage(
      products: products,
      total: json['total'] as int? ?? products.length,
    );
  }
}
