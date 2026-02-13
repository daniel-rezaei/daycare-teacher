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
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final imagePath = imageFile.path;

      // بررسی اینکه آیا تصویر از گالری داخلی آمده یا نه
      // اگر مسیر فایل در getApplicationDocumentsDirectory باشد، یعنی از گالری داخلی آمده
      if (imagePath.startsWith(dir.path) &&
          imagePath.endsWith('.jpg') &&
          !imagePath.endsWith('_thumb.jpg')) {
        // تصویر از گالری داخلی آمده، نیازی به ذخیره مجدد نیست
        return imagePath;
      }

      // تصویر از جای دیگری آمده (مثلاً دوربین یا cache موقت)، باید ذخیره شود
      final id = _uuid.v4();
      final originalPath = "${dir.path}/$id.jpg";
      final thumbPath = "${dir.path}/${id}_thumb.jpg";

      // کپی کردن فایل اصلی
      await imageFile.copy(originalPath);
      // ریفرش کردن کش
      PhotoCacheService.refresh();

      // ساخت thumbnail در پس‌زمینه (از فایل اصلی که کپی شده) - بدون await
      // این کار در پس‌زمینه انجام می‌شود و UI را block نمی‌کند
      _createThumbnail(originalPath, thumbPath);

      return originalPath;
    } catch (e) {
      return null;
    }
  }

  /// ساخت thumbnail در پس‌زمینه (در isolate جداگانه)
  static Future<void> _createThumbnail(
    String sourcePath,
    String thumbPath,
  ) async {
    // خواندن فایل در isolate اصلی (سریع است)
    final bytes = await File(sourcePath).readAsBytes();

    // پردازش تصویر در isolate جداگانه برای جلوگیری از block شدن UI
    final thumbnailBytes = await compute(_processThumbnail, bytes);

    if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
      await File(thumbPath).writeAsBytes(thumbnailBytes);
    }
  }

  /// پردازش thumbnail در isolate جداگانه
  static Uint8List? _processThumbnail(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image != null) {
        final resized = img.copyResize(image, width: 300);
        return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
      }
      return null;
    } catch (e) {
      return null;
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
