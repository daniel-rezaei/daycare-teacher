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
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/core/widgets/staff_avatar_widget.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_accident_api.dart';
import 'package:teacher_app/features/activity/widgets/meal_type_selector_widget.dart';
import 'package:teacher_app/features/auth/data/models/staff_class_model/staff_class_model.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/home/data/data_source/home_api.dart';

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

  // Field selections
  String? _selectedNatureOfInjury;
  String? _selectedInjuredBodyPart;
  String? _selectedLocation;
  String? _selectedFirstAidProvided;
  String? _selectedChildReaction;
  String? _selectedNotifyBy;
  String? _selectedDateNotified;

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
  Set<String> _selectedStaffIds = {}; // Multi-select for staff

  // Class ID for fetching staff
  String? _classId;

  bool _isLoadingOptions = true;
  bool _isLoadingStaff = true;
  bool _medicalFollowUpRequired = false;
  bool _incidentReportedToAuthority = false;
  bool _parentNotified = false;

  final ActivityAccidentApi _api = GetIt.instance<ActivityAccidentApi>();
  final HomeApi _homeApi = GetIt.instance<HomeApi>();

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

  void _toggleStaffSelection(String staffId) {
    setState(() {
      if (_selectedStaffIds.contains(staffId)) {
        _selectedStaffIds.remove(staffId);
      } else {
        _selectedStaffIds.add(staffId);
      }
    });
    debugPrint('[ACCIDENT_ACTIVITY] Selected staff IDs: $_selectedStaffIds');
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

                  // Selected Child Avatar
                  ChildAvatarWidget(
                    photoId: widget.selectedChild.photo,
                    size: 48,
                  ),
                  const SizedBox(height: 24),

                  // Loading indicator
                  if (_isLoadingOptions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // Nature of Injury
                    MealTypeSelectorWidget(
                      title: 'Nature of Injury',
                      options: _natureOfInjuryOptions,
                      selectedValue: _selectedNatureOfInjury,
                      onChanged: (value) {
                        setState(() {
                          _selectedNatureOfInjury = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Injured Body Part
                    MealTypeSelectorWidget(
                      title: 'Injured Body Part',
                      options: _injuredBodyPartOptions,
                      selectedValue: _selectedInjuredBodyPart,
                      onChanged: (value) {
                        setState(() {
                          _selectedInjuredBodyPart = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Location
                    MealTypeSelectorWidget(
                      title: 'Location',
                      options: _locationOptions,
                      selectedValue: _selectedLocation,
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // First Aid Provided
                    MealTypeSelectorWidget(
                      title: 'First Aid Provided',
                      options: _firstAidProvidedOptions,
                      selectedValue: _selectedFirstAidProvided,
                      onChanged: (value) {
                        setState(() {
                          _selectedFirstAidProvided = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Child's Reaction
                    MealTypeSelectorWidget(
                      title: 'Child\'s Reaction',
                      options: _childReactionOptions,
                      selectedValue: _selectedChildReaction,
                      onChanged: (value) {
                        setState(() {
                          _selectedChildReaction = value;
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

                    // Date Notified
                    if (_dateNotifiedOptions.isNotEmpty)
                      MealTypeSelectorWidget(
                        title: 'Date Notified',
                        options: _dateNotifiedOptions,
                        selectedValue: _selectedDateNotified,
                        onChanged: (value) {
                          setState(() {
                            _selectedDateNotified = value;
                          });
                        },
                      ),
                    if (_dateNotifiedOptions.isNotEmpty)
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

                    // Add Button (DISABLED - UI only, no functionality)
                    ButtonWidget(
                      isEnabled: false, // Disabled as per requirements
                      onTap: () {
                        // No implementation - button is disabled
                        debugPrint(
                          '[ACCIDENT_ACTIVITY] Add button pressed (disabled)',
                        );
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
