import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';

class SleepActivityBottomSheet extends StatefulWidget {
  final List<ChildEntity> selectedChildren;
  final DateTime dateTime;
  final String? startAt; // activity_sleep.start_at
  final String? endAt; // activity_sleep.end_at
  final List<String> sleepMonitoringOptions; // activity_sleep.sleep_monitoring

  const SleepActivityBottomSheet({
    super.key,
    required this.selectedChildren,
    required this.dateTime,
    this.startAt,
    this.endAt,
    this.sleepMonitoringOptions = const [],
  });

  @override
  State<SleepActivityBottomSheet> createState() => _SleepActivityBottomSheetState();
}

class _SleepActivityBottomSheetState extends State<SleepActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _images = [];
  
  String? _selectedSleepMonitoring;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    debugPrint('[SLEEP_ACTIVITY] ========== Opening SleepActivityBottomSheet ==========');
    debugPrint('[SLEEP_ACTIVITY] Selected children count: ${widget.selectedChildren.length}');
    debugPrint('[SLEEP_ACTIVITY] DateTime: ${widget.dateTime}');
    debugPrint('[SLEEP_ACTIVITY] start_at: ${widget.startAt}');
    debugPrint('[SLEEP_ACTIVITY] end_at: ${widget.endAt}');
    debugPrint('[SLEEP_ACTIVITY] Sleep Monitoring options: ${widget.sleepMonitoringOptions.length}');
    debugPrint('[SLEEP_ACTIVITY] CRITICAL: This is READ-ONLY / LOCAL SELECT ONLY');
    debugPrint('[SLEEP_ACTIVITY] NO API mutations will be performed');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format time string from activity_sleep.start_at or end_at
  /// Expected format: "08:30" -> "08:30 PM" (with PM appended)
  String _formatSleepTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return '--:--';
    }
    
    try {
      // Parse time string (assuming format like "08:30" or "20:30")
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        
        // Determine AM/PM
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        
        // Format as "08:30 PM" (with leading zero for hour if needed)
        final formattedHour = displayHour.toString().padLeft(2, '0');
        return '$formattedHour:$minute $period';
      }
      return timeStr;
    } catch (e) {
      debugPrint('[SLEEP_ACTIVITY] Error formatting time: $e');
      return timeStr;
    }
  }

  void _onSleepMonitoringChanged(String? value) {
    debugPrint('[SLEEP_ACTIVITY] Sleep Monitoring changed: $value');
    debugPrint('[SLEEP_ACTIVITY] This is LOCAL SELECT ONLY - no API call');
    setState(() {
      _selectedSleepMonitoring = value;
    });
  }

  void _onTagRemoved(String tag) {
    debugPrint('[SLEEP_ACTIVITY] ========== Tag removed (LOCAL ONLY) ==========');
    debugPrint('[SLEEP_ACTIVITY] Tag removed locally: $tag');
    debugPrint('[SLEEP_ACTIVITY] NO API call executed for tag removal');
    setState(() {
      _tags.remove(tag);
    });
    debugPrint('[SLEEP_ACTIVITY] Tag removed successfully - remaining tags: ${_tags.length}');
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[SLEEP_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  void _handleAdd() {
    debugPrint('[SLEEP_ACTIVITY] ========== Add button pressed ==========');
    debugPrint('[SLEEP_ACTIVITY] CRITICAL: This is READ-ONLY / LOCAL SELECT ONLY');
    debugPrint('[SLEEP_ACTIVITY] NO API mutation will be performed');
    debugPrint('[SLEEP_ACTIVITY] Selected children: ${widget.selectedChildren.length}');
    debugPrint('[SLEEP_ACTIVITY] Start time: ${widget.startAt}');
    debugPrint('[SLEEP_ACTIVITY] End time: ${widget.endAt}');
    debugPrint('[SLEEP_ACTIVITY] Sleep Monitoring: $_selectedSleepMonitoring');
    debugPrint('[SLEEP_ACTIVITY] Tags (LOCAL-ONLY): $_tags');
    debugPrint('[SLEEP_ACTIVITY] Description: ${_descriptionController.text}');
    debugPrint('[SLEEP_ACTIVITY] Images: ${_images.length}');
    debugPrint('[SLEEP_ACTIVITY] ========== No API mutation - closing BottomSheet ==========');
    
    // This is READ-ONLY - just close the BottomSheet
    Navigator.pop(context);
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
            const HeaderCheckOut(isIcon: false, title: 'Sleep Activity'),
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

                  // Time Row: Start Time and End Time
                  Row(
                    children: [
                      // Column 1: Start Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatSleepTime(widget.startAt),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Column 2: End Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Time',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatSleepTime(widget.endAt),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sleep Monitoring Selector
                  MealTypeSelectorWidget(
                    title: 'Sleep Monitoring',
                    selectedValue: _selectedSleepMonitoring,
                    onChanged: _onSleepMonitoringChanged,
                    options: widget.sleepMonitoringOptions, // Loaded from activity_sleep.sleep_monitoring
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

                  // Add Button (READ-ONLY - just closes BottomSheet)
                  ButtonWidget(
                    isEnabled: true,
                    onTap: _handleAdd,
                    child: const Text(
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

