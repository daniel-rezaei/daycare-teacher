import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacher_app/features/activity/choose_photo_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AttachPhotoWidget extends StatefulWidget {
  final List<File> images;
  final Function(List<File>)? onImagesChanged;
  const AttachPhotoWidget({
    super.key,
    this.images = const [],
    this.onImagesChanged,
  });

  @override
  State<AttachPhotoWidget> createState() => _AttachPhotoWidgetState();
}

class _AttachPhotoWidgetState extends State<AttachPhotoWidget> {
  late List<File> _images;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.images);
  }

  @override
  void didUpdateWidget(AttachPhotoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != oldWidget.images) {
      _images = List.from(widget.images);
    }
  }

  void _notifyChange() {
    widget.onImagesChanged?.call(_images);
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  // Force low resolution to prevent memory issues
                  // Configuration applied BEFORE camera opens
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024.0,  // Maximum width (forces low resolution)
                    maxHeight: 1024.0, // Maximum height (forces low resolution)
                    imageQuality: 60,   // Low quality for minimal memory usage
                  );
                  if (image != null) {
                    setState(() {
                      _images.insert(0, File(image.path));
                      _notifyChange();
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from App Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push<List<File>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChoosePhotoScreen(
                        allowMultipleSelection: true,
                      ),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    setState(() {
                      // اضافه کردن عکس‌های انتخاب شده به ابتدای لیست
                      for (var file in result.reversed) {
                        _images.insert(0, file);
                      }
                      _notifyChange();
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // وقتی لیست تصاویر خالی است، استایل ویژه نمایش داده شود
    if (_images.isEmpty) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffF0E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.images.attachment2.svg(),
              SizedBox(width: 8),
              Text(
                'Attach Photo',
                style: TextStyle(
                  color: Color(0xff7B2AF3),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // وقتی تصاویر اضافه شدند، حالت معمولی با نمایش لیست
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 124,
              width: 124,
              decoration: BoxDecoration(
                color: Color(0xffF0E7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.images.attachment2.svg(),
                  SizedBox(height: 8),
                  Text(
                    'Attach Photo',
                    style: TextStyle(
                      color: Color(0xff7B2AF3),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          ..._images.map((file) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      file,
                      height: 124,
                      width: 124,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.remove(file);
                            _notifyChange();
                          });
                        },
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: Color(0xffFFDFDF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Assets.images.trash.svg(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
