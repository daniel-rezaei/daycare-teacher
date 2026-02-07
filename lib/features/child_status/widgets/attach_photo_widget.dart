import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacher_app/features/activity/choose_photo_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AttachPhotoWidget extends StatefulWidget {
  final List<File> images;
  final Function(List<File>)? onImagesChanged;
  /// Custom button label (e.g. "Add Attachment" for Learning).
  final String? buttonLabel;
  /// When true, shows 3 options: Add photo or Video, Take Photo or Video, Attach File.
  final bool showAttachFileOption;

  const AttachPhotoWidget({
    super.key,
    this.images = const [],
    this.onImagesChanged,
    this.buttonLabel,
    this.showAttachFileOption = false,
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

  static const _imageExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic',
  };

  static bool _isImageFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return _imageExtensions.contains(ext);
  }

  String get _effectiveButtonLabel =>
      widget.buttonLabel ?? 'Attach Photo';

  Future<void> _pickImage() async {
    if (widget.showAttachFileOption) {
      _showAttachmentOptions();
      return;
    }
    _showPhotoOptions();
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024.0,
                    maxHeight: 1024.0,
                    imageQuality: 60,
                  );
                  if (image != null && mounted) {
                    setState(() {
                      _images.insert(0, File(image.path));
                      _notifyChange();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from App Gallery'),
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
                  if (result != null && result.isNotEmpty && mounted) {
                    setState(() {
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Add photo or Video'),
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
                  if (result != null && result.isNotEmpty && mounted) {
                    setState(() {
                      for (var file in result.reversed) {
                        _images.insert(0, file);
                      }
                      _notifyChange();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo or Video'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024.0,
                    maxHeight: 1024.0,
                    imageQuality: 60,
                  );
                  if (image != null && mounted) {
                    setState(() {
                      _images.insert(0, File(image.path));
                      _notifyChange();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Attach File'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    setState(() {
      for (var p in result.files) {
        if (p.path != null) {
          _images.add(File(p.path!));
        }
      }
      _notifyChange();
    });
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
                _effectiveButtonLabel,
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
                    _effectiveButtonLabel,
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
            final isImage = _isImageFile(file);
            final fileName = file.path.split(RegExp(r'[/\\]')).last;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    if (isImage)
                      Image.file(
                        file,
                        height: 124,
                        width: 124,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        height: 124,
                        width: 124,
                        color: const Color(0xffF0E7FF),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_drive_file,
                                size: 40, color: Color(0xff7B2AF3)),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                fileName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff7B2AF3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
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
