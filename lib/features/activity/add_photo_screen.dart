import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teacher_app/core/photo_cache_service.dart';
import 'package:teacher_app/features/activity/choose_photo_screen.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as IMG;

class AddPhotoScreen extends StatelessWidget {
  const AddPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Assets.images.arrowLeft.svg(),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Add Photo – Toddler 2',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF).withValues(alpha: .6),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        topLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -4),
                          blurRadius: 16,
                          color: Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.images.photo.image(height: 116),
                        SizedBox(height: 24),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Take a photo or select one from your gallery',
                          style: TextStyle(
                            color: Color(0xff71717A).withValues(alpha: .8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ButtonsInfoCardPhoto(),
    );
  }
}

class ButtonsInfoCardPhoto extends StatelessWidget {
  const ButtonsInfoCardPhoto({super.key});
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 16),
              Text("Processing...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 212,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          InfoCardPhoto(
            title: 'Take Photo',
            icon: Assets.images.photo2.image(height: 68),
            onTap: () async {
              final picker = ImagePicker();
              final XFile? file = await picker.pickImage(
                source: ImageSource.camera,
              );

              if (file != null) {
                showLoadingDialog(context); // <- نمایش لودینگ

                final dir = await getApplicationDocumentsDirectory();
                final id = const Uuid().v4();
                final originalPath = "${dir.path}/$id.jpg";
                final thumbPath = "${dir.path}/${id}_thumb.jpg";

                await File(file.path).copy(originalPath);

                PhotoCacheService.refresh();

                // Thumbnail async
                _createThumbnail(file.path, thumbPath);

                // کمی تأخیر برای طبیعی‌تر شدن تجربه
                await Future.delayed(Duration(milliseconds: 300));

                Navigator.pop(context); // بستن لودینگ
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChoosePhotoScreen()),
                );
              }
            },
          ),
          SizedBox(height: 16),
          InfoCardPhoto(
            title: 'Choose From library',
            icon: Assets.images.gallery.image(height: 68),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChoosePhotoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ساخت thumbnail در پس‌زمینه
  void _createThumbnail(String sourcePath, String thumbPath) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();
      IMG.Image? img = IMG.decodeImage(bytes);
      if (img != null) {
        final resized = IMG.copyResize(img, width: 300);
        await File(thumbPath).writeAsBytes(IMG.encodeJpg(resized, quality: 80));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Thumbnail creation failed: $e");
      }
    }
  }
}

class InfoCardPhoto extends StatelessWidget {
  final String title;
  final Widget icon;
  final Function() onTap;
  const InfoCardPhoto({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          border: Border.all(width: 2, color: Color(0xffFAFAFA)),
          boxShadow: [
            BoxShadow(
              color: Color(0xffE4D3FF).withValues(alpha: .5),
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
