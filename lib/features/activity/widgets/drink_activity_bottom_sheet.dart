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
import 'package:teacher_app/features/activity/data/data_source/activity_drinks_api.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/core/data_state.dart';

class DrinkActivityBottomSheet extends StatefulWidget {
  final List<ChildEntity> selectedChildren;
  final DateTime dateTime;

  const DrinkActivityBottomSheet({
    super.key,
    required this.selectedChildren,
    required this.dateTime,
  });

  @override
  State<DrinkActivityBottomSheet> createState() => _DrinkActivityBottomSheetState();
}

class _DrinkActivityBottomSheetState extends State<DrinkActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _images = [];
  
  String? _selectedDrinkType;
  String? _selectedQuantity;
  List<String> _tags = [];
  
  // Options loaded from backend
  List<String> _drinkTypeOptions = [];
  List<String> _quantityOptions = [];
  
  // Class ID for creating activities
  String? _classId;
  
  bool _isSubmitting = false;
  bool _isLoadingOptions = true;
  final ActivityDrinksApi _api = GetIt.instance<ActivityDrinksApi>();
  final FileUploadUsecase _fileUploadUsecase = GetIt.instance<FileUploadUsecase>();

  @override
  void initState() {
    super.initState();
    debugPrint('[DRINK_ACTIVITY] ========== Opening DrinkActivityBottomSheet ==========');
    debugPrint('[DRINK_ACTIVITY] Selected children count: ${widget.selectedChildren.length}');
    debugPrint('[DRINK_ACTIVITY] DateTime: ${widget.dateTime}');
    
    // Load classId and drink options
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
        debugPrint('[DRINK_ACTIVITY] ClassId loaded: $_classId');
      } else {
        debugPrint('[DRINK_ACTIVITY] ⚠️ ClassId not found in SharedPreferences');
      }
    } catch (e, stackTrace) {
      debugPrint('[DRINK_ACTIVITY] Error loading classId: $e');
      debugPrint('[DRINK_ACTIVITY] StackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDrinkTypes() async {
    try {
      debugPrint('[DRINK_ACTIVITY] Loading drink types from backend...');
      final options = await _api.getDrinkTypes();
      debugPrint('[DRINK_ACTIVITY] Drink types loaded: $options');
      if (mounted) {
        setState(() {
          _drinkTypeOptions = options;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[DRINK_ACTIVITY] Error loading drink types: $e');
      debugPrint('[DRINK_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _drinkTypeOptions = [];
        });
      }
    }
  }

  Future<void> _loadQuantities() async {
    try {
      debugPrint('[DRINK_ACTIVITY] Loading quantities from backend...');
      final options = await _api.getQuantities();
      debugPrint('[DRINK_ACTIVITY] Quantities loaded: $options');
      if (mounted) {
        setState(() {
          _quantityOptions = options;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[DRINK_ACTIVITY] Error loading quantities: $e');
      debugPrint('[DRINK_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _quantityOptions = [];
        });
      }
    }
  }

  Future<void> _loadAllOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });
    await Future.wait([
      _loadDrinkTypes(),
      _loadQuantities(),
    ]);
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

  void _onDrinkTypeChanged(String? value) {
    debugPrint('[DRINK_ACTIVITY] Drink type changed: $value');
    setState(() {
      _selectedDrinkType = value;
    });
  }

  void _onQuantityChanged(String? value) {
    debugPrint('[DRINK_ACTIVITY] Quantity changed: $value');
    setState(() {
      _selectedQuantity = value;
    });
  }

  void _onTagSubmitted(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      debugPrint('[DRINK_ACTIVITY] Adding tag (LOCAL ONLY): $tag');
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
      debugPrint('[DRINK_ACTIVITY] Tag added successfully - total tags: ${_tags.length}');
    } else if (_tags.contains(tag)) {
      debugPrint('[DRINK_ACTIVITY] Tag already exists: $tag');
    }
  }

  void _onTagRemoved(String tag) {
    debugPrint('[DRINK_ACTIVITY] ========== Tag removed (LOCAL ONLY) ==========');
    debugPrint('[DRINK_ACTIVITY] Tag removed locally: $tag');
    debugPrint('[DRINK_ACTIVITY] NO API call executed for tag removal');
    debugPrint('[DRINK_ACTIVITY] Tags are LOCAL-ONLY - changes stay in UI');
    setState(() {
      _tags.remove(tag);
    });
    debugPrint('[DRINK_ACTIVITY] Tag removed successfully - remaining tags: ${_tags.length}');
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[DRINK_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      debugPrint('[DRINK_ACTIVITY] Uploading photo: ${imageFile.path}');
      final uploadResult = await _fileUploadUsecase.uploadFile(filePath: imageFile.path);
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        debugPrint('[DRINK_ACTIVITY] Photo uploaded successfully: ${uploadResult.data}');
        return uploadResult.data;
      } else {
        debugPrint('[DRINK_ACTIVITY] Photo upload failed');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('[DRINK_ACTIVITY] Error uploading photo: $e');
      debugPrint('[DRINK_ACTIVITY] StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> _handleAdd() async {
    debugPrint('[DRINK_ACTIVITY] ========== Add button pressed ==========');
    debugPrint('[DRINK_ACTIVITY] Selected children: ${widget.selectedChildren.length}');
    debugPrint('[DRINK_ACTIVITY] Drink type: $_selectedDrinkType');
    debugPrint('[DRINK_ACTIVITY] Quantity: $_selectedQuantity');
    debugPrint('[DRINK_ACTIVITY] Tags: $_tags');
    debugPrint('[DRINK_ACTIVITY] Description: ${_descriptionController.text}');
    debugPrint('[DRINK_ACTIVITY] Images: ${_images.length}');

    // Validation
    if (widget.selectedChildren.isEmpty) {
      debugPrint('[DRINK_ACTIVITY] Validation failed: No children selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one child')),
      );
      return;
    }

    if (_classId == null || _classId!.isEmpty) {
      debugPrint('[DRINK_ACTIVITY] Validation failed: No classId available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class ID not found. Please try again.')),
      );
      return;
    }

    if (_selectedDrinkType == null || _selectedDrinkType!.isEmpty) {
      debugPrint('[DRINK_ACTIVITY] Validation failed: No drink type selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a drink type')),
      );
      return;
    }

    if (_selectedQuantity == null || _selectedQuantity!.isEmpty) {
      debugPrint('[DRINK_ACTIVITY] Validation failed: No quantity selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a quantity')),
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
      debugPrint('[DRINK_ACTIVITY] start_at (UTC): $startAtUtc');

      // Two-step flow: Create activity (parent) then drink details (child) for EACH child
      int successCount = 0;
      int failureCount = 0;

      for (final child in widget.selectedChildren) {
        if (child.id == null || child.id!.isEmpty) {
          debugPrint('[DRINK_ACTIVITY] Skipping child with null ID');
          failureCount++;
          continue;
        }

        try {
          debugPrint('[DRINK_ACTIVITY] ========== Processing child: ${child.id} ==========');
          
          // STEP A: Create parent activity
          debugPrint('[DRINK_ACTIVITY] STEP A: Creating activity for child ${child.id}');
          final activityId = await _api.createActivity(
            childId: child.id!,
            classId: _classId!,
            startAtUtc: startAtUtc,
          );
          debugPrint('[DRINK_ACTIVITY] ✅ Activity created with ID: $activityId');

          // STEP B: Create drink details linked to activity
          debugPrint('[DRINK_ACTIVITY] STEP B: Creating drink details for activity $activityId');
          final response = await _api.createDrinkDetails(
            activityId: activityId,
            drinkType: _selectedDrinkType!,
            quantity: _selectedQuantity!,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            tags: _tags.isNotEmpty ? _tags : null,
            photo: photoFileId,
          );

          debugPrint('[DRINK_ACTIVITY] ✅ Drink details created for child ${child.id}: ${response.statusCode}');
          debugPrint('[DRINK_ACTIVITY] Response data: ${response.data}');
          successCount++;
        } catch (e, stackTrace) {
          debugPrint('[DRINK_ACTIVITY] ❌ Error processing child ${child.id}: $e');
          debugPrint('[DRINK_ACTIVITY] StackTrace: $stackTrace');
          failureCount++;
        }
      }

      debugPrint('[DRINK_ACTIVITY] ========== Submission complete ==========');
      debugPrint('[DRINK_ACTIVITY] Success: $successCount, Failures: $failureCount');

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
                    ? 'Created $successCount drink activities (${failureCount} failed)'
                    : 'Drink activities created successfully',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create drink activities')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[DRINK_ACTIVITY] Error in _handleAdd: $e');
      debugPrint('[DRINK_ACTIVITY] StackTrace: $stackTrace');
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
            const HeaderCheckOut(isIcon: false, title: 'Drink Activity'),
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
                    const SizedBox(height: 24),
                  ],

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
                      options: _drinkTypeOptions,
                      selectedValue: _selectedDrinkType,
                      onChanged: _onDrinkTypeChanged,
                    ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  if (!_isLoadingOptions)
                    MealTypeSelectorWidget(
                      title: 'Quantity',
                      options: _quantityOptions,
                      selectedValue: _selectedQuantity,
                      onChanged: _onQuantityChanged,
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

