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
import 'package:teacher_app/features/activity/data/data_source/activity_incident_api.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/activity/widgets/multi_select_type_selector_widget.dart';
import 'package:teacher_app/features/auth/data/models/staff_class_model/staff_class_model.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/home/data/data_source/home_api.dart';

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
  List<String> _selectedNatureOfInjury = [];
  List<String> _selectedLocation = [];
  String? _selectedNotifyBy;

  // Options loaded from backend
  List<String> _natureOfInjuryOptions = [];
  List<String> _locationOptions = [];
  List<String> _notifyByOptions = [];

  // Staff
  List<StaffClassModel> _staffList = [];
  Set<String> _selectedStaffIds = {}; // Multi-select for staff

  // Class ID for fetching staff
  String? _classId;

  bool _isLoadingOptions = true;
  bool _isLoadingStaff = true;

  final ActivityIncidentApi _api = GetIt.instance<ActivityIncidentApi>();
  final HomeApi _homeApi = GetIt.instance<HomeApi>();

  @override
  void initState() {
    super.initState();
    debugPrint(
      '[INCIDENT_ACTIVITY] ========== Opening IncidentActivityBottomSheet ==========',
    );
    debugPrint(
      '[INCIDENT_ACTIVITY] Selected child: ${widget.selectedChild.id}',
    );
    debugPrint('[INCIDENT_ACTIVITY] DateTime: ${widget.dateTime}');

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
        debugPrint('[INCIDENT_ACTIVITY] ClassId loaded: $_classId');
      } else {
        debugPrint(
          '[INCIDENT_ACTIVITY] ⚠️ ClassId not found in SharedPreferences',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[INCIDENT_ACTIVITY] Error loading classId: $e');
      debugPrint('[INCIDENT_ACTIVITY] StackTrace: $stackTrace');
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
        _api.getLocationOptions(),
        _api.getNotifyByOptions(),
      ]);

      if (mounted) {
        setState(() {
          _natureOfInjuryOptions = results[0];
          _locationOptions = results[1];
          _notifyByOptions = results[2];
          _isLoadingOptions = false;
        });
        debugPrint(
          '[INCIDENT_ACTIVITY] Options loaded: Nature=${_natureOfInjuryOptions.length}, Location=${_locationOptions.length}, NotifyBy=${_notifyByOptions.length}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[INCIDENT_ACTIVITY] Error loading options: $e');
      debugPrint('[INCIDENT_ACTIVITY] StackTrace: $stackTrace');
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
      debugPrint('[INCIDENT_ACTIVITY] Loading all staff from all classes...');
      final response = await _homeApi.getAllStaff();
      final List<dynamic> data = response.data['data'] as List<dynamic>;

      // Parse all staff
      final allStaff = data
          .map((e) => StaffClassModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Remove duplicates based on staff_id (a staff might be in multiple classes)
      final Map<String, StaffClassModel> uniqueStaffMap = {};
      for (final staff in allStaff) {
        if (staff.staffId != null && staff.staffId!.isNotEmpty) {
          if (!uniqueStaffMap.containsKey(staff.staffId)) {
            uniqueStaffMap[staff.staffId!] = staff;
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
          '[INCIDENT_ACTIVITY] All staff loaded: ${_staffList.length} unique members (from ${allStaff.length} total records)',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[INCIDENT_ACTIVITY] Error loading staff: $e');
      debugPrint('[INCIDENT_ACTIVITY] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingStaff = false;
        });
      }
    }
  }

  void _onImagesChanged(List<File> images) {
    debugPrint('[INCIDENT_ACTIVITY] Images changed: ${images.length}');
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  void _toggleStaffSelection(String staffId) {
    setState(() {
      if (_selectedStaffIds.contains(staffId)) {
        _selectedStaffIds.remove(staffId);
      } else {
        _selectedStaffIds.add(staffId);
      }
    });
    debugPrint('[INCIDENT_ACTIVITY] Selected staff IDs: $_selectedStaffIds');
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
            const HeaderCheckOut(isIcon: false, title: 'Incident Activity'),
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
                            final staffId = staff.staffId ?? '';
                            final isSelected = _selectedStaffIds.contains(
                              staffId,
                            );

                            return GestureDetector(
                              onTap: () => _toggleStaffSelection(staffId),
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

                    // Add Button (disabled for now)
                    ButtonWidget(
                      isEnabled: false,
                      onTap: () {
                        // Not implemented yet
                      },
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
