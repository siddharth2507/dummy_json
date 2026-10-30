import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/product.dart';
import '../data/product_repository.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    required this.repository,
    required this.onSignOut,
  });
  final ProductRepository repository;
  final Future<void> Function() onSignOut;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _scroll = ScrollController();
  final List<Product> _products = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _total = 0;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 420) _loadMore();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _error = null;
      _products.clear();
    });
    try {
      final page = await widget.repository.fetchProducts(
        skip: 0,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _products.addAll(page.products);
        _total = page.total;
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ApiException
              ? error.message
              : 'Could not load products. Check your connection.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading ||
        _loadingMore ||
        _products.isEmpty ||
        _products.length >= _total) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final page = await widget.repository.fetchProducts(
        skip: _products.length,
        limit: _pageSize,
      );
      if (mounted) {
        setState(() {
          _products.addAll(page.products);
          _total = page.total;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ApiException
                  ? error.message
                  : 'Could not load more products.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Goods',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'A little something for every day',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _MessageState(
              icon: Icons.wifi_off_outlined,
              title: 'Couldn’t load products',
              message: _error!,
              action: 'Try again',
              onAction: _loadFirstPage,
            )
          : _products.isEmpty
          ? const _MessageState(
              icon: Icons.inventory_2_outlined,
              title: 'Nothing here yet',
              message: 'There are no products to show.',
            )
          : RefreshIndicator(
              onRefresh: _loadFirstPage,
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    sliver: SliverToBoxAdapter(
                      child: _WelcomeBanner(total: _total),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The collection',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Useful finds, picked for you',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EDE5),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              '$_total items',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverGrid.builder(
                      itemCount: _products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: .67,
                          ),
                      itemBuilder: (context, index) => _ProductCard(
                        product: _products[index],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: _products[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: _loadingMore
                            ? const CircularProgressIndicator()
                            : Text(
                                '${_products.length} of $_total products',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.total});
  final int total;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFFE5EDE5),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find your\neveryday favorite.',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
              ),
              const SizedBox(height: 8),
              Text(
                '$total thoughtfully picked finds',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.local_mall_outlined,
          size: 54,
          color: Color(0xFF315C4B),
        ),
      ],
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: const Color(0xFFF0F1EB),
                  padding: const EdgeInsets.all(8),
                  child: product.thumbnail.isEmpty
                      ? const Icon(Icons.image_outlined, size: 40)
                      : Image.network(
                          product.thumbnail,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 34,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFE3A329),
                    ),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.black38),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          if (action != null) ...[
            const SizedBox(height: 18),
            FilledButton.tonal(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    ),
  );
}
