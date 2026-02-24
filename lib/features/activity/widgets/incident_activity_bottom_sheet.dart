import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/core/widgets/staff_avatar_widget.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_incident_api.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/activity/widgets/multi_select_type_selector_widget.dart';
import 'package:teacher_app/features/auth/data/models/staff_class_model/staff_class_model.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status_module/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status_module/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status_module/widgets/note_widget.dart';
import 'package:teacher_app/features/activity/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/features/home/data/data_source/home_api.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class IncidentActivityBottomSheet extends StatefulWidget {
  final ChildEntity selectedChild; // Only ONE child for incident
  final DateTime dateTime;

  const IncidentActivityBottomSheet({
    super.key,
    required this.selectedChild,
    required this.dateTime,
  });

  @override
  State<IncidentActivityBottomSheet> createState() =>
      _IncidentActivityBottomSheetState();
}

class _IncidentActivityBottomSheetState
    extends State<IncidentActivityBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _images = [];

  // Field selections
  List<String> _selectedNatureOfIncident = [];
  List<String> _selectedLocation = [];
  String? _selectedNotifyBy;

  // Persons Notified selections
  DateTime? _notifyParentDateTime;
  String? _notifyParentBy;
  DateTime? _notifyMinistryDateTime;
  String? _notifyMinistryBy;
  DateTime? _notifySupervisorDateTime;
  String? _notifySupervisorBy;
  DateTime? _notifyCasDateTime;
  String? _notifyCasBy;
  DateTime? _notifyPoliceDateTime;
  String? _notifyPoliceBy;

  // Options loaded from backend
  List<String> _natureOfIncidentOptions = [];
  List<String> _locationOptions = [];
  List<String> _notifyByOptions = [];
  List<String> _notifyParentByOptions = [];
  List<String> _notifyMinistryByOptions = [];
  List<String> _notifySupervisorByOptions = [];
  List<String> _notifyCasByOptions = [];
  List<String> _notifyPoliceByOptions = [];

  // Staff
  List<StaffClassModel> _staffList = [];
  final Set<String> _selectedStaffIds =
      {}; // Multi-select for staff (using contactId)

  // Class ID for fetching staff
  String? _classId;

  bool _isLoadingOptions = true;
  bool _isLoadingStaff = true;
  bool _isSubmitting = false;

  final ActivityIncidentApi _api = GetIt.instance<ActivityIncidentApi>();
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
        _api.getNatureOfIncidentOptions(),
        _api.getLocationOptions(),
        _api.getNotifyByOptions(),
        _api.getNotifyParentByOptions(),
        _api.getNotifyMinistryByOptions(),
        _api.getNotifySupervisorByOptions(),
        _api.getNotifyCasByOptions(),
        _api.getNotifyPoliceByOptions(),
      ]);

      if (mounted) {
        setState(() {
          _natureOfIncidentOptions = results[0];
          _locationOptions = results[1];
          _notifyByOptions = results[2];
          _notifyParentByOptions = results[3];
          _notifyMinistryByOptions = results[4];
          _notifySupervisorByOptions = results[5];
          _notifyCasByOptions = results[6];
          _notifyPoliceByOptions = results[7];
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

      // Remove duplicates based on contact_id (a staff might be in multiple classes)
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
      // STEP B: Create incident details linked to activity
      await _api.createIncidentDetails(
        activityId: activityId,
        childId: widget.selectedChild.id!,
        dateTime: dateTimeUtc,
        natureOfInjuryTexts: _selectedNatureOfIncident,
        locationTexts: _selectedLocation,
        staffIds: _selectedStaffIds.toList(),
        staffId: staffId,
        notifyByText: _selectedNotifyBy,
        notifyParentDateTime: _notifyParentDateTime?.toUtc().toIso8601String(),
        notifyParentByText: _notifyParentBy,
        notifyMinistryDateTime: _notifyMinistryDateTime
            ?.toUtc()
            .toIso8601String(),
        notifyMinistryByText: _notifyMinistryBy,
        notifySupervisorDateTime: _notifySupervisorDateTime
            ?.toUtc()
            .toIso8601String(),
        notifySupervisorByText: _notifySupervisorBy,
        notifyCasDateTime: _notifyCasDateTime?.toUtc().toIso8601String(),
        notifyCasByText: _notifyCasBy,
        notifyPoliceDateTime: _notifyPoliceDateTime?.toUtc().toIso8601String(),
        notifyPoliceByText: _notifyPoliceBy,
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
        CustomSnackbar.showSuccess(context, 'Incident activity created successfully');
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
            const HeaderCheckOutWidget(isIcon: false, title: 'Incident Activity'),
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
                    // Nature of Incident (Multi-select)
                    MultiSelectTypeSelectorWidget(
                      title: 'Nature of Incident',
                      options: _natureOfIncidentOptions,
                      selectedValues: _selectedNatureOfIncident,
                      onChanged: (values) {
                        setState(() {
                          _selectedNatureOfIncident = values;
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

                    // Persons Notified Section
                    const Text(
                      'Persons Notified',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Parent / Guardian
                    _PersonNotifiedRow(
                      label: 'Parent / Guardian',
                      dateTime: _notifyParentDateTime,
                      notifyByOptions: _notifyParentByOptions,
                      selectedNotifyBy: _notifyParentBy,
                      onDateSelected: (dateTime) {
                        setState(() {
                          _notifyParentDateTime = dateTime;
                        });
                      },
                      onNotifyByChanged: (value) {
                        setState(() {
                          _notifyParentBy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ministry Of Education
                    _PersonNotifiedRow(
                      label: 'Ministry Of Education',
                      dateTime: _notifyMinistryDateTime,
                      notifyByOptions: _notifyMinistryByOptions,
                      selectedNotifyBy: _notifyMinistryBy,
                      onDateSelected: (dateTime) {
                        setState(() {
                          _notifyMinistryDateTime = dateTime;
                        });
                      },
                      onNotifyByChanged: (value) {
                        setState(() {
                          _notifyMinistryBy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Supervisor/Director
                    _PersonNotifiedRow(
                      label: 'Supervisor/Director',
                      dateTime: _notifySupervisorDateTime,
                      notifyByOptions: _notifySupervisorByOptions,
                      selectedNotifyBy: _notifySupervisorBy,
                      onDateSelected: (dateTime) {
                        setState(() {
                          _notifySupervisorDateTime = dateTime;
                        });
                      },
                      onNotifyByChanged: (value) {
                        setState(() {
                          _notifySupervisorBy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // CAS
                    _PersonNotifiedRow(
                      label: 'CAS',
                      dateTime: _notifyCasDateTime,
                      notifyByOptions: _notifyCasByOptions,
                      selectedNotifyBy: _notifyCasBy,
                      onDateSelected: (dateTime) {
                        setState(() {
                          _notifyCasDateTime = dateTime;
                        });
                      },
                      onNotifyByChanged: (value) {
                        setState(() {
                          _notifyCasBy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Police
                    _PersonNotifiedRow(
                      label: 'Police',
                      dateTime: _notifyPoliceDateTime,
                      notifyByOptions: _notifyPoliceByOptions,
                      selectedNotifyBy: _notifyPoliceBy,
                      onDateSelected: (dateTime) {
                        setState(() {
                          _notifyPoliceDateTime = dateTime;
                        });
                      },
                      onNotifyByChanged: (value) {
                        setState(() {
                          _notifyPoliceBy = value;
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

// Person Notified Row Widget
class _PersonNotifiedRow extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final List<String> notifyByOptions;
  final String? selectedNotifyBy;
  final Function(DateTime) onDateSelected;
  final Function(String?) onNotifyByChanged;

  const _PersonNotifiedRow({
    required this.label,
    required this.dateTime,
    required this.notifyByOptions,
    required this.selectedNotifyBy,
    required this.onDateSelected,
    required this.onNotifyByChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            // Date Time Display
            if (dateTime != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  DateFormat('MMM d, yyyy h:mm a').format(dateTime!),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            // Calendar Icon
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                DateTime? selectedDateTime = dateTime ?? now;
                final picked = await showModalBottomSheet<DateTime>(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setState) => SizedBox(
                      height: 300,
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
                                onPressed: () {
                                  Navigator.pop(context, selectedDateTime);
                                },
                                child: const Text('Done'),
                              ),
                            ],
                          ),
                          Expanded(
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.dateAndTime,
                              initialDateTime: dateTime ?? now,
                              minimumDate: DateTime(now.year - 1),
                              maximumDate: now,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  selectedDateTime = newDateTime;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (picked != null) {
                  onDateSelected(picked);
                }
              },
              child: Assets.images.calendarDate.svg(width: 24, height: 24),
            ),
            const SizedBox(width: 8),
            // Dropdown Icon for notify_by
            GestureDetector(
              onTap: notifyByOptions.isEmpty
                  ? null
                  : () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Select Notification Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...notifyByOptions.map(
                                (option) => ListTile(
                                  title: Text(option),
                                  trailing: selectedNotifyBy == option
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.purple,
                                        )
                                      : null,
                                  onTap: () {
                                    onNotifyByChanged(option);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              if (selectedNotifyBy != null)
                                ListTile(
                                  title: const Text('Clear selection'),
                                  onTap: () {
                                    onNotifyByChanged(null);
                                    Navigator.pop(context);
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedNotifyBy != null
                        ? Colors.purple
                        : AppColors.textTertiary,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: selectedNotifyBy != null
                      ? Colors.purple
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
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
