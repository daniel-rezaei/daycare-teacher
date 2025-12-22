import 'dart:io';
import 'package:flutter/cupertino.dart';
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
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:get_it/get_it.dart';

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
  bool _checkoutSubmitted = false; // برای جلوگیری از pop چندباره

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
      // Step 1: Upload images if any
      List<String> uploadedFileIds = [];
      if (_images.isNotEmpty) {
        debugPrint('[CHECKOUT_DEBUG] Starting image upload, count: ${_images.length}');
        final fileUploadUsecase = GetIt.instance<FileUploadUsecase>();
        
        for (int i = 0; i < _images.length; i++) {
          final imageFile = _images[i];
          debugPrint('[CHECKOUT_DEBUG] Uploading image ${i + 1}/${_images.length}: ${imageFile.path}');
          
          final uploadResult = await fileUploadUsecase.uploadFile(
            filePath: imageFile.path,
          );
          
          if (uploadResult is DataSuccess && uploadResult.data != null) {
            uploadedFileIds.add(uploadResult.data!);
            debugPrint('[CHECKOUT_DEBUG] Image ${i + 1} uploaded successfully, fileId: ${uploadResult.data}');
          } else {
            debugPrint('[CHECKOUT_DEBUG] Failed to upload image ${i + 1}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطا در آپلود تصویر ${i + 1}')),
              );
            }
            setState(() {
              _isSubmitting = false;
            });
            return;
          }
        }
        debugPrint('[CHECKOUT_DEBUG] All images uploaded successfully, total: ${uploadedFileIds.length}');
      } else {
        debugPrint('[CHECKOUT_DEBUG] No images to upload');
      }

      // Step 2: Update Attendance_Child
      debugPrint('[CHECKOUT_STEP2] ========== Step 2: Preparing Check Out Data ==========');
      debugPrint('[CHECKOUT_STEP2] Calling DateUtils.getCurrentDateTimeForCheckOut()...');
      final checkOutAt = DateUtils.getCurrentDateTimeForCheckOut();
      debugPrint('[CHECKOUT_STEP2] checkOutAt generated: "$checkOutAt"');
      debugPrint('[CHECKOUT_STEP2] checkOutAt type: ${checkOutAt.runtimeType}');
      debugPrint('[CHECKOUT_STEP2] checkOutAt length: ${checkOutAt.length}');
      debugPrint('[CHECKOUT_STEP2] checkOutAt isEmpty: ${checkOutAt.isEmpty}');
      
      final note = _noteController.text.isNotEmpty ? _noteController.text : null;
      // فقط اولین file_id را به صورت string ارسال می‌کنیم
      final photoFileId = uploadedFileIds.isNotEmpty ? uploadedFileIds.first : null;
      
      debugPrint('[CHECKOUT_STEP2] ========== All Check Out Data Prepared ==========');
      debugPrint('[CHECKOUT_STEP2] - attendanceId: ${widget.attendanceId}');
      debugPrint('[CHECKOUT_STEP2] - checkOutAt: "$checkOutAt"');
      debugPrint('[CHECKOUT_STEP2] - checkoutPickupContactId: $_selectedContactId');
      debugPrint('[CHECKOUT_STEP2] - checkoutPickupContactType: $_selectedRelationToChild');
      debugPrint('[CHECKOUT_STEP2] - notes: $note');
      debugPrint('[CHECKOUT_STEP2] - photo fileId (first): $photoFileId');
      debugPrint('[CHECKOUT_STEP2] - total uploaded files: ${uploadedFileIds.length}');
      
      debugPrint('[CHECKOUT_STEP2] ========== Dispatching UpdateAttendanceEvent ==========');
      
      // علامت‌گذاری که checkout در حال ارسال است
      setState(() {
        _checkoutSubmitted = true;
      });
      
      context.read<AttendanceBloc>().add(
            UpdateAttendanceEvent(
              attendanceId: widget.attendanceId,
              checkOutAt: checkOutAt,
              notes: note,
              checkoutPickupContactId: _selectedContactId!,
              checkoutPickupContactType: _selectedRelationToChild,
              photo: photoFileId,
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
        // بررسی اینکه آیا attendance مربوط به این widget به‌روز شده است
        if (state is GetAttendanceByClassIdSuccess) {
          // پیدا کردن attendance مربوط به این attendanceId
          final matchingAttendances = state.attendanceList.where(
            (att) => att.id == widget.attendanceId,
          ).toList();
          
          if (matchingAttendances.isEmpty) {
            debugPrint('❌ Attendance not found for attendanceId: ${widget.attendanceId}');
            return;
          }
          
          final updatedAttendance = matchingAttendances.first;
          
          // اگر این attendance به‌روز شده و checkOutAt دارد، یعنی checkout موفق بوده
          // فقط اگر در حال submit هستیم و attendance مربوط به این widget است
          if (_isSubmitting &&
              _checkoutSubmitted &&
              updatedAttendance.id == widget.attendanceId && 
              updatedAttendance.checkOutAt != null && 
              updatedAttendance.checkOutAt!.isNotEmpty) {
            debugPrint('[CHECKOUT_DEBUG] Attendance updated with checkOutAt - Popping back to previous page');
            setState(() {
              _isSubmitting = false;
              _checkoutSubmitted = false; // reset flag
            });
            if (mounted) {
              // به جای رفتن به HomePage، به صفحه قبلی برگرد
              Navigator.of(context).pop();
            }
          }
        } else if (state is UpdateAttendanceFailure) {
          setState(() {
            _isSubmitting = false;
            _checkoutSubmitted = false;
          });
          // نمایش خطا به کاربر
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
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
                                  child: CupertinoActivityIndicator(),
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
                              child: CupertinoActivityIndicator(
                                radius: 10,
                                color: Colors.white,
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
