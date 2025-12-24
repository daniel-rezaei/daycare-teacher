import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/photo_cache_service.dart';
import 'package:teacher_app/core/services/image_processing_service.dart';
import 'package:teacher_app/features/activity/choose_photo_screen.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';
import 'package:uuid/uuid.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({super.key});

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  String? classId;

  @override
  void initState() {
    super.initState();
    _loadClassId();
  }

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString(AppConstants.classIdKey);

    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
      });
      // Request class rooms if not already loaded
      final currentState = context.read<HomeBloc>().state;
      if (currentState.classRooms == null || currentState.classRooms!.isEmpty) {
        context.read<HomeBloc>().add(const LoadClassRoomsEvent());
      }
    }
  }

  String? _getRoomName(List<ClassRoomEntity>? classRooms) {
    if (classId == null || classRooms == null) return null;

    try {
      final classRoom = classRooms.firstWhere(
        (room) => room.id == classId,
      );
      return classRoom.roomName;
    } catch (e) {
      return null;
    }
  }

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
                        child: BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            final roomName = _getRoomName(state.classRooms);
                            return Row(
                              children: [
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    color: Color(0xff444349),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (roomName != null) ...[
                                  Text(
                                    ' – ',
                                    style: TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (state.isLoadingClassRooms)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CupertinoActivityIndicator(
                                        radius: 8,
                                      ),
                                    )
                                  else
                                    Text(
                                      roomName,
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ],
                            );
                          },
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

/// Save and process image completely in background (fire and forget)
Future<void> _saveAndProcessImageInBackground(String cameraFilePath) async {
  final bgStartTime = DateTime.now();
  try {
    final dir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    final savedPath = '${dir.path}/$id.jpg';
    final thumbPath = '${dir.path}/${id}_thumb.jpg';

    // Copy file in background
    await File(cameraFilePath).copy(savedPath);
    final copyTime = DateTime.now().difference(bgStartTime).inMilliseconds;
    debugPrint('[PERF] Background file copy: ${copyTime}ms');

    // Refresh cache
    PhotoCacheService.refresh();

    // Process image in background (optimize and create thumbnail)
    ImageProcessingService.processCameraImageAsync(
      cameraImagePath: cameraFilePath,
      savedImagePath: savedPath,
      thumbnailPath: thumbPath,
    ).then((_) {
      final totalBgTime = DateTime.now().difference(bgStartTime).inMilliseconds;
      debugPrint('[PERF] Background processing complete: ${totalBgTime}ms');
    }).catchError((e) {
      debugPrint('[ADD_PHOTO] Background processing error: $e');
    });
  } catch (e) {
    debugPrint('[ADD_PHOTO] Background save error: $e');
  }
}

class ButtonsInfoCardPhoto extends StatelessWidget {
  const ButtonsInfoCardPhoto({super.key});
  
  BuildContext? showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(radius: 12),
                  SizedBox(height: 16),
                  Text(
                    "Processing...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return null;
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
              // Performance instrumentation
              final startTime = DateTime.now();
              
              // Show loading IMMEDIATELY before camera opens
              if (!context.mounted) return;
              final loadStartTime = DateTime.now();
              showLoadingDialog(context);
              final loadDialogTime = DateTime.now().difference(loadStartTime).inMilliseconds;
              debugPrint('[PERF] Load dialog shown: ${loadDialogTime}ms');

              try {
                final picker = ImagePicker();
                
                // CRITICAL: Force camera to use lowest safe resolution BEFORE opening
                final cameraOpenStart = DateTime.now();
                final XFile? file = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024.0,  // Forces low resolution capture
                  maxHeight: 1024.0, // Prevents max-resolution
                  imageQuality: 60,  // Low quality for minimal size
                  preferredCameraDevice: CameraDevice.rear,
                );
                final cameraTime = DateTime.now().difference(cameraOpenStart).inMilliseconds;
                debugPrint('[PERF] Camera capture time: ${cameraTime}ms');

                if (file == null) {
                  // User cancelled
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  return;
                }

                final onResultTime = DateTime.now().difference(startTime).inMilliseconds;
                debugPrint('[PERF] Time to camera result: ${onResultTime}ms');

                // INSTANT PATH: Navigate IMMEDIATELY without waiting for ANY file operations
                // Pass camera file as temporary placeholder - user sees it instantly
                if (!context.mounted) return;
                Navigator.pop(context); // Close loading
                
                final navStartTime = DateTime.now();
                // Navigate IMMEDIATELY - use camera file as placeholder
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChoosePhotoScreen(
                      temporaryCameraFile: file.path,
                    ),
                  ),
                );
                final navTime = DateTime.now().difference(navStartTime).inMilliseconds;
                final totalPerceivedTime = DateTime.now().difference(startTime).inMilliseconds;
                debugPrint('[PERF] Navigation time: ${navTime}ms');
                debugPrint('[PERF] TOTAL PERCEIVED TIME: ${totalPerceivedTime}ms');

                // ALL file operations happen in background (fire and forget)
                _saveAndProcessImageInBackground(file.path).catchError((e) {
                  debugPrint('[ADD_PHOTO] Background save error: $e');
                });
              } catch (e) {
                // Close loading on error
                if (!context.mounted) return;
                Navigator.pop(context);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    duration: const Duration(seconds: 2),
                  ),
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
