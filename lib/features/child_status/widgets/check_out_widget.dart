import 'dart:io';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/contact_utils.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/core/utils/photo_utils.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/lifecycle_event_handler.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';
import 'package:teacher_app/features/pickup_authorization/presentation/bloc/pickup_authorization_bloc.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CheckOutWidget extends StatefulWidget {
  final String childId;
  final String childName;
  final String attendanceId;
  final String classId;

  const CheckOutWidget({
    super.key,
    required this.childId,
    required this.childName,
    required this.attendanceId,
    required this.classId,
  });

  @override
  State<CheckOutWidget> createState() => _CheckOutWidgetState();
}

class _CheckOutWidgetState extends State<CheckOutWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _noteController = TextEditingController();
  final List<File> _images = [];
  String? _selectedContactId;
  String? _selectedRelationToChild; // برای checkoutPickupContactType
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // دریافت PickupAuthorization
    context.read<PickupAuthorizationBloc>().add(
          GetPickupAuthorizationByChildIdEvent(childId: widget.childId),
        );

    // دریافت Contacts
    context.read<ChildBloc>().add(const GetAllContactsEvent());

    // وقتی کیبورد باز/بسته شود، اسکرول اتوماتیک انجام می شود
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(
          onMetricsChanged: () {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            });
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Removed duplicate methods - using utilities instead

  Future<void> _handleSubmit() async {
    debugPrint('[CHECKOUT_DEBUG] Submit button clicked');
    
    if (_isSubmitting) {
      debugPrint('[CHECKOUT_DEBUG] Already submitting, returning');
      return;
    }

    if (_selectedContactId == null || _selectedContactId!.isEmpty) {
      debugPrint('[CHECKOUT_DEBUG] No contact selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً شخصی که بچه را برمی‌دارد انتخاب کنید')),
      );
      return;
    }

    debugPrint('[CHECKOUT_DEBUG] Starting submit process');
    debugPrint('[CHECKOUT_DEBUG] Selected contactId: $_selectedContactId');
    debugPrint('[CHECKOUT_DEBUG] Widget childId (Child.id): ${widget.childId}');
    debugPrint('[CHECKOUT_DEBUG] Note: ${_noteController.text}');
    debugPrint('[CHECKOUT_DEBUG] Images count: ${_images.length}');

    setState(() {
      _isSubmitting = true;
    });

    try {
      // widget.childId در واقع Child.id است (نه contactId)
      // چون در child_status.dart، child.id به CheckOutWidget پاس داده می‌شود
      final actualChildId = widget.childId;
      
      debugPrint('[CHECKOUT_DEBUG] Using widget.childId as Child.id: $actualChildId');

      if (actualChildId.isEmpty) {
        debugPrint('[CHECKOUT_DEBUG] actualChildId is empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطا در پیدا کردن اطلاعات بچه')),
          );
        }
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // به‌روزرسانی Attendance_Child (Check-Out)
      // ❌ هیچ PickupAuthorization جدیدی ساخته نمی‌شود
      // ✅ فقط Attendance_Child به‌روزرسانی می‌شود
      final checkOutAt = DateUtils.getCurrentDateTime();
      final note = _noteController.text.isNotEmpty ? _noteController.text : null;
      
      debugPrint('[CHECKOUT_DEBUG] Dispatching UpdateAttendanceEvent');
      debugPrint('[CHECKOUT_DEBUG] - attendanceId: ${widget.attendanceId}');
      debugPrint('[CHECKOUT_DEBUG] - classId: ${widget.classId}');
      debugPrint('[CHECKOUT_DEBUG] - checkOutAt: $checkOutAt');
      debugPrint('[CHECKOUT_DEBUG] - checkoutPickupContactId: $_selectedContactId');
      debugPrint('[CHECKOUT_DEBUG] - checkoutPickupContactType: $_selectedRelationToChild');
      debugPrint('[CHECKOUT_DEBUG] - notes: $note');
      
      context.read<AttendanceBloc>().add(
            UpdateAttendanceEvent(
              attendanceId: widget.attendanceId,
              classId: widget.classId,
              checkOutAt: checkOutAt,
              notes: note,
              checkoutPickupContactId: _selectedContactId!,
              checkoutPickupContactType: _selectedRelationToChild,
              // TODO: photo upload - فعلاً null می‌گذاریم
              photo: null,
            ),
          );
    } catch (e, stackTrace) {
      debugPrint('[CHECKOUT_DEBUG] Exception in _handleSubmit: $e');
      debugPrint('[CHECKOUT_DEBUG] StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is UpdateAttendanceSuccess) {
          // بعد از موفقیت Check-Out، به صفحه قبلی برمی‌گردیم
          debugPrint('[CHECKOUT_DEBUG] UpdateAttendanceSuccess - Closing modal');
          Navigator.pop(context);
        } else if (state is UpdateAttendanceFailure) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: ModalBottomSheetWrapper(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const HeaderCheckOut(isIcon: true, title: 'Check Out'),
              const Divider(color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Who is picking up ${widget.childName}?',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<PickupAuthorizationBloc, PickupAuthorizationState>(
                      builder: (context, pickupState) {
                        return BlocBuilder<ChildBloc, ChildState>(
                          builder: (context, childState) {
                            if (pickupState is GetPickupAuthorizationByChildIdLoading ||
                                childState.isLoadingContacts) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            List<PickupAuthorizationEntity> pickupList = [];
                            if (pickupState is GetPickupAuthorizationByChildIdSuccess) {
                              pickupList = pickupState.pickupAuthorizationList;
                            }

                            List<ContactEntity> contacts = [];
                            if (childState.contacts != null) {
                              contacts = childState.contacts!;
                            }

                            if (pickupList.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text('هیچ مجوزی برای این بچه یافت نشد'),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: pickupList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final pickup = pickupList[index];
                                final contact = ContactUtils.getContactById(
                                  pickup.authorizedContactId,
                                  contacts,
                                );
                                final isSelected = _selectedContactId == pickup.authorizedContactId;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedContactId = pickup.authorizedContactId;
                                      _selectedRelationToChild = pickup.relationToChild;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryLight
                                          : AppColors.backgroundLight,
                                      border: Border.all(
                                        color: AppColors.backgroundBorder,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.backgroundBorder,
                                              width: 1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child: contact?.photo != null &&
                                                    contact!.photo!.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: PhotoUtils.getPhotoUrl(contact.photo),
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                    httpHeaders: PhotoUtils.getImageHeaders(),
                                                    errorWidget: (context, url, error) =>
                                                        Assets.images.image.image(
                                                      width: 48,
                                                      height: 48,
                                                    ),
                                                  )
                                                : Assets.images.image.image(
                                                    width: 48,
                                                    height: 48,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ContactUtils.getContactName(contact),
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pickup.relationToChild ?? AppConstants.unknownContact,
                                                style: TextStyle(
                                                  color: AppColors.textTertiary
                                                      .withValues(alpha: .8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Assets.images.checkbox.svg()
                                        else
                                          Assets.images.checkbox2.svg(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    NoteWidget(
                      title: 'Note',
                      hintText: 'Placeholder',
                      controller: _noteController,
                    ),
                    const SizedBox(height: 20),
                    AttachPhotoWidget(
                      images: _images,
                      onImagesChanged: (images) {
                        setState(() {
                          _images.clear();
                          _images.addAll(images);
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ButtonWidget(
                      onTap: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit',
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
      ),
    );
  }
}
