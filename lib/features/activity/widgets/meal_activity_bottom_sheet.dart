import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_meals_api.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/core/data_state.dart';

class MealActivityBottomSheet extends StatefulWidget {
  final List<ChildEntity> selectedChildren;
  final DateTime dateTime;

  const MealActivityBottomSheet({
    super.key,
    required this.selectedChildren,
    required this.dateTime,
  });

  @override
  State<MealActivityBottomSheet> createState() => _MealActivityBottomSheetState();
}

class _MealActivityBottomSheetState extends State<MealActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _images = [];
  
  String? _selectedMealType;
  String? _selectedQuantity;
  List<String> _tags = [];
  
  bool _isSubmitting = false;
  final ActivityMealsApi _api = GetIt.instance<ActivityMealsApi>();
  final FileUploadUsecase _fileUploadUsecase = GetIt.instance<FileUploadUsecase>();

  @override
  void initState() {
    super.initState();
    debugPrint('[MEAL_ACTIVITY] ========== Opening MealActivityBottomSheet ==========');
    debugPrint('[MEAL_ACTIVITY] Selected children count: ${widget.selectedChildren.length}');
    debugPrint('[MEAL_ACTIVITY] DateTime: ${widget.dateTime}');
    
    // Load meal types and quantities from API
    _loadMealTypes();
    _loadQuantities();
    // Tags are LOCAL-ONLY - no API loading needed
    debugPrint('[MEAL_ACTIVITY] Tags are LOCAL-ONLY - no API calls for tags');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMealTypes() async {
    try {
      debugPrint('[MEAL_ACTIVITY] Loading meal types...');
      final response = await _api.getMealTypes();
      debugPrint('[MEAL_ACTIVITY] Meal types response: ${response.statusCode}');
      // Extract unique meal types from response
      // This would need to be implemented based on actual API response structure
    } catch (e, stackTrace) {
      debugPrint('[MEAL_ACTIVITY] Error loading meal types: $e');
      debugPrint('[MEAL_ACTIVITY] StackTrace: $stackTrace');
    }
  }

  Future<void> _loadQuantities() async {
    try {
      debugPrint('[MEAL_ACTIVITY] Loading quantities...');
      final response = await _api.getQuantities();
      debugPrint('[MEAL_ACTIVITY] Quantities response: ${response.statusCode}');
      // Extract unique quantities from response
    } catch (e, stackTrace) {
      debugPrint('[MEAL_ACTIVITY] Error loading quantities: $e');
      debugPrint('[MEAL_ACTIVITY] StackTrace: $stackTrace');
    }
  }

  // Tags are LOCAL-ONLY - no API loading method needed
  // Removed _loadTags() - tags are display-only and local-editable

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  void _onMealTypeChanged(String? value) {
    debugPrint('[MEAL_ACTIVITY] Meal type changed: $value');
    setState(() {
      _selectedMealType = value;
    });
  }

  void _onQuantityChanged(String? value) {
    debugPrint('[MEAL_ACTIVITY] Quantity changed: $value');
    setState(() {
      _selectedQuantity = value;
    });
  }

  void _onTagRemoved(String tag) {
    debugPrint('[MEAL_ACTIVITY] ========== Tag removed (LOCAL ONLY) ==========');
    debugPrint('[MEAL_ACTIVITY] Tag removed locally: $tag');
    debugPrint('[MEAL_ACTIVITY] NO API call executed for tag removal');
    debugPrint('[MEAL_ACTIVITY] Tags are LOCAL-ONLY - changes stay in UI');
    setState(() {
      _tags.remove(tag);
    });
    debugPrint('[MEAL_ACTIVITY] Tag removed successfully - remaining tags: ${_tags.length}');
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[MEAL_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      debugPrint('[MEAL_ACTIVITY] Uploading photo: ${imageFile.path}');
      final uploadResult = await _fileUploadUsecase.uploadFile(filePath: imageFile.path);
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        debugPrint('[MEAL_ACTIVITY] Photo uploaded successfully: ${uploadResult.data}');
        return uploadResult.data;
      } else {
        debugPrint('[MEAL_ACTIVITY] Photo upload failed');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('[MEAL_ACTIVITY] Error uploading photo: $e');
      debugPrint('[MEAL_ACTIVITY] StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> _handleAdd() async {
    debugPrint('[MEAL_ACTIVITY] ========== Add button pressed ==========');
    debugPrint('[MEAL_ACTIVITY] Selected children: ${widget.selectedChildren.length}');
    debugPrint('[MEAL_ACTIVITY] Meal type: $_selectedMealType');
    debugPrint('[MEAL_ACTIVITY] Quantity: $_selectedQuantity');
    debugPrint('[MEAL_ACTIVITY] Tags (LOCAL-ONLY, NOT sent to API): $_tags');
    debugPrint('[MEAL_ACTIVITY] Description: ${_descriptionController.text}');
    debugPrint('[MEAL_ACTIVITY] Images: ${_images.length}');
    debugPrint('[MEAL_ACTIVITY] CRITICAL: Tags will NOT be included in API payload');

    // Validation
    if (widget.selectedChildren.isEmpty) {
      debugPrint('[MEAL_ACTIVITY] Validation failed: No children selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one child')),
      );
      return;
    }

    if (_selectedMealType == null || _selectedMealType!.isEmpty) {
      debugPrint('[MEAL_ACTIVITY] Validation failed: No meal type selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a meal type')),
      );
      return;
    }

    if (_selectedQuantity == null || _selectedQuantity!.isEmpty) {
      debugPrint('[MEAL_ACTIVITY] Validation failed: No quantity selected');
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

      // Format date_time in UTC ISO 8601 format
      final dateTimeUtc = widget.dateTime.toUtc().toIso8601String();
      debugPrint('[MEAL_ACTIVITY] date_time (UTC): $dateTimeUtc');

      // CRITICAL: Tags are LOCAL-ONLY - NOT included in API payload
      debugPrint('[MEAL_ACTIVITY] Tags are LOCAL-ONLY - NOT sending to API');
      debugPrint('[MEAL_ACTIVITY] Current tags (local only): $_tags');
      debugPrint('[MEAL_ACTIVITY] Tags will NOT be included in API request');

      // Create meal activity for each selected child
      int successCount = 0;
      int failureCount = 0;

      for (final child in widget.selectedChildren) {
        if (child.id == null || child.id!.isEmpty) {
          debugPrint('[MEAL_ACTIVITY] Skipping child with null ID');
          failureCount++;
          continue;
        }

        try {
          debugPrint('[MEAL_ACTIVITY] Creating meal activity for child: ${child.id}');
          debugPrint('[MEAL_ACTIVITY] NOT including tags in API call (tags are LOCAL-ONLY)');
          final response = await _api.createMealActivity(
            childId: child.id!,
            dateTime: dateTimeUtc,
            mealType: _selectedMealType!,
            quantity: _selectedQuantity!,
            // Tags are LOCAL-ONLY - NOT sent to API
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            photo: photoFileId,
          );

          debugPrint('[MEAL_ACTIVITY] Meal activity created for child ${child.id}: ${response.statusCode}');
          debugPrint('[MEAL_ACTIVITY] Response data: ${response.data}');
          successCount++;
        } catch (e, stackTrace) {
          debugPrint('[MEAL_ACTIVITY] Error creating meal activity for child ${child.id}: $e');
          debugPrint('[MEAL_ACTIVITY] StackTrace: $stackTrace');
          failureCount++;
        }
      }

      debugPrint('[MEAL_ACTIVITY] ========== Submission complete ==========');
      debugPrint('[MEAL_ACTIVITY] Success: $successCount, Failures: $failureCount');

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (successCount > 0) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failureCount > 0
                    ? 'Created $successCount meal activities (${failureCount} failed)'
                    : 'Meal activities created successfully',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create meal activities')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[MEAL_ACTIVITY] Error in _handleAdd: $e');
      debugPrint('[MEAL_ACTIVITY] StackTrace: $stackTrace');
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
            const HeaderCheckOut(isIcon: false, title: 'Meal Activity'),
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
                  MealTypeSelectorWidget(
                    title: 'Type',
                    selectedValue: _selectedMealType,
                    onChanged: _onMealTypeChanged,
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  MealTypeSelectorWidget(
                    title: 'Quantity',
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
                  const SizedBox(height: 8),
                  if (_tags.isEmpty)
                    const Text(
                      'No tags added',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _onTagRemoved(tag),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
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

