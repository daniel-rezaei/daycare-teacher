import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/core/widgets/staff_avatar_widget.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_accident_api.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/activity/widgets/multi_select_type_selector_widget.dart';
import 'package:teacher_app/features/auth/data/models/staff_class_model/staff_class_model.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/features/home/data/data_source/home_api.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AccidentActivityBottomSheet extends StatefulWidget {
  final ChildEntity selectedChild; // Only ONE child for accident
  final DateTime dateTime;

  const AccidentActivityBottomSheet({
    super.key,
    required this.selectedChild,
    required this.dateTime,
  });

  @override
  State<AccidentActivityBottomSheet> createState() =>
      _AccidentActivityBottomSheetState();
}

class _AccidentActivityBottomSheetState
    extends State<AccidentActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _images = [];

  // Field selections (multi-select for enum fields)
  List<String> _selectedNatureOfInjury = [];
  List<String> _selectedInjuredBodyPart = [];
  List<String> _selectedLocation = [];
  List<String> _selectedFirstAidProvided = [];
  List<String> _selectedChildReaction = [];
  String? _selectedNotifyBy;
  String? _selectedDateNotified;
  DateTime? _selectedDateTimeNotified; // Custom date/time selection

  // Options loaded from backend
  List<String> _natureOfInjuryOptions = [];
  List<String> _injuredBodyPartOptions = [];
  List<String> _locationOptions = [];
  List<String> _firstAidProvidedOptions = [];
  List<String> _childReactionOptions = [];
  List<String> _notifyByOptions = [];
  List<String> _dateNotifiedOptions = [];

  // Staff
  List<StaffClassModel> _staffList = [];
  Set<String> _selectedStaffIds =
      {}; // Multi-select for staff (using contactId)

  // Class ID for fetching staff
  String? _classId;

  bool _isLoadingOptions = true;
  bool _isLoadingStaff = true;
  bool _isSubmitting = false;
  bool _medicalFollowUpRequired = false;
  bool _incidentReportedToAuthority = false;
  bool _parentNotified = false;

  final ActivityAccidentApi _api = GetIt.instance<ActivityAccidentApi>();
  final HomeApi _homeApi = GetIt.instance<HomeApi>();
  final FileUploadUsecase _fileUploadUsecase =
      GetIt.instance<FileUploadUsecase>();

  @override
  void initState() {
    super.initState();
    debugPrint(
      '[ACCIDENT_ACTIVITY] ========== Opening AccidentActivityBottomSheet ==========',
    );
    debugPrint(
      '[ACCIDENT_ACTIVITY] Selected child: ${widget.selectedChild.id}',
    );
    debugPrint('[ACCIDENT_ACTIVITY] DateTime: ${widget.dateTime}');

    _loadClassId();
    _loadAllOptions();
    _loadStaff();
  }

  Future<void> _loadClassId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedClassId = prefs.getString(AppConstants.classIdKey);
      if (savedClassId != null && savedClassId.isNotEmpty) {
        setState(() {
          _classId = savedClassId;
        });
        debugPrint('[ACCIDENT_ACTIVITY] ClassId loaded: $_classId');
      } else {
        debugPrint(
          '[ACCIDENT_ACTIVITY] ⚠️ ClassId not found in SharedPreferences',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[ACCIDENT_ACTIVITY] Error loading classId: $e');
      debugPrint('[ACCIDENT_ACTIVITY] StackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });

    try {
      final results = await Future.wait([
        _api.getNatureOfInjuryOptions(),
        _api.getInjuredBodyPartOptions(),
        _api.getLocationOptions(),
        _api.getFirstAidProvidedOptions(),
        _api.getChildReactionOptions(),
        _api.getNotifyByOptions(),
        _api.getDateNotifiedOptions(),
      ]);

      if (mounted) {
        setState(() {
          _natureOfInjuryOptions = results[0];
          _injuredBodyPartOptions = results[1];
          _locationOptions = results[2];
          _firstAidProvidedOptions = results[3];
          _childReactionOptions = results[4];
          _notifyByOptions = results[5];
          _dateNotifiedOptions = results[6];
          _isLoadingOptions = false;
        });
        debugPrint('[ACCIDENT_ACTIVITY] All options loaded successfully');
      }
    } catch (e, stackTrace) {
      debugPrint('[ACCIDENT_ACTIVITY] Error loading options: $e');
      debugPrint('[ACCIDENT_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingOptions = false;
        });
      }
    }
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoadingStaff = true;
    });

    try {
      debugPrint('[ACCIDENT_ACTIVITY] Loading all staff from all classes');
      final response = await _homeApi.getAllStaff();
      final List<dynamic> data = response.data['data'] as List<dynamic>;

      // Parse all staff
      final allStaff = data
          .map((e) => StaffClassModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Remove duplicates based on staff_id (a staff might be in multiple classes)
      final Map<String, StaffClassModel> uniqueStaffMap = {};
      for (final staff in allStaff) {
        if (staff.contactId != null && staff.contactId!.isNotEmpty) {
          if (!uniqueStaffMap.containsKey(staff.contactId)) {
            uniqueStaffMap[staff.contactId!] = staff;
          }
        }
      }

      final uniqueStaffList = uniqueStaffMap.values.toList();

      if (mounted) {
        setState(() {
          _staffList = uniqueStaffList;
          _isLoadingStaff = false;
        });
        debugPrint(
          '[ACCIDENT_ACTIVITY] All staff loaded: ${_staffList.length} unique members (from ${allStaff.length} total records)',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[ACCIDENT_ACTIVITY] Error loading staff: $e');
      debugPrint('[ACCIDENT_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingStaff = false;
        });
      }
    }
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[ACCIDENT_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  void _toggleStaffSelection(String contactId) {
    setState(() {
      if (_selectedStaffIds.contains(contactId)) {
        _selectedStaffIds.remove(contactId);
      } else {
        _selectedStaffIds.add(contactId);
      }
    });
    debugPrint(
      '[ACCIDENT_ACTIVITY] Selected staff contact IDs: $_selectedStaffIds',
    );
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      debugPrint('[ACCIDENT_ACTIVITY] Uploading photo: ${imageFile.path}');
      final uploadResult = await _fileUploadUsecase.uploadFile(
        filePath: imageFile.path,
      );
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        debugPrint(
          '[ACCIDENT_ACTIVITY] Photo uploaded successfully: ${uploadResult.data}',
        );
        return uploadResult.data;
      } else {
        debugPrint('[ACCIDENT_ACTIVITY] Photo upload failed');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('[ACCIDENT_ACTIVITY] Error uploading photo: $e');
      debugPrint('[ACCIDENT_ACTIVITY] StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> _handleAdd() async {
    debugPrint('[ACCIDENT_ACTIVITY] ========== Add button pressed ==========');
    debugPrint(
      '[ACCIDENT_ACTIVITY] Selected child: ${widget.selectedChild.id}',
    );
    debugPrint(
      '[ACCIDENT_ACTIVITY] Nature of injury: $_selectedNatureOfInjury',
    );
    debugPrint(
      '[ACCIDENT_ACTIVITY] Injured body part: $_selectedInjuredBodyPart',
    );
    debugPrint('[ACCIDENT_ACTIVITY] Location: $_selectedLocation');
    debugPrint(
      '[ACCIDENT_ACTIVITY] First aid provided: $_selectedFirstAidProvided',
    );
    debugPrint('[ACCIDENT_ACTIVITY] Child reaction: $_selectedChildReaction');
    debugPrint('[ACCIDENT_ACTIVITY] Staff IDs: $_selectedStaffIds');
    debugPrint('[ACCIDENT_ACTIVITY] Date notified: $_selectedDateNotified');
    debugPrint(
      '[ACCIDENT_ACTIVITY] Medical follow-up: $_medicalFollowUpRequired',
    );
    debugPrint(
      '[ACCIDENT_ACTIVITY] Incident reported: $_incidentReportedToAuthority',
    );
    debugPrint('[ACCIDENT_ACTIVITY] Parent notified: $_parentNotified');
    debugPrint('[ACCIDENT_ACTIVITY] Notify by: $_selectedNotifyBy');
    debugPrint(
      '[ACCIDENT_ACTIVITY] Description: ${_descriptionController.text}',
    );
    debugPrint('[ACCIDENT_ACTIVITY] Images: ${_images.length}');

    // Validation
    if (widget.selectedChild.id == null || widget.selectedChild.id!.isEmpty) {
      debugPrint('[ACCIDENT_ACTIVITY] Validation failed: Child ID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child ID not found. Please try again.')),
      );
      return;
    }

    if (_classId == null || _classId!.isEmpty) {
      debugPrint('[ACCIDENT_ACTIVITY] Validation failed: No classId available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class ID not found. Please try again.')),
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
      debugPrint('[ACCIDENT_ACTIVITY] start_at (UTC): $startAtUtc');

      // Format date_time in UTC ISO 8601 format for Step B
      final dateTimeUtc = widget.dateTime.toUtc().toIso8601String();
      debugPrint('[ACCIDENT_ACTIVITY] date_time (UTC): $dateTimeUtc');

      // STEP A: Create parent activity
      debugPrint(
        '[ACCIDENT_ACTIVITY] STEP A: Creating activity for child ${widget.selectedChild.id}',
      );
      final activityId = await _api.createActivity(
        childId: widget.selectedChild.id!,
        classId: _classId!,
        startAtUtc: startAtUtc,
      );
      debugPrint('[ACCIDENT_ACTIVITY] ✅ Activity created with ID: $activityId');

      // STEP B: Create accident details linked to activity
      debugPrint(
        '[ACCIDENT_ACTIVITY] STEP B: Creating accident details for activity $activityId',
      );
      final response = await _api.createAccidentDetails(
        activityId: activityId,
        childId: widget.selectedChild.id!,
        dateTime: dateTimeUtc,
        natureOfInjuryTexts: _selectedNatureOfInjury,
        injuredBodyTypeTexts: _selectedInjuredBodyPart,
        locationTexts: _selectedLocation,
        firstAidProvidedTexts: _selectedFirstAidProvided,
        childReactionTexts: _selectedChildReaction,
        staffIds: _selectedStaffIds.toList(),
        dateTimeNotifiedText: _selectedDateTimeNotified != null
            ? _selectedDateTimeNotified!.toUtc().toIso8601String()
            : _selectedDateNotified,
        medicalFollowUpRequired: _medicalFollowUpRequired,
        incidentReportedToAuthority: _incidentReportedToAuthority,
        parentNotified: _parentNotified,
        notifyByText: _selectedNotifyBy,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        photo: photoFileId,
      );

      debugPrint(
        '[ACCIDENT_ACTIVITY] ✅ Accident details created: ${response.statusCode}',
      );
      debugPrint('[ACCIDENT_ACTIVITY] Response data: ${response.data}');

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Close bottom sheet first
        Navigator.pop(context);
        // Navigate back to LogActivityScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogActivityScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accident activity created successfully'),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[ACCIDENT_ACTIVITY] Error in _handleAdd: $e');
      debugPrint('[ACCIDENT_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  String _getStaffName(StaffClassModel staff) {
    final firstName = staff.firstName ?? '';
    final lastName = staff.lastName ?? '';
    return '$firstName $lastName'.trim().isEmpty
        ? 'Unknown'
        : '$firstName $lastName'.trim();
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
            const HeaderCheckOut(isIcon: false, title: 'Accident Activity'),
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

                  // Loading indicator
                  // Note: Child information is available in widget.selectedChild but not displayed
                  if (_isLoadingOptions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // Nature of Injury (Multi-select)
                    MultiSelectTypeSelectorWidget(
                      title: 'Nature of Injury',
                      options: _natureOfInjuryOptions,
                      selectedValues: _selectedNatureOfInjury,
                      onChanged: (values) {
                        setState(() {
                          _selectedNatureOfInjury = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Injured Body Part (Multi-select)
                    MultiSelectTypeSelectorWidget(
                      title: 'Injured Body Part',
                      options: _injuredBodyPartOptions,
                      selectedValues: _selectedInjuredBodyPart,
                      onChanged: (values) {
                        setState(() {
                          _selectedInjuredBodyPart = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Location (Multi-select)
                    MultiSelectTypeSelectorWidget(
                      title: 'Location',
                      options: _locationOptions,
                      selectedValues: _selectedLocation,
                      onChanged: (values) {
                        setState(() {
                          _selectedLocation = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // First Aid Provided (Multi-select)
                    MultiSelectTypeSelectorWidget(
                      title: 'First Aid Provided',
                      options: _firstAidProvidedOptions,
                      selectedValues: _selectedFirstAidProvided,
                      onChanged: (values) {
                        setState(() {
                          _selectedFirstAidProvided = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Child's Reaction (Multi-select)
                    MultiSelectTypeSelectorWidget(
                      title: 'Child\'s Reaction',
                      options: _childReactionOptions,
                      selectedValues: _selectedChildReaction,
                      onChanged: (values) {
                        setState(() {
                          _selectedChildReaction = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Staff Involved (Multi-select)
                    const Text(
                      'Staff Involved',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingStaff)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _staffList.length,
                          itemBuilder: (context, index) {
                            final staff = _staffList[index];
                            final contactId = staff.contactId ?? '';
                            final isSelected = _selectedStaffIds.contains(
                              contactId,
                            );

                            return GestureDetector(
                              onTap: () => _toggleStaffSelection(contactId),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _StaffCircleItem(
                                  photoId: staff.photoId,
                                  name: _getStaffName(staff),
                                  role: staff.role ?? 'Staff',
                                  isSelected: isSelected,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Date Notified
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date Notified',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            if (_selectedDateTimeNotified != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  DateFormat(
                                    'MMM d, yyyy h:mm a',
                                  ).format(_selectedDateTimeNotified!),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showModalBottomSheet<DateTime>(
                                  context: context,
                                  builder: (context) => Container(
                                    height: 300,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                final selected = DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                  now.hour,
                                                  now.minute,
                                                );
                                                Navigator.pop(
                                                  context,
                                                  selected,
                                                );
                                              },
                                              child: const Text('Done'),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode
                                                .dateAndTime,
                                            initialDateTime:
                                                _selectedDateTimeNotified ??
                                                now,
                                            minimumDate: DateTime(now.year - 1),
                                            maximumDate: now,
                                            onDateTimeChanged:
                                                (DateTime newDateTime) {
                                                  // Update will be handled when Done is pressed
                                                },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDateTimeNotified = picked;
                                    _selectedDateNotified =
                                        null; // Clear dropdown selection
                                  });
                                }
                              },
                              child: Assets.images.calendarDate.svg(
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Medical Follow-Up Required
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Medical Follow-Up required',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: _medicalFollowUpRequired,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _medicalFollowUpRequired = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Incident Reported to Authority
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Incident Reported to Authority',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: _incidentReportedToAuthority,
                            activeColor: Colors.purple,
                            onChanged: (value) {
                              setState(() {
                                _incidentReportedToAuthority = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Parent Notified
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Parent Notified',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: _parentNotified,
                            activeColor: Colors.purple,
                            onChanged: (value) {
                              setState(() {
                                _parentNotified = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // How To Notify
                    if (_notifyByOptions.isNotEmpty)
                      MealTypeSelectorWidget(
                        title: 'How To Notify',
                        options: _notifyByOptions,
                        selectedValue: _selectedNotifyBy,
                        onChanged: (value) {
                          setState(() {
                            _selectedNotifyBy = value;
                          });
                        },
                      ),
                    if (_notifyByOptions.isNotEmpty) const SizedBox(height: 24),

                    // Description Field
                    NoteWidget(
                      title: 'Description',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Staff Circle Item that uses StaffAvatar instead of AssetImage
class _StaffCircleItem extends StatelessWidget {
  final String? photoId;
  final String name;
  final String role;
  final bool isSelected;

  const _StaffCircleItem({
    required this.photoId,
    required this.name,
    required this.role,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 130,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Border Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.white,
                    width: 1,
                  ),
                ),
              ),

              // Avatar
              StaffAvatar(photoId: photoId, size: 72),

              // Check Badge
              if (isSelected)
                Positioned(
                  bottom: 0,
                  right: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: SvgPicture.asset('assets/images/ic_radio_check.svg'),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
