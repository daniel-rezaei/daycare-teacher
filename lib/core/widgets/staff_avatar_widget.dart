import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StaffAvatarWidget extends StatelessWidget {
  final String? photoId;
  final double size;

  const StaffAvatarWidget({super.key, required this.photoId, this.size = 48});

  @override
  Widget build(BuildContext context) {
    if (photoId == null || photoId!.isEmpty) {
      return _placeholder();
    }

    /// مسیر نسبی، baseUrl از Dio میاد
    final imageUrl = 'http://51.79.53.56:8055/assets/$photoId';

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        httpHeaders: const {
          'Authorization': 'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
        },
        width: size,
        height: size,
        fit: BoxFit.cover,

        /// هنگام لود
        placeholder: (_, _) => _loading(),

        /// هنگام خطا
        errorWidget: (_, _, _) => _placeholder(),
      ),
    );
  }

  Widget _loading() => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      shape: BoxShape.circle,
    ),
    child: CupertinoActivityIndicator(),
  );

  Widget _placeholder() => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.person, color: Colors.white),
  );
}
