import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_observation_api.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/core/data_state.dart';

class ObservationActivityBottomSheet extends StatefulWidget {
  final List<ChildEntity> selectedChildren;
  final DateTime dateTime;

  const ObservationActivityBottomSheet({
    super.key,
    required this.selectedChildren,
    required this.dateTime,
  });

  @override
  State<ObservationActivityBottomSheet> createState() => _ObservationActivityBottomSheetState();
}

class _ObservationActivityBottomSheetState extends State<ObservationActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _images = [];
  
  CategoryModel? _selectedCategoryModel;
  String? _selectedCategoryName;
  String? _selectedDomainId;
  List<String> _tags = [];
  bool _followUpRequired = false;
  bool _shareWithParent = false;
  
  // Options loaded from backend
 List<CategoryModel> _categoryOptions = [];
  
  // Class ID for creating activities
  String? _classId;
  
  bool _isSubmitting = false;
  bool _isLoadingOptions = true;
  final ActivityObservationApi _api = GetIt.instance<ActivityObservationApi>();
  final FileUploadUsecase _fileUploadUsecase = GetIt.instance<FileUploadUsecase>();

  @override
  void initState() {
    super.initState();
    debugPrint('[OBSERVATION_ACTIVITY] ========== Opening ObservationActivityBottomSheet ==========');
    debugPrint('[OBSERVATION_ACTIVITY] Selected children count: ${widget.selectedChildren.length}');
    debugPrint('[OBSERVATION_ACTIVITY] DateTime: ${widget.dateTime}');
    
    // Load classId and options
    _loadClassId();
    _loadAllOptions();
  }

  Future<void> _loadClassId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedClassId = prefs.getString(AppConstants.classIdKey);
      if (savedClassId != null && savedClassId.isNotEmpty) {
        setState(() {
          _classId = savedClassId;
        });
        debugPrint('[OBSERVATION_ACTIVITY] ClassId loaded: $_classId');
      } else {
        debugPrint('[OBSERVATION_ACTIVITY] ⚠️ ClassId not found in SharedPreferences');
      }
    } catch (e, stackTrace) {
      debugPrint('[OBSERVATION_ACTIVITY] Error loading classId: $e');
      debugPrint('[OBSERVATION_ACTIVITY] StackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

Future<void> _loadCategoryOptions() async {
  try {
    debugPrint('[OBSERVATION_ACTIVITY] Loading categories from backend...');
    final categories = await _api.getCategoryOptions();

    debugPrint(
      '[OBSERVATION_ACTIVITY] Categories loaded: ${categories.map((e) => e.name).toList()}',
    );

    if (!mounted) return;

    setState(() {
      _categoryOptions = categories;
    });
  } catch (e, stackTrace) {
    debugPrint('[OBSERVATION_ACTIVITY] Error loading categories: $e');
    debugPrint('[OBSERVATION_ACTIVITY] StackTrace: $stackTrace');

    if (!mounted) return;

    setState(() {
      _categoryOptions = [];
    });
  }
}


  Future<void> _loadAllOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });
    await _loadCategoryOptions();
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

