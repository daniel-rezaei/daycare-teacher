import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teacher_app/core/utils/photo_utils.dart';

class ChildAvatarWidget extends StatelessWidget {
  final String? photoId;
  final double size;
  final BoxFit fit;

  const ChildAvatarWidget({
    super.key,
    this.photoId,
    this.size = 48,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = PhotoUtils.getPhotoUrl(photoId);

    return ClipOval(
      child: photoUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              httpHeaders: PhotoUtils.getImageHeaders(),
              width: size,
              height: size,
              fit: fit,
              placeholder: (_, __) => Container(
                width: size,
                height: size,
                color: Colors.grey.shade200,
                child: const CupertinoActivityIndicator(),
              ),
              errorWidget: (_, __, ___) => Container(
                width: size,
                height: size,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            )
          : Container(
              width: size,
              height: size,
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
    );
  }
}

