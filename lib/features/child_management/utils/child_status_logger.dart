import 'package:flutter/foundation.dart';

/// تگ یکسان برای فیلتر لاگ‌های صفحه Child Status در logcat (جستجو: ChildStatus)
const String kChildStatusLogTag = '[ChildStatus]';

void childStatusLog(String message, {bool isError = false}) {
  final prefix = isError ? 'ERROR' : 'INFO';
  debugPrint('$kChildStatusLogTag $prefix | $message');
}
