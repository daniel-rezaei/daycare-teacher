import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:teacher_app/core/photo_cache_service.dart';

/// سرویس برای مدیریت گالری داخلی اپ
class GalleryService {
  static const _uuid = Uuid();

  /// ذخیره تصویر در گالری داخلی
  /// [imageFile]: فایل تصویر که باید ذخیره شود
  /// برمی‌گرداند: مسیر فایل اصلی ذخیره شده
  static Future<String?> saveImageToGallery(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        debugPrint('[GALLERY_SERVICE] Image file does not exist: ${imageFile.path}');
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final id = _uuid.v4();
      final originalPath = "${dir.path}/$id.jpg";
      final thumbPath = "${dir.path}/${id}_thumb.jpg";

      // کپی کردن فایل اصلی
      await imageFile.copy(originalPath);
      debugPrint('[GALLERY_SERVICE] Original image saved: $originalPath');

      // ساخت thumbnail در پس‌زمینه (از فایل اصلی که کپی شده)
      _createThumbnail(originalPath, thumbPath);

      // ریفرش کردن کش
      PhotoCacheService.refresh();

      return originalPath;
    } catch (e) {
      debugPrint('[GALLERY_SERVICE] Error saving image to gallery: $e');
      return null;
    }
  }

  /// ساخت thumbnail در پس‌زمینه
  static Future<void> _createThumbnail(String sourcePath, String thumbPath) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        final resized = img.copyResize(image, width: 300);
        await File(thumbPath).writeAsBytes(img.encodeJpg(resized, quality: 80));
        debugPrint('[GALLERY_SERVICE] Thumbnail created: $thumbPath');
      }
    } catch (e) {
      debugPrint('[GALLERY_SERVICE] Thumbnail creation failed: $e');
    }
  }

  /// بررسی اینکه آیا تصویر در گالری وجود دارد
  static Future<bool> isImageInGallery(String imagePath) async {
    try {
      final file = File(imagePath);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }
}

