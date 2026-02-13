import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/palette.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';

/// Bottom sheet for creating a new lesson (Learn activity).
/// Unlike other activities, no children need to be selected beforehand.
class CreateNewLessenBottomSheet extends StatefulWidget {
  const CreateNewLessenBottomSheet({super.key});

  @override
  State<CreateNewLessenBottomSheet> createState() =>
      _CreateNewLessenBottomSheetState();
}

class _CreateNewLessenBottomSheetState
    extends State<CreateNewLessenBottomSheet> {
  final LearningPlanApi _api = GetIt.instance<LearningPlanApi>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _images = [];
  final List<String> _tags = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  List<LearningCategoryItem> _categories = [];
  List<AgeGroupItem> _ageGroups = [];
  List<ClassItem> _classes = [];
  bool _isLoadingOptions = true;
  String? _loadError;

  String? _selectedCategoryId;
  String? _selectedAgeGroupId;
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoadingOptions = true;
      _loadError = null;
    });
    try {
      _categories = await _api.getLearningCategories();
      if (!mounted) return;
      setState(() {});

      _ageGroups = await _api.getAgeGroups();
      if (!mounted) return;
      setState(() {});

      _classes = await _api.getClasses();
      if (!mounted) return;
      setState(() {
        _isLoadingOptions = false;
        _loadError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOptions = false;
          _loadError = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _videoLinkController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = _endDate ?? _startDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _handleAdd() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter a lesson title');
      return;
    }
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please select a category');
      return;
    }
    if (_startDate == null || _endDate == null) {
      CustomSnackbar.showWarning(context, 'Please select start and end date');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      CustomSnackbar.showWarning(context, 'End date must be after start date');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _api.createLearningPlan(
        title: title,
        category: _selectedCategoryId!,
        startDate: _formatDate(_startDate!),
        endDate: _formatDate(_endDate!),
        ageGroupId: _selectedAgeGroupId,
        classId: _selectedClassId,
        videoLink: _videoLinkController.text.trim().isEmpty
            ? null
            : _videoLinkController.text.trim(),
        tags: _tags.isEmpty ? null : _tags,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      CustomSnackbar.showSuccess(context, 'Learning plan created successfully');
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _onImagesChanged(List<File> images) {
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  void _onTagSubmitted(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _onTagRemoved(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  LearningCategoryItem? _categoryById(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  LearningCategoryItem? _categoryByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  AgeGroupItem? _ageGroupById(String? id) {
    if (id == null) return null;
    try {
      return _ageGroups.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  AgeGroupItem? _ageGroupByName(String name) {
    try {
      return _ageGroups.firstWhere((a) => a.name == name);
    } catch (_) {
      return null;
    }
  }

  ClassItem? _classById(String? id) {
    if (id == null) return null;
    try {
      return _classes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  ClassItem? _classByRoomName(String roomName) {
    try {
      return _classes.firstWhere((c) => c.roomName == roomName);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetWrapper(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeaderCheckOutWidget(isIcon: false, title: 'Create New Lesson'),
            const Divider(height: 1, color: AppColors.dividerDark),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Lesson Title'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Autumn Leaf Collage',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Duration'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickStartDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_calanders.svg',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _startDate != null
                                      ? DateFormat(
                                          'MMM d, yyyy',
                                        ).format(_startDate!)
                                      : 'Start date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _startDate != null
                                        ? Palette.textForeground
                                        : Colors.black38,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickEndDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_calanders.svg',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _endDate != null
                                      ? DateFormat(
                                          'MMM d, yyyy',
                                        ).format(_endDate!)
                                      : 'End date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _endDate != null
                                        ? Palette.textForeground
                                        : Colors.black38,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_isLoadingOptions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_loadError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            _loadError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loadOptions,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    MealTypeSelectorWidget(
                      title: 'Category',
                      options: _categories.map((c) => c.name).toList(),
                      selectedValue: _categoryById(_selectedCategoryId)?.name,
                      onChanged: (value) => setState(() {
                        _selectedCategoryId = value == null
                            ? null
                            : _categoryByName(value)?.id;
                      }),
                    ),
                    const SizedBox(height: 24),
                    MealTypeSelectorWidget(
                      title: 'Age Band',
                      options: _ageGroups.map((a) => a.name).toList(),
                      selectedValue: _ageGroupById(_selectedAgeGroupId)?.name,
                      onChanged: (value) => setState(() {
                        _selectedAgeGroupId = value == null
                            ? null
                            : _ageGroupByName(value)?.id;
                      }),
                    ),
                    const SizedBox(height: 24),
                    MealTypeSelectorWidget(
                      title: 'Class',
                      options: _classes.map((c) => c.roomName).toList(),
                      selectedValue: _classById(_selectedClassId)?.roomName,
                      onChanged: (value) => setState(() {
                        _selectedClassId = value == null
                            ? null
                            : _classByRoomName(value)?.id;
                      }),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildLabel('Video Link'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _videoLinkController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Enter the video link',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tag Section (same as other activities)
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
                  // Description (same as other activities)
                  NoteWidget(
                    title: 'Description',
                    hintText: 'Please enter a description',
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 20),
                  // Add Attachment (photo/video from gallery or camera, or any file e.g. PDF)
                  AttachPhotoWidget(
                    images: _images,
                    onImagesChanged: _onImagesChanged,
                    buttonLabel: 'Add Attachment',
                    showAttachFileOption: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.borderPrimary80,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CupertinoActivityIndicator(
                                radius: 11,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
