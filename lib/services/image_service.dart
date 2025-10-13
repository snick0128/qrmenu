import 'package:flutter/material.dart';

class ImageService {
  static const String _imageKitBaseUrl = 'https://ik.imagekit.io/YOUR_IMAGEKIT_ID';
  
  // Generate ImageKit URL with transformations
  static String getOptimizedImageUrl({
    required String imagePath,
    int? width,
    int? height,
    BoxFit? fit,
    int? quality,
  }) {
    if (!imagePath.startsWith('http')) {
      imagePath = '$_imageKitBaseUrl/$imagePath';
    }

    final List<String> transformations = [];

    if (width != null) transformations.add('w-$width');
    if (height != null) transformations.add('h-$height');
    if (fit != null) {
      switch (fit) {
        case BoxFit.cover:
          transformations.add('c-maintain_ratio');
          break;
        case BoxFit.contain:
          transformations.add('c-at_max');
          break;
        case BoxFit.fill:
          transformations.add('c-force');
          break;
        default:
          transformations.add('c-maintain_ratio');
      }
    }
    if (quality != null) transformations.add('q-$quality');

    // Add default optimizations
    transformations.add('f-auto'); // Auto format selection
    transformations.add('lo-true'); // Enable lazy loading

    if (transformations.isNotEmpty) {
      final transformationString = transformations.join(',');
      return '$imagePath?tr=$transformationString';
    }

    return imagePath;
  }

  // Get thumbnail URL
  static String getThumbnailUrl(String imagePath) {
    return getOptimizedImageUrl(
      imagePath: imagePath,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      quality: 80,
    );
  }

  // Get high-quality image URL
  static String getHighQualityImageUrl(String imagePath) {
    return getOptimizedImageUrl(
      imagePath: imagePath,
      quality: 90,
    );
  }

  // Get low-quality placeholder URL for progressive loading
  static String getPlaceholderUrl(String imagePath) {
    return getOptimizedImageUrl(
      imagePath: imagePath,
      width: 50,
      height: 50,
      quality: 30,
      fit: BoxFit.cover,
    );
  }
}