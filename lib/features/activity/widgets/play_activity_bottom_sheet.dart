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
import 'package:teacher_app/features/activity/data/data_source/activity_play_api.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/core/data_state.dart';

class PlayActivityBottomSheet extends StatefulWidget {
  final List<ChildEntity> selectedChildren;
  final DateTime dateTime;

  const PlayActivityBottomSheet({
    super.key,
    required this.selectedChildren,
    required this.dateTime,
  });

  @override
  State<PlayActivityBottomSheet> createState() => _PlayActivityBottomSheetState();
}

class _PlayActivityBottomSheetState extends State<PlayActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _images = [];
  
  String? _selectedType;
  List<String> _tags = [];
  
  // Time range state
  late DateTime _startTime;
  late DateTime _endTime;
  
  // Options loaded from backend
  List<String> _typeOptions = [];
  
  // Class ID for creating activities
  String? _classId;
  
  bool _isSubmitting = false;
  bool _isLoadingOptions = true;
  final ActivityPlayApi _api = GetIt.instance<ActivityPlayApi>();
  final FileUploadUsecase _fileUploadUsecase = GetIt.instance<FileUploadUsecase>();

  @override
  void initState() {
    super.initState();
    debugPrint('[PLAY_ACTIVITY] ========== Opening PlayActivityBottomSheet ==========');
    debugPrint('[PLAY_ACTIVITY] Selected children count: ${widget.selectedChildren.length}');
    debugPrint('[PLAY_ACTIVITY] DateTime: ${widget.dateTime}');
    
    // Initialize time range: start = widget.dateTime, end = start + 30 minutes
    _startTime = widget.dateTime;
    _endTime = _startTime.add(const Duration(minutes: 30));
    
    // Load classId and play options
    _loadClassId();
    _loadAllOptions();
  }
  
  bool get _isTimeValid => _endTime.isAfter(_startTime);

  Future<void> _loadClassId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedClassId = prefs.getString(AppConstants.classIdKey);
      if (savedClassId != null && savedClassId.isNotEmpty) {
        setState(() {
          _classId = savedClassId;
        });
        debugPrint('[PLAY_ACTIVITY] ClassId loaded: $_classId');
      } else {
        debugPrint('[PLAY_ACTIVITY] ⚠️ ClassId not found in SharedPreferences');
      }
    } catch (e, stackTrace) {
      debugPrint('[PLAY_ACTIVITY] Error loading classId: $e');
      debugPrint('[PLAY_ACTIVITY] StackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    try {
      debugPrint('[PLAY_ACTIVITY] Loading play types from backend...');
      final options = await _api.getPlayTypes();
      debugPrint('[PLAY_ACTIVITY] Play types loaded: $options');
      if (mounted) {
        setState(() {
          _typeOptions = options;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[PLAY_ACTIVITY] Error loading play types: $e');
      debugPrint('[PLAY_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _typeOptions = [];
        });
      }
    }
  }

  Future<void> _loadAllOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });
    await _loadTypes();
    if (mounted) {
      setState(() {
        _isLoadingOptions = false;
      });
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
  
  Future<void> _selectEndTime() async {
    DateTime selectedTime = _endTime;
    
    await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Check if selected time is valid
          final newEndTime = DateTime(
            widget.dateTime.year,
            widget.dateTime.month,
            widget.dateTime.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          final isValid = newEndTime.isAfter(_startTime);
          
          return Container(
            height: 250,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: isValid ? () {
                        Navigator.pop(context);
                        setState(() {
                          _endTime = newEndTime;
                        });
                      } : null,
                      child: const Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _endTime,
                    onDateTimeChanged: (DateTime newTime) {
                      selectedTime = newTime;
                      setModalState(() {}); // Trigger rebuild to update Done button state
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _toggleEndAmPm() {
    setState(() {
      if (_endTime.hour < 12) {
        // AM -> PM: add 12 hours
        _endTime = _endTime.add(const Duration(hours: 12));
      } else {
        // PM -> AM: subtract 12 hours
        _endTime = _endTime.subtract(const Duration(hours: 12));
      }
    });
  }

  void _onTypeChanged(String? value) {
    debugPrint('[PLAY_ACTIVITY] Type changed: $value');
    setState(() {
      _selectedType = value;
    });
  }

  void _onTagSubmitted(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      debugPrint('[PLAY_ACTIVITY] Adding tag (LOCAL ONLY): $tag');
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
      debugPrint('[PLAY_ACTIVITY] Tag added successfully - total tags: ${_tags.length}');
    } else if (_tags.contains(tag)) {
      debugPrint('[PLAY_ACTIVITY] Tag already exists: $tag');
    }
  }

  void _onTagRemoved(String tag) {
    debugPrint('[PLAY_ACTIVITY] ========== Tag removed (LOCAL ONLY) ==========');
    debugPrint('[PLAY_ACTIVITY] Tag removed locally: $tag');
    debugPrint('[PLAY_ACTIVITY] NO API call executed for tag removal');
    debugPrint('[PLAY_ACTIVITY] Tags are LOCAL-ONLY - changes stay in UI');
    setState(() {
      _tags.remove(tag);
    });
    debugPrint('[PLAY_ACTIVITY] Tag removed successfully - remaining tags: ${_tags.length}');
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[PLAY_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      debugPrint('[PLAY_ACTIVITY] Uploading photo: ${imageFile.path}');
      final uploadResult = await _fileUploadUsecase.uploadFile(filePath: imageFile.path);
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        debugPrint('[PLAY_ACTIVITY] Photo uploaded successfully: ${uploadResult.data}');
        return uploadResult.data;
      } else {
        debugPrint('[PLAY_ACTIVITY] Photo upload failed');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('[PLAY_ACTIVITY] Error uploading photo: $e');
      debugPrint('[PLAY_ACTIVITY] StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> _handleAdd() async {
    debugPrint('[PLAY_ACTIVITY] ========== Add button pressed ==========');
    debugPrint('[PLAY_ACTIVITY] Selected children: ${widget.selectedChildren.length}');
    debugPrint('[PLAY_ACTIVITY] Type: $_selectedType');
    debugPrint('[PLAY_ACTIVITY] Tags: $_tags');
    debugPrint('[PLAY_ACTIVITY] Description: ${_descriptionController.text}');
    debugPrint('[PLAY_ACTIVITY] Images: ${_images.length}');

    // Validation
    if (widget.selectedChildren.isEmpty) {
      debugPrint('[PLAY_ACTIVITY] Validation failed: No children selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one child')),
      );
      return;
    }

    if (_classId == null || _classId!.isEmpty) {
      debugPrint('[PLAY_ACTIVITY] Validation failed: No classId available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class ID not found. Please try again.')),
      );
      return;
    }

    if (_selectedType == null || _selectedType!.isEmpty) {
      debugPrint('[PLAY_ACTIVITY] Validation failed: No type selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a type')),
      );
      return;
    }

    if (!_isTimeValid) {
      debugPrint('[PLAY_ACTIVITY] Validation failed: Invalid time range');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time cannot be before start time')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload photo if exists
      String? photoFileId;
      if (_images.isNotEmpty) {
        photoFileId = await _uploadPhoto(_images.first);
      }

      // Format start_at and end_at in UTC ISO 8601 format
      final startAtUtc = _startTime.toUtc().toIso8601String();
      final endAtUtc = _endTime.toUtc().toIso8601String();
      debugPrint('[PLAY_ACTIVITY] start_at (UTC): $startAtUtc');
      debugPrint('[PLAY_ACTIVITY] end_at (UTC): $endAtUtc');

      // Two-step flow: Create activity (parent) then play details (child) for EACH child
      int successCount = 0;
      int failureCount = 0;

      for (final child in widget.selectedChildren) {
        if (child.id == null || child.id!.isEmpty) {
          debugPrint('[PLAY_ACTIVITY] Skipping child with null ID');
          failureCount++;
          continue;
        }

        try {
          debugPrint('[PLAY_ACTIVITY] ========== Processing child: ${child.id} ==========');
          
          // STEP A: Create parent activity
          debugPrint('[PLAY_ACTIVITY] STEP A: Creating activity for child ${child.id}');
          final activityId = await _api.createActivity(
            childId: child.id!,
            classId: _classId!,
            startAtUtc: startAtUtc,
          );
          debugPrint('[PLAY_ACTIVITY] ✅ Activity created with ID: $activityId');

          // STEP B: Create play details linked to activity
          debugPrint('[PLAY_ACTIVITY] STEP B: Creating play details for activity $activityId');
          final response = await _api.createPlayDetails(
            activityId: activityId,
            type: _selectedType!,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            tags: _tags.isNotEmpty ? _tags : null,
            photo: photoFileId,
            startAt: startAtUtc,
            endAt: endAtUtc,
          );

          debugPrint('[PLAY_ACTIVITY] ✅ Play details created for child ${child.id}: ${response.statusCode}');
          debugPrint('[PLAY_ACTIVITY] Response data: ${response.data}');
          successCount++;
        } catch (e, stackTrace) {
          debugPrint('[PLAY_ACTIVITY] ❌ Error processing child ${child.id}: $e');
          debugPrint('[PLAY_ACTIVITY] StackTrace: $stackTrace');
          failureCount++;
        }
      }

      debugPrint('[PLAY_ACTIVITY] ========== Submission complete ==========');
      debugPrint('[PLAY_ACTIVITY] Success: $successCount, Failures: $failureCount');

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
                    ? 'Created $successCount play activities (${failureCount} failed)'
                    : 'Play activities created successfully',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create play activities')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[PLAY_ACTIVITY] Error in _handleAdd: $e');
      debugPrint('[PLAY_ACTIVITY] StackTrace: $stackTrace');
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
            const HeaderCheckOut(isIcon: false, title: 'Play Activity'),
            const Divider(color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Date and Time
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

                  // Selected Children Preview (avatars only, no title, no names)
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
                  ],

                  // Time Range Selector
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TimeColumn(
                            label: 'Start',
                            time: _startTime,
                            onTimeTap: null,
                            onAmPmTap: null,
                            enabled: false,
                          ),
                        ),
                        Expanded(
                          child: _TimeColumn(
                            label: 'End',
                            time: _endTime,
                            onTimeTap: _selectEndTime,
                            onAmPmTap: _toggleEndAmPm,
                            enabled: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Type Selector
                  if (_isLoadingOptions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    MealTypeSelectorWidget(
                      title: 'Type',
                      options: _typeOptions,
                      selectedValue: _selectedType,
                      onChanged: _onTypeChanged,
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
                  // Tag Input Field
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
                  // Tag Chips Display
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

                  // Attach Photo
                  AttachPhotoWidget(
                    images: _images,
                    onImagesChanged: _onImagesChanged,
                  ),
                  const SizedBox(height: 32),

                  // Add Button
                  ButtonWidget(
                    isEnabled: !_isSubmitting && _isTimeValid,
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

class _TimeColumn extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback? onTimeTap;
  final VoidCallback? onAmPmTap;
  final bool enabled;

  const _TimeColumn({
    required this.label,
    required this.time,
    required this.onTimeTap,
    required this.onAmPmTap,
    this.enabled = true,
  });

  String _formatTimeForDisplay(DateTime dateTime) {
    return DateFormat('hh:mm').format(dateTime);
  }

  String _getAmPm(DateTime dateTime) {
    return DateFormat('a').format(dateTime).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Row(
            children: [
              GestureDetector(
                onTap: enabled ? onTimeTap : null,
                child: Text(
                  _formatTimeForDisplay(time),
                  style: TextStyle(
                    color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: enabled ? onAmPmTap : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: enabled ? AppColors.primaryLight : AppColors.divider,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getAmPm(time),
                    style: TextStyle(
                      color: enabled ? AppColors.primary : AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

