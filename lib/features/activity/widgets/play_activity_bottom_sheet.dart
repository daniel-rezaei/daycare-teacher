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
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_play_api.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_management/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_management/widgets/note_widget.dart';
import 'package:teacher_app/features/activity/domain/usecase/file_upload_usecase.dart';
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
  State<PlayActivityBottomSheet> createState() =>
      _PlayActivityBottomSheetState();
}

class _PlayActivityBottomSheetState extends State<PlayActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _images = [];

  String? _selectedType;
  final List<String> _tags = [];

  // Time range state (no defaults - user must set both)
  DateTime? _startTime;
  DateTime? _endTime;

  // Options loaded from backend
  List<String> _typeOptions = [];

  // Class ID for creating activities
  String? _classId;

  bool _isSubmitting = false;
  bool _isLoadingOptions = true;
  final ActivityPlayApi _api = GetIt.instance<ActivityPlayApi>();
  final FileUploadUsecase _fileUploadUsecase =
      GetIt.instance<FileUploadUsecase>();

  @override
  void initState() {
    super.initState();
    // No default times - user must select both Start and End
    _startTime = null;
    _endTime = null;

    _loadClassId();
    _loadAllOptions();
  }

  bool get _isTimeValid =>
      _startTime != null && _endTime != null && _endTime!.isAfter(_startTime!);

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString(AppConstants.classIdKey);
    if (savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        _classId = savedClassId;
      });
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
      final options = await _api.getPlayTypes();
      if (mounted) {
        setState(() {
          _typeOptions = options;
        });
      }
    } catch (e) {
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

  Future<void> _selectStartTime() async {
    DateTime selectedTime = _startTime ?? widget.dateTime;

    await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final newStartTime = DateTime(
            widget.dateTime.year,
            widget.dateTime.month,
            widget.dateTime.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          final isValid = _endTime == null || _endTime!.isAfter(newStartTime);

          return SizedBox(
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
                      onPressed: isValid
                          ? () {
                              Navigator.pop(context);
                              setState(() {
                                _startTime = newStartTime;
                              });
                            }
                          : null,
                      child: const Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: selectedTime,
                    onDateTimeChanged: (DateTime newTime) {
                      selectedTime = newTime;
                      setModalState(() {});
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

  void _toggleStartAmPm() {
    if (_startTime == null) return;
    setState(() {
      if (_startTime!.hour < 12) {
        _startTime = _startTime!.add(const Duration(hours: 12));
      } else {
        _startTime = _startTime!.subtract(const Duration(hours: 12));
      }
    });
  }

  Future<void> _selectEndTime() async {
    DateTime selectedTime =
        _endTime ??
        _startTime?.add(const Duration(minutes: 30)) ??
        widget.dateTime.add(const Duration(minutes: 30));

    await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final newEndTime = DateTime(
            widget.dateTime.year,
            widget.dateTime.month,
            widget.dateTime.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          final isValid = _startTime == null || newEndTime.isAfter(_startTime!);

          return SizedBox(
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
                      onPressed: isValid
                          ? () {
                              Navigator.pop(context);
                              setState(() {
                                _endTime = newEndTime;
                              });
                            }
                          : null,
                      child: const Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: selectedTime,
                    onDateTimeChanged: (DateTime newTime) {
                      selectedTime = newTime;
                      setModalState(() {});
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
    if (_endTime == null) return;
    setState(() {
      if (_endTime!.hour < 12) {
        _endTime = _endTime!.add(const Duration(hours: 12));
      } else {
        _endTime = _endTime!.subtract(const Duration(hours: 12));
      }
    });
  }

  void _onTypeChanged(String? value) {
    setState(() {
      _selectedType = value;
    });
  }

  void _onTagSubmitted(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _onTagRemoved(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _onImagesChanged(List<File> images) {
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      final uploadResult = await _fileUploadUsecase.uploadFile(
        filePath: imageFile.path,
      );
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        return uploadResult.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleAdd() async {
    // Validation
    if (widget.selectedChildren.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please select at least one child');
      return;
    }

    if (_classId == null || _classId!.isEmpty) {
      CustomSnackbar.showError(
        context,
        'Class ID not found. Please try again.',
      );
      return;
    }

    if (_selectedType == null || _selectedType!.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please select a type');
      return;
    }

    if (!_isTimeValid) {
      CustomSnackbar.showWarning(
        context,
        'End time cannot be before start time',
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
      final startAtUtc = _startTime!.toUtc().toIso8601String();
      final endAtUtc = _endTime!.toUtc().toIso8601String();

      // Two-step flow: Create activity (parent) then play details (child) for EACH child
      int successCount = 0;
      int failureCount = 0;

      for (final child in widget.selectedChildren) {
        if (child.id == null || child.id!.isEmpty) {
          failureCount++;
          continue;
        }

        try {
          // STEP A: Create parent activity
          final activityId = await _api.createActivity(
            childId: child.id!,
            classId: _classId!,
            startAtUtc: startAtUtc,
          );
          // STEP B: Create play details linked to activity
          await _api.createPlayDetails(
            activityId: activityId,
            type: _selectedType!,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            tags: _tags.isNotEmpty ? _tags : null,
            photo: photoFileId,
            startAt: startAtUtc,
            endAt: endAtUtc,
          );
          successCount++;
        } catch (e) {
          failureCount++;
        }
      }

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
            MaterialPageRoute(builder: (context) => const LogActivityScreen()),
          );
          CustomSnackbar.showSuccess(
            context,
            failureCount > 0
                ? 'Created $successCount play activities ($failureCount failed)'
                : 'Play activities created successfully',
          );
        } else {
          CustomSnackbar.showError(context, 'Failed to create play activities');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        CustomSnackbar.showError(context, 'Error: $e');
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
            const HeaderCheckOutWidget(isIcon: false, title: 'Play Activity'),
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
                            onTimeTap: _selectStartTime,
                            onAmPmTap: _toggleStartAmPm,
                            enabled: true,
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
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider),
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
  final DateTime? time;
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
    final hasValue = time != null;
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
                  hasValue ? _formatTimeForDisplay(time!) : 'Select',
                  style: TextStyle(
                    color: hasValue
                        ? (enabled
                              ? AppColors.textPrimary
                              : AppColors.textTertiary)
                        : AppColors.textTertiary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasValue) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: enabled ? onAmPmTap : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppColors.primaryLight
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getAmPm(time!),
                      style: TextStyle(
                        color: enabled
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