void _onCategoryNameChanged(String? name) {
  debugPrint('[OBSERVATION_ACTIVITY] Category changed: $name');

  if (name == null) {
    setState(() {
      _selectedCategoryName = null;
      _selectedCategoryModel = null;
      _selectedDomainId = null; // Clear domain when category is cleared
    });
    return;
  }

  try {
    final model = _categoryOptions.firstWhere(
      (c) => c.name == name,
    );

    setState(() {
      _selectedCategoryName = name;     // برای UI
      _selectedCategoryModel = model;   // برای backend
      _selectedDomainId = model.value;   // Set Domain ID to Category value
    });
    debugPrint('[OBSERVATION_ACTIVITY] Category selected: ${model.name} (value: ${model.value})');
    debugPrint('[OBSERVATION_ACTIVITY] Domain ID set to: ${model.value}');
  } catch (e) {
    debugPrint('[OBSERVATION_ACTIVITY] Error finding category: $e');
    setState(() {
      _selectedCategoryName = null;
      _selectedCategoryModel = null;
      _selectedDomainId = null;
    });
  }
}




  void _onTagSubmitted(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      debugPrint('[OBSERVATION_ACTIVITY] Adding tag: $tag');
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
      debugPrint('[OBSERVATION_ACTIVITY] Tag added successfully - total tags: ${_tags.length}');
    } else if (_tags.contains(tag)) {
      debugPrint('[OBSERVATION_ACTIVITY] Tag already exists: $tag');
    }
  }

  void _onTagRemoved(String tag) {
    debugPrint('[OBSERVATION_ACTIVITY] Tag removed: $tag');
    setState(() {
      _tags.remove(tag);
    });
    debugPrint('[OBSERVATION_ACTIVITY] Tag removed successfully - remaining tags: ${_tags.length}');
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[OBSERVATION_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      debugPrint('[OBSERVATION_ACTIVITY] Uploading photo: ${imageFile.path}');
      final uploadResult = await _fileUploadUsecase.uploadFile(filePath: imageFile.path);
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        debugPrint('[OBSERVATION_ACTIVITY] Photo uploaded successfully: ${uploadResult.data}');
        return uploadResult.data;
      } else {
        debugPrint('[OBSERVATION_ACTIVITY] Photo upload failed');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('[OBSERVATION_ACTIVITY] Error uploading photo: $e');
      debugPrint('[OBSERVATION_ACTIVITY] StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> _handleAdd() async {
    debugPrint('[OBSERVATION_ACTIVITY] ========== Add button pressed ==========');
    debugPrint('[OBSERVATION_ACTIVITY] Selected children: ${widget.selectedChildren.length}');
    debugPrint('[OBSERVATION_ACTIVITY] Domain ID: $_selectedDomainId');
    debugPrint('[OBSERVATION_ACTIVITY] Tags (Development Area): $_tags');
    debugPrint('[OBSERVATION_ACTIVITY] Description: ${_descriptionController.text}');
    debugPrint('[OBSERVATION_ACTIVITY] Images: ${_images.length}');
    debugPrint('[OBSERVATION_ACTIVITY] Follow-up required: $_followUpRequired');
    debugPrint('[OBSERVATION_ACTIVITY] Share with parent: $_shareWithParent');

    // Validation
    if (widget.selectedChildren.isEmpty) {
      debugPrint('[OBSERVATION_ACTIVITY] Validation failed: No children selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child')),
      );
      return;
    }

    if (widget.selectedChildren.length > 1) {
      debugPrint('[OBSERVATION_ACTIVITY] Validation failed: Multiple children selected (only one allowed)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select only one child for observation')),
      );
      return;
    }

    if (_classId == null || _classId!.isEmpty) {
      debugPrint('[OBSERVATION_ACTIVITY] Validation failed: No classId available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class ID not found. Please try again.')),
      );
      return;
    }

    if (_selectedCategoryModel == null) {
      debugPrint('[OBSERVATION_ACTIVITY] Validation failed: No category selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    // Domain ID is automatically set from selected category value
    if (_selectedDomainId == null || _selectedDomainId!.isEmpty) {
      debugPrint('[OBSERVATION_ACTIVITY] Validation failed: Domain ID not set from category');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
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

      // Format start_at in UTC ISO 8601 format
      final startAtUtc = widget.dateTime.toUtc().toIso8601String();
      debugPrint('[OBSERVATION_ACTIVITY] start_at (UTC): $startAtUtc');

      final child = widget.selectedChildren.first;
      if (child.id == null || child.id!.isEmpty) {
        debugPrint('[OBSERVATION_ACTIVITY] Skipping child with null ID');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid child selected')),
        );
        return;
      }

      try {
        debugPrint('[OBSERVATION_ACTIVITY] ========== Processing child: ${child.id} ==========');
        
        // STEP A: Create parent activity
        debugPrint('[OBSERVATION_ACTIVITY] STEP A: Creating activity for child ${child.id}');
        final activityId = await _api.createActivity(
          childId: child.id!,
          classId: _classId!,
          startAtUtc: startAtUtc,
        );
        debugPrint('[OBSERVATION_ACTIVITY] ✅ Activity created with ID: $activityId');

        // STEP B: Create observation details linked to activity
        debugPrint('[OBSERVATION_ACTIVITY] STEP B: Creating observation details for activity $activityId');
        final response = await _api.createObservationDetails(
          activityId: activityId,
          domainId: _selectedDomainId!,
          skillObserved: _selectedCategoryModel?.value,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          tags: _tags.isNotEmpty ? _tags : null,
          photo: photoFileId,
          followUpRequired: _followUpRequired,
          shareWithParent: _shareWithParent,
        );

        debugPrint('[OBSERVATION_ACTIVITY] ✅ Observation details created for child ${child.id}: ${response.statusCode}');
        debugPrint('[OBSERVATION_ACTIVITY] Response data: ${response.data}');

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

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
            const SnackBar(
              content: Text('Observation activity created successfully'),
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('[OBSERVATION_ACTIVITY] ❌ Error processing child ${child.id}: $e');
        debugPrint('[OBSERVATION_ACTIVITY] StackTrace: $stackTrace');
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[OBSERVATION_ACTIVITY] Error in _handleAdd: $e');
      debugPrint('[OBSERVATION_ACTIVITY] StackTrace: $stackTrace');
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
            const HeaderCheckOut(isIcon: false, title: 'Observation Activity'),
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

                         // Category Selector - BETWEEN Development Area and Date/Time
                  if (_isLoadingOptions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_categoryOptions.isNotEmpty)
                    MealTypeSelectorWidget(
                      title: 'Category',
                      options: _categoryOptions.map((e) => e.name).toList(),
                      selectedValue: _selectedCategoryName,
                      onChanged: _onCategoryNameChanged,
                    ),
                  if (_categoryOptions.isNotEmpty) const SizedBox(height: 24),
                  // Development Area (Tag) Section - BEFORE Category
                  const Text(
                    'Development Area',
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
                      hintText: 'Enter development area and press done',
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
                  const SizedBox(height: 20),

                  // Toggle Buttons: Follow-up required and Share with parent
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Follow - up required ?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _followUpRequired,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _followUpRequired = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Share with parent',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _shareWithParent,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _shareWithParent = value;
                            });
                          },
                        ),
                      ),
                    ],
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

