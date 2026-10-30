import 'package:flutter/material.dart';

import '../data/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _galleryController;
  int _activeImage = 0;
  bool _saved = false;
  bool _addedToBag = false;

  Product get product => widget.product;
  List<String> get _images => product.images.isEmpty
      ? (product.thumbnail.isEmpty ? const [] : [product.thumbnail])
      : product.images;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: _saved ? 'Remove from saved items' : 'Save item',
            onPressed: () => setState(() => _saved = !_saved),
            icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
            color: _saved ? Colors.redAccent : null,
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: SizedBox(
          height: 54,
          child: AnimatedScale(
            scale: _addedToBag ? 1.015 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: product.stock == 0
                    ? Colors.grey.shade400
                    : _addedToBag
                    ? const Color(0xFF247653)
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: product.stock > 0 && !_addedToBag
                      ? () => setState(() => _addedToBag = true)
                      : null,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: Row(
                        key: ValueKey(_addedToBag ? 'added' : 'add'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product.stock == 0
                                ? Icons.remove_shopping_cart_outlined
                                : _addedToBag
                                ? Icons.check_circle_outline
                                : Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            product.stock == 0
                                ? 'Out of stock'
                                : _addedToBag
                                ? 'Added to bag'
                                : 'Add to bag',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _gallery(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Pill(
                        label: product.category,
                        color: const Color(0xFFE5EDE5),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFE3A329),
                        size: 20,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
                  ),
                  if (product.brand.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'by ${product.brand}',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                      ),
                      if (product.discountPercentage > 0) ...[
                        const SizedBox(width: 12),
                        _Pill(
                          label:
                              '${product.discountPercentage.toStringAsFixed(0)}% off',
                          color: const Color(0xFFE5EDE5),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          product.stock > 0
                              ? Icons.check_circle_outline
                              : Icons.remove_circle_outline,
                          size: 20,
                          color: product.stock > 0
                              ? Colors.green.shade700
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.stock > 0
                              ? '${product.stock} available'
                              : 'Currently unavailable',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 19,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Ships soon',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'About this item',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gallery(BuildContext context) {
    final images = _images;
    return Container(
      height: 360,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1EB),
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (images.isEmpty)
            const Center(
              child: Icon(
                Icons.image_outlined,
                size: 64,
                color: Colors.black38,
              ),
            )
          else
            PageView.builder(
              controller: _galleryController,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _activeImage = index),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(22),
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 52,
                      color: Colors.black38,
                    ),
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 7,
                    width: index == _activeImage ? 20 : 7,
                    decoration: BoxDecoration(
                      color: index == _activeImage
                          ? const Color(0xFF315C4B)
                          : Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                product.stock > 0 ? 'In stock' : 'Sold out',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );
}
