import 'package:zad/core/api/end_points.dart';

class ProductImage {
  final int id;
  final String imagePath;
  final String? altText;
  final String? imageableType;
  final int? imageableId;

  const ProductImage({
    required this.id,
    required this.imagePath,
    this.altText,
    this.imageableType,
    this.imageableId,
  });

  static String normalizeImagePath(String? rawPath) {
    final serverBase = EndPoints.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    rawPath = rawPath?.toString().trim();

    if (rawPath == null || rawPath.isEmpty) {
      return '$serverBase/storage/default-product.jpg';
    }

    if (rawPath.startsWith('http')) {
      return rawPath;
    }

    if (rawPath.startsWith('/')) {
      return '$serverBase$rawPath';
    }

    return '$serverBase/$rawPath';
  }

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    String? rawPath = json['image_path']?.toString().trim();

    rawPath ??= json['imageUrl']?.toString().trim();
    rawPath ??= json['image_url']?.toString().trim();
    rawPath ??= json['url']?.toString().trim();
    rawPath ??= json['path']?.toString().trim();
    rawPath ??= json['src']?.toString().trim();
    rawPath ??= json['thumbnail']?.toString().trim();
    rawPath ??= json['file_path']?.toString().trim();

    final normalizedPath = normalizeImagePath(rawPath);
    print('ProductImage created - ID: ${json['id']}, Path: $normalizedPath');

    return ProductImage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imagePath: normalizedPath,
      altText: json['alt_text']?.toString(),
      imageableType: json['imageable_type']?.toString(),
      imageableId: (json['imageable_id'] as num?)?.toInt(),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final int isActive;
  final String? sku;
  final String? slug;
  final List<ProductImage> images;
  final List<int> categoryIds;

  int get categoryId => categoryIds.isNotEmpty ? categoryIds.first : 0;

  Product({
    required this.id,
    required this.name,
    this.categoryIds = const [],
    this.description,
    required this.price,
    required this.stock,
    required this.isActive,
    this.sku,
    this.slug,
    this.images = const [],
  });

  String getImageUrl() {
    for (final image in images) {
      final path = image.imagePath.trim();
      if (path.isNotEmpty && path != '') return path;
    }

    return 'https://via.placeholder.com/300x300?text=No+Image';
  }

  bool hasValidImage() {
    if (images.isNotEmpty) {
      final firstImage = images.first.imagePath.trim();
      return firstImage.isNotEmpty && firstImage != '';
    }
    return false;
  }

  bool hasImage() {
    return images.isNotEmpty && images.first.imagePath.isNotEmpty;
  }

  static List<int> _extractCategoryIds(Map<String, dynamic> json) {
    final ids = <int>{};

    void addId(dynamic value) {
      if (value == null) return;

      if (value is num) {
        ids.add(value.toInt());
        return;
      }

      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) ids.add(parsed);
        return;
      }

      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final rawId =
            map['id'] ??
            map['category_id'] ??
            map['categoryId'] ??
            map['cat_id'];

        if (rawId != null) {
          if (rawId is num) {
            ids.add(rawId.toInt());
          } else if (rawId is String) {
            final parsed = int.tryParse(rawId);
            if (parsed != null) ids.add(parsed);
          }
        }
        return;
      }

      if (value is List) {
        for (final item in value) {
          addId(item);
        }
      }
    }

    final candidates = [
      json['category_id'],
      json['categoryId'],
      json['cat_id'],
      json['category'],
      json['categories'],
      json['category_ids'],
      json['categories_ids'],
    ];

    for (final candidate in candidates) {
      addId(candidate);
    }

    if (ids.isEmpty && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      for (final candidate in [
        data['category_id'],
        data['category'],
        data['categories'],
      ]) {
        addId(candidate);
      }
    }

    return ids.toList();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    print('Product.fromJson called for product ID: ${json['id']}');
    print('Raw JSON: $json');

    final imagesJson = json['images'];
    final parsedImages = <ProductImage>[];

    if (imagesJson is List && imagesJson.isNotEmpty) {
      print('Found ${imagesJson.length} images in response');
      for (final imageEntry in imagesJson) {
        if (imageEntry is Map) {
          parsedImages.add(
            ProductImage.fromJson(Map<String, dynamic>.from(imageEntry)),
          );
        } else if (imageEntry is String && imageEntry.isNotEmpty) {
          parsedImages.add(
            ProductImage.fromJson({
              'image_path': imageEntry,
              'id': json['id'] ?? 0,
            }),
          );
        }
      }
    } else if (imagesJson is Map) {
      final imagesMap = Map<String, dynamic>.from(imagesJson);
      if (imagesMap['data'] is List && (imagesMap['data'] as List).isNotEmpty) {
        print('Found nested images.data list in response');
        for (final imageEntry in imagesMap['data'] as List) {
          if (imageEntry is Map) {
            parsedImages.add(
              ProductImage.fromJson(Map<String, dynamic>.from(imageEntry)),
            );
          } else if (imageEntry is String && imageEntry.isNotEmpty) {
            parsedImages.add(
              ProductImage.fromJson({
                'image_path': imageEntry,
                'id': json['id'] ?? 0,
              }),
            );
          }
        }
      } else {
        print('Found single image object in response');
        parsedImages.add(ProductImage.fromJson(imagesMap));
      }
    } else if (imagesJson is String && imagesJson.isNotEmpty) {
      parsedImages.add(
        ProductImage.fromJson({
          'image_path': imagesJson,
          'id': json['id'] ?? 0,
        }),
      );
    } else {
      print(
        'No images array in response or empty for product ID: ${json['id']}',
      );
    }

    return Product(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: double.parse(json['price']?.toString() ?? '0'),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == 1 ? 1 : 0,
      sku: json['sku']?.toString(),
      slug: json['slug']?.toString(),
      images: parsedImages,
      categoryIds: _extractCategoryIds(json),
    );
  }
}

/*

*/
