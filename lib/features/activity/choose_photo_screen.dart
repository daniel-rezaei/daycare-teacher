import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ChoosePhotoScreen extends StatefulWidget {
  const ChoosePhotoScreen({super.key});

  @override
  State<ChoosePhotoScreen> createState() => _ChoosePhotoScreenState();
}

class _ChoosePhotoScreenState extends State<ChoosePhotoScreen> {
  List<File> photos = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = await dir
        .list()
        .where((f) => f is File && f.path.endsWith("_thumb.jpg"))
        .map((f) => File(f.path))
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (var f in files) {
        await precacheImage(FileImage(f), context);
      }
      setState(() {
        photos = files.reversed.toList();
      });
    });
  }

  Set<File> selectedPhotos = {};
  bool allSelected = false;
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
                          'Choose a Photo',
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gallery',
                              style: TextStyle(
                                color: Color(0xff444349),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Assets.images.sort.svg(),
                          ],
                        ),

                        SizedBox(height: 16),

                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double spacing = 8;
                              double itemWidth =
                                  (constraints.maxWidth - 2 * spacing) / 3;

                              return SingleChildScrollView(
                                child: Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: photos.map((file) {
                                    bool isSelected = selectedPhotos.contains(
                                      file,
                                    );

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedPhotos.remove(file);
                                          } else {
                                            selectedPhotos.add(file);
                                          }
                                          allSelected =
                                              selectedPhotos.length ==
                                              photos.length;
                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: itemWidth,
                                            height: itemWidth,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
                                                image: FileImage(file),
                                                fit: BoxFit.cover,
                                                colorFilter: isSelected
                                                    ? ColorFilter.mode(
                                                        Colors.black.withValues(
                                                          alpha: 0.3,
                                                        ),
                                                        BlendMode.darken,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: isSelected
                                                ? Assets.images.radiofi.svg()
                                                : Assets.images.radio.svg(),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
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
      bottomNavigationBar: Container(
        height: 86,
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0xff95939D).withValues(alpha: .2),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Color(0xffDBDADD)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: Assets.images.squareArrowRight.svg(),
            ),
            SizedBox(width: 18),
            Text(
              '${selectedPhotos.length} photo${selectedPhotos.length > 1 ? 's' : ''} Selected',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (allSelected) {
                    selectedPhotos.clear();
                  } else {
                    selectedPhotos = photos.toSet();
                  }
                  allSelected = !allSelected;
                });
              },
              child: Row(
                children: [
                  allSelected
                      ? Assets.images.checkbox.svg()
                      : Assets.images.checkbox2.svg(),
                  SizedBox(width: 8),
                  Text(
                    'Select All',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
