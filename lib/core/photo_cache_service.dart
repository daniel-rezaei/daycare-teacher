import 'dart:io';

class PhotoCacheService {
  static List<File>? _cachedPhotos;

  /// برمی‌گرداند: لیست عکس‌ها – از کش اگر موجود باشد
  static Future<List<File>> loadPhotos(String folderPath) async {
    if (_cachedPhotos != null) {
      return _cachedPhotos!;
    }

    final dir = Directory(folderPath);
    if (!dir.existsSync()) return [];

    final files = dir
        .listSync()
        .where((f) => f is File && f.path.endsWith(".jpg"))
        .map((f) => File(f.path))
        .toList();

    _cachedPhotos = files;
    return files;
  }

  /// وقتی عکس جدید ذخیره شد، کش را ریست کنید
  static void refresh() {
    _cachedPhotos = null;
  }
}
