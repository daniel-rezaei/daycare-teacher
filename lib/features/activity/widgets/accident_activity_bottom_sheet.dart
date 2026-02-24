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
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/core/widgets/staff_avatar_widget.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_accident_api.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/activity/widgets/multi_select_type_selector_widget.dart';
import 'package:teacher_app/features/auth/data/models/staff_class_model/staff_class_model.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/child_management/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_management/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_management/widgets/note_widget.dart';
import 'package:teacher_app/features/activity/domain/usecase/file_upload_usecase.dart';
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

  // Staff
  List<StaffClassModel> _staffList = [];
  final Set<String> _selectedStaffIds =
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
    _loadClassId();
    _loadAllOptions();
    _loadStaff();
  }

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
          _isLoadingOptions = false;
        });
      }
    } catch (e) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStaff = false;
        });
      }
    }
  }

  void _onImagesChanged(List<File> images) {
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
    if (widget.selectedChild.id == null || widget.selectedChild.id!.isEmpty) {
      CustomSnackbar.showError(context, 'Child ID not found. Please try again.');
      return;
    }

    if (_classId == null || _classId!.isEmpty) {
      CustomSnackbar.showError(context, 'Class ID not found. Please try again.');
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

      // Format date_time in UTC ISO 8601 format for Step B
      final dateTimeUtc = widget.dateTime.toUtc().toIso8601String();

      // STEP A: Create parent activity
      final activityId = await _api.createActivity(
        childId: widget.selectedChild.id!,
        classId: _classId!,
        startAtUtc: startAtUtc,
      );

      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString(AppConstants.staffIdKey);
      // STEP B: Create accident details linked to activity
      await _api.createAccidentDetails(
        activityId: activityId,
        childId: widget.selectedChild.id!,
        dateTime: dateTimeUtc,
        natureOfInjuryTexts: _selectedNatureOfInjury,
        injuredBodyTypeTexts: _selectedInjuredBodyPart,
        locationTexts: _selectedLocation,
        firstAidProvidedTexts: _selectedFirstAidProvided,
        childReactionTexts: _selectedChildReaction,
        staffIds: _selectedStaffIds.toList(),
        staffId: staffId,
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
        CustomSnackbar.showSuccess(context, 'Accident activity created successfully');
      }
    } catch (e) {
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
            const HeaderCheckOutWidget(isIcon: false, title: 'Accident Activity'),
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
                                  builder: (context) => SizedBox(
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

// Custom Staff Circle Item that uses StaffAvatarWidget instead of AssetImage
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
    return SizedBox(
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
              StaffAvatarWidget(photoId: photoId, size: 72),

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
