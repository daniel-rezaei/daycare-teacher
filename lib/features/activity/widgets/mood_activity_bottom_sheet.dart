import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_mood_api.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class MoodActivityBottomSheet extends StatefulWidget {
  final List<ChildEntity> selectedChildren;
  final DateTime dateTime;

  const MoodActivityBottomSheet({
    super.key,
    required this.selectedChildren,
    required this.dateTime,
  });

  @override
  State<MoodActivityBottomSheet> createState() => _MoodActivityBottomSheetState();
}

class _MoodActivityBottomSheetState extends State<MoodActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _images = [];
  
  /// Selected mood id (from /items/mood) for API
  String? _selectedMoodId;
  List<String> _tags = [];

  // Options loaded from GET /items/mood (id, name)
  List<Map<String, String>> _moodOptions = [];
  
  // Class ID for creating activities
  String? _classId;
  
  bool _isSubmitting = false;
  bool _isLoadingOptions = true;
  final ActivityMoodApi _api = GetIt.instance<ActivityMoodApi>();
  final FileUploadUsecase _fileUploadUsecase = GetIt.instance<FileUploadUsecase>();

  @override
  void initState() {
    super.initState();
    debugPrint('[MOOD_ACTIVITY] ========== Opening MoodActivityBottomSheet ==========');
    debugPrint('[MOOD_ACTIVITY] Selected children count: ${widget.selectedChildren.length}');
    debugPrint('[MOOD_ACTIVITY] DateTime: ${widget.dateTime}');
    
    // Load classId and mood options
    _loadClassId();
    _loadMoodOptions();
  }

  Future<void> _loadClassId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedClassId = prefs.getString(AppConstants.classIdKey);
      if (savedClassId != null && savedClassId.isNotEmpty) {
        setState(() {
          _classId = savedClassId;
        });
        debugPrint('[MOOD_ACTIVITY] ClassId loaded: $_classId');
      } else {
        debugPrint('[MOOD_ACTIVITY] ⚠️ ClassId not found in SharedPreferences');
      }
    } catch (e, stackTrace) {
      debugPrint('[MOOD_ACTIVITY] Error loading classId: $e');
      debugPrint('[MOOD_ACTIVITY] StackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });
    try {
      debugPrint('[MOOD_ACTIVITY] Loading mood options from backend...');
      final options = await _api.getMoodOptions();
      debugPrint('[MOOD_ACTIVITY] Mood options loaded: $options');
      if (mounted) {
        setState(() {
          _moodOptions = options;
          _isLoadingOptions = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[MOOD_ACTIVITY] Error loading mood options: $e');
      debugPrint('[MOOD_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _moodOptions = [];
          _isLoadingOptions = false;
        });
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Map API mood name to asset SVG (assets/images). API names: Excited, hugging, Neutral, Neutral2, Sleepy, quiet, Unwell, Group 27, Anxious, Frustrated (and possibly Sad, Happy).
  Widget _moodSvgForName(String name) {
    final n = name.trim().toLowerCase();
    if (n == 'unwell') return Assets.images.unwell.svg(width: 48, height: 48);
    if (n == 'sleepy') return Assets.images.sleepy.svg(width: 48, height: 48);
    if (n == 'sad') return Assets.images.sad.svg(width: 48, height: 48);
    if (n == 'hugging') return Assets.images.hugging.svg(width: 48, height: 48);
    if (n == 'excited') return Assets.images.excited.svg(width: 48, height: 48);
    if (n == 'happy') return Assets.images.neutral.svg(width: 48, height: 48);
    if (n == 'neutral') return Assets.images.neutral2.svg(width: 48, height: 48);
    if (n == 'frustrated') return Assets.images.frustrated.svg(width: 48, height: 48);
    if (n == 'quiet') return Assets.images.quiet.svg(width: 48, height: 48);
    if (n == 'anxious') return Assets.images.anxious.svg(width: 48, height: 48);
    return SizedBox();
  }

  void _onMoodChanged(String? moodName) {
    debugPrint('[MOOD_ACTIVITY] Mood changed: $moodName');
    setState(() {
      if (moodName == null) {
        _selectedMoodId = null;
        return;
      }
      final match = _moodOptions.where((m) => m['name'] == moodName);
      _selectedMoodId = match.isEmpty ? null : match.first['id'];
    });
  }

  void _onTagSubmitted(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      debugPrint('[MOOD_ACTIVITY] Adding tag: $tag');
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
      debugPrint('[MOOD_ACTIVITY] Tag added successfully - total tags: ${_tags.length}');
    } else if (_tags.contains(tag)) {
      debugPrint('[MOOD_ACTIVITY] Tag already exists: $tag');
    }
  }

  void _onTagRemoved(String tag) {
    debugPrint('[MOOD_ACTIVITY] Tag removed: $tag');
    setState(() {
      _tags.remove(tag);
    });
    debugPrint('[MOOD_ACTIVITY] Tag removed successfully - remaining tags: ${_tags.length}');
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[MOOD_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      debugPrint('[MOOD_ACTIVITY] Uploading photo: ${imageFile.path}');
      final uploadResult = await _fileUploadUsecase.uploadFile(filePath: imageFile.path);
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        debugPrint('[MOOD_ACTIVITY] Photo uploaded successfully: ${uploadResult.data}');
        return uploadResult.data;
      } else {
        debugPrint('[MOOD_ACTIVITY] Photo upload failed');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('[MOOD_ACTIVITY] Error uploading photo: $e');
      debugPrint('[MOOD_ACTIVITY] StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> _handleAdd() async {
    debugPrint('[MOOD_ACTIVITY] ========== Add button pressed ==========');
    debugPrint('[MOOD_ACTIVITY] Selected children: ${widget.selectedChildren.length}');
    debugPrint('[MOOD_ACTIVITY] Mood id: $_selectedMoodId');
    debugPrint('[MOOD_ACTIVITY] Tags: $_tags');
    debugPrint('[MOOD_ACTIVITY] Description: ${_descriptionController.text}');
    debugPrint('[MOOD_ACTIVITY] Images: ${_images.length}');

    // Validation
    if (widget.selectedChildren.isEmpty) {
      debugPrint('[MOOD_ACTIVITY] Validation failed: No children selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one child')),
      );
      return;
    }

    if (_classId == null || _classId!.isEmpty) {
      debugPrint('[MOOD_ACTIVITY] Validation failed: No classId available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class ID not found. Please try again.')),
      );
      return;
    }

    if (_selectedMoodId == null || _selectedMoodId!.isEmpty) {
      debugPrint('[MOOD_ACTIVITY] Validation failed: No mood selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload all photos (same process as other activities)
      final List<String> photoIds = [];
      for (final file in _images) {
        final id = await _uploadPhoto(file);
        if (id != null) photoIds.add(id);
      }

      // Format start_at in UTC ISO 8601 format
      final startAtUtc = widget.dateTime.toUtc().toIso8601String();
      debugPrint('[MOOD_ACTIVITY] start_at (UTC): $startAtUtc');

      // Two-step flow: Create activity (parent) then mood details (child) for EACH child
      int successCount = 0;
      int failureCount = 0;

      for (final child in widget.selectedChildren) {
        if (child.id == null || child.id!.isEmpty) {
          debugPrint('[MOOD_ACTIVITY] Skipping child with null ID');
          failureCount++;
          continue;
        }

        try {
          debugPrint('[MOOD_ACTIVITY] ========== Processing child: ${child.id} ==========');

          // STEP A: Create parent activity
          debugPrint('[MOOD_ACTIVITY] STEP A: Creating activity for child ${child.id}');
          final activityId = await _api.createActivity(
            childId: child.id!,
            classId: _classId!,
            startAtUtc: startAtUtc,
          );
          debugPrint('[MOOD_ACTIVITY] ✅ Activity created with ID: $activityId');

          // STEP B: Create mood details linked to activity
          debugPrint('[MOOD_ACTIVITY] STEP B: Creating mood details for activity $activityId');
          final response = await _api.createMoodDetails(
            activityId: activityId,
            mood: _selectedMoodId!,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            tag: _tags.isNotEmpty ? _tags.first : null,
            photo: photoIds.isEmpty ? null : photoIds,
          );

          debugPrint('[MOOD_ACTIVITY] ✅ Mood details created for child ${child.id}: ${response.statusCode}');
          debugPrint('[MOOD_ACTIVITY] Response data: ${response.data}');
          successCount++;
        } catch (e, stackTrace) {
          debugPrint('[MOOD_ACTIVITY] ❌ Error processing child ${child.id}: $e');
          debugPrint('[MOOD_ACTIVITY] StackTrace: $stackTrace');
          failureCount++;
        }
      }

      debugPrint('[MOOD_ACTIVITY] ========== Submission complete ==========');
      debugPrint('[MOOD_ACTIVITY] Success: $successCount, Failures: $failureCount');

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (successCount > 0) {
          // Close bottom sheet first
          Navigator.pop(context);
          // Navigate back to LogActivityScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LogActivityScreen(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failureCount > 0
                    ? 'Created $successCount mood activities (${failureCount} failed)'
                    : 'Mood activities created successfully',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create mood activities')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[MOOD_ACTIVITY] Error in _handleAdd: $e');
      debugPrint('[MOOD_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetWrapper(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderCheckOut(isIcon: false, title: 'Mood Activity'),
            const Divider(color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Date and Time (like Play, no Start/End time)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(widget.dateTime),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(widget.dateTime),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Selected Children Preview (avatars only, like Play)
                  if (widget.selectedChildren.isNotEmpty) ...[
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.selectedChildren.length,
                        itemBuilder: (context, index) {
                          final child = widget.selectedChildren[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChildAvatarWidget(
                              photoId: child.photo,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Mood Selector: title "Mood", each item has asset SVG on top, no gray background
                  const Text(
                    'Mood',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingOptions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _moodOptions.map((mood) {
                        final name = mood['name'] ?? '';
                        final isSelected = _selectedMoodId == mood['id'];
                        return Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () =>
                                _onMoodChanged(isSelected ? null : name),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _moodSvgForName(name),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Tag Section
                  const Text(
                    'Tag',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Enter tag and press done',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.divider,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.divider,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    onSubmitted: _onTagSubmitted,
                  ),
                  const SizedBox(height: 12),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppColors.primaryLight,
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onDeleted: () => _onTagRemoved(tag),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Description Field
                  NoteWidget(
                    title: 'Decription',
                    hintText: 'Please enter a description',
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 20),

                  // Attach Photo (same process as other activities)
                  AttachPhotoWidget(
                    images: _images,
                    onImagesChanged: _onImagesChanged,
                  ),
                  const SizedBox(height: 32),

                  // Add Button
                  ButtonWidget(
                    isEnabled: !_isSubmitting,
                    onTap: _handleAdd,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CupertinoActivityIndicator(
                              radius: 10,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

