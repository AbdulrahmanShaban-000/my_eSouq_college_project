
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/cart_controller.dart';
import 'package:zad/controllers/recent_orders_controller.dart';
import 'package:zad/screens/cart_page.dart';
import 'package:zad/screens/favourites_page.dart';
import 'package:zad/home/screens/home_page.dart';
import 'package:zad/screens/nav_bar.dart';
import 'package:zad/screens/profile_page.dart';
import 'package:zad/models/Product.dart';
import 'package:zad/product/mixins/rating_mixin.dart';
import 'package:zad/product/widgets/product_add_to_cart_button.dart';
import 'package:zad/product/widgets/product_image_slider.dart';
import 'package:zad/product/widgets/product_info_section.dart';
import 'package:zad/product/widgets/product_notes_section.dart';
import 'package:zad/product/widgets/product_quantity_section.dart';
import 'package:zad/product/widgets/product_rating_section.dart';
import 'package:zad/product/widgets/product_wishlist_button.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with RatingMixin {
  final CartController cartController = Get.find();
  final RecentOrdersController recentOrdersController = Get.find();

  final RxInt quantity = 1.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadRatings(widget.product.id);
    });
  }

  void _addToCart() {
    cartController.addToCart(widget.product, quantity.value);
    recentOrdersController.addOrder(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final product = widget.product;
    final displayImages = _getDisplayImages(product);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ]
                : [Colors.grey[50]!, Colors.grey[200]!, Colors.grey[300]!],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(theme, product, displayImages),
            _buildContent(theme, product),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => HomePage());
              break;
            case 1:
              Get.offAll(() => FavouritesPage());
              break;
            case 2:
              Get.offAll(() => CartPage());
              break;
            case 3:
              Get.offAll(() => ProfilePage());
              break;
          }
        },
      ),
    );
  }

  List<String> _getDisplayImages(Product product) {
    final imageUrls = product.images
        .map((image) => image.imagePath.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
    return imageUrls.isNotEmpty ? imageUrls : [product.getImageUrl()];
  }

  // ==================== APP BAR ====================
  SliverAppBar _buildAppBar(
    ThemeData theme,
    Product product,
    List<String> images,
  ) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => Get.back(),
      ),
      actions: [       
        ProductWishlistButton(product: product, size: 22, showLabel: false),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImageSlider(
          productId: product.id,
          images: images,
          heroTag: 'product_${product.id}',
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildContent(ThemeData theme, Product product) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            ProductInfoSection(product: product),

            const SizedBox(height: 20),

           
            ProductRatingSection(productId: product.id),

            const SizedBox(height: 20),

          
            const ProductNotesSection(),

            const SizedBox(height: 24),

       
            ProductQuantitySection(product: product, quantity: quantity),

            const SizedBox(height: 24),

        
            ProductAddToCartButton(product: product, onAddToCart: _addToCart),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
