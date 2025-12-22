import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/widgets/lifecycle_event_handler.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/child_status/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/features/child_status/services/local_absent_storage_service.dart';
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:get_it/get_it.dart';
import 'package:teacher_app/core/utils/date_utils.dart';

class AddNoteWidget extends StatefulWidget {
  final String childId;
  final String classId;
  final String? childImage; // photoId
  final String childFirstName;
  final String childLastName;
  final ChildAttendanceStatus childAttendanceStatus;
  final String? attendanceId; // اگر وجود داشته باشد

  const AddNoteWidget({
    super.key,
    required this.childId,
    required this.classId,
    required this.childFirstName,
    required this.childLastName,
    this.childImage,
    required this.childAttendanceStatus,
    this.attendanceId,
  });

  String get childName => '$childFirstName $childLastName'.trim();

  @override
  State<AddNoteWidget> createState() => _AddNoteWidgetState();
}

class _AddNoteWidgetState extends State<AddNoteWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _noteController = TextEditingController();
  final List<File> _images = [];
  bool _isSubmitting = false;
  String? _staffId;
  String? _currentAttendanceId; // attendanceId فعلی (ممکن است بعد از Check In تغییر کند)

  // برای مدیریت مراحل submit
  bool _needsCheckIn = false;
  bool _isCheckingIn = false;
  bool _noteSubmitted = false; // برای جلوگیری از pop چندباره

  @override
  void initState() {
    super.initState();
    debugPrint('[NOTE_INIT] ========== AddNoteWidget INIT ==========');
    debugPrint('[NOTE_INIT] childId: ${widget.childId}');
    debugPrint('[NOTE_INIT] classId: ${widget.classId}');
    debugPrint('[NOTE_INIT] childName: ${widget.childName}');
    debugPrint('[NOTE_INIT] childAttendanceStatus: ${widget.childAttendanceStatus}');
    debugPrint('[NOTE_INIT] attendanceId: ${widget.attendanceId}');

    _currentAttendanceId = widget.attendanceId;
    _needsCheckIn = widget.childAttendanceStatus == ChildAttendanceStatus.notArrived ||
        widget.attendanceId == null;

    debugPrint('[NOTE_INIT] _needsCheckIn: $_needsCheckIn');
    debugPrint('[NOTE_INIT] _currentAttendanceId: $_currentAttendanceId');

    _loadStaffId();

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

  Future<void> _loadStaffId() async {
    debugPrint('[NOTE_LOAD] _loadStaffId called');
    final prefs = await SharedPreferences.getInstance();
    final staffId = prefs.getString(AppConstants.staffIdKey);
    debugPrint('[NOTE_LOAD] staffId from prefs: $staffId');
    if (mounted) {
      setState(() {
        _staffId = staffId;
      });
      debugPrint('[NOTE_LOAD] _staffId set to: $_staffId');
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Step 1: Check In خودکار (در صورت نیاز)
  Future<bool> _performCheckIn() async {
    debugPrint('[NOTE_CHECKIN] ========== Step 1: Check In ==========');
    
    if (!_needsCheckIn) {
      debugPrint('[NOTE_CHECKIN] Check In not needed, skipping');
      return true;
    }

    if (widget.classId.isEmpty || _staffId == null) {
      debugPrint('[NOTE_CHECKIN] Missing classId or staffId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا: اطلاعات لازم برای Check In یافت نشد')),
        );
      }
      return false;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      // استفاده از همان منطق Check In که در صفحه لیست کودکان استفاده می‌شود
      // حذف از لیست غایبین محلی (اگر وجود داشته باشد)
      await LocalAbsentStorageService.removeAbsent(widget.classId, widget.childId);

      final checkInAt = DateUtils.getCurrentDateTime();
      debugPrint('[NOTE_CHECKIN] Dispatching CreateAttendanceEvent');
      debugPrint('[NOTE_CHECKIN] - childId: ${widget.childId}');
      debugPrint('[NOTE_CHECKIN] - classId: ${widget.classId}');
      debugPrint('[NOTE_CHECKIN] - checkInAt: $checkInAt');
      debugPrint('[NOTE_CHECKIN] - staffId: $_staffId');

      // منتظر می‌مانیم تا CreateAttendanceSuccess بیاید
      // این در listener مدیریت می‌شود
      context.read<AttendanceBloc>().add(
            CreateAttendanceEvent(
              childId: widget.childId,
              classId: widget.classId,
              checkInAt: checkInAt,
              staffId: _staffId,
            ),
          );

      // منتظر می‌مانیم تا state به‌روزرسانی شود
      // این در listener مدیریت می‌شود و _currentAttendanceId تنظیم می‌شود
      return true;
    } catch (e, stackTrace) {
      debugPrint('[NOTE_CHECKIN] Exception: $e');
      debugPrint('[NOTE_CHECKIN] StackTrace: $stackTrace');
      setState(() {
        _isCheckingIn = false;
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در Check In: $e')),
        );
      }
      return false;
    }
  }

  /// Step 2: آپلود تصاویر
  Future<List<String>> _uploadImages() async {
    debugPrint('[NOTE_UPLOAD] ========== Step 2: Upload Images ==========');
    debugPrint('[NOTE_UPLOAD] Images count: ${_images.length}');

    if (_images.isEmpty) {
      return [];
    }

    setState(() {
    });

    List<String> uploadedFileIds = [];
    final fileUploadUsecase = GetIt.instance<FileUploadUsecase>();

    try {
      for (int i = 0; i < _images.length; i++) {
        final imageFile = _images[i];
        debugPrint('[NOTE_UPLOAD] Uploading image ${i + 1}/${_images.length}: ${imageFile.path}');

        final uploadResult = await fileUploadUsecase.uploadFile(
          filePath: imageFile.path,
        );

        if (uploadResult is DataSuccess && uploadResult.data != null) {
          uploadedFileIds.add(uploadResult.data!);
          debugPrint('[NOTE_UPLOAD] Image ${i + 1} uploaded successfully, fileId: ${uploadResult.data}');
        } else {
          debugPrint('[NOTE_UPLOAD] Failed to upload image ${i + 1}');
          setState(() {
            _isSubmitting = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطا در آپلود تصویر ${i + 1}')),
            );
          }
          throw Exception('Failed to upload image ${i + 1}');
        }
      }

      debugPrint('[NOTE_UPLOAD] All images uploaded successfully, total: ${uploadedFileIds.length}');
      setState(() {
      });
      return uploadedFileIds;
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      rethrow;
    }
  }

  /// Step 3: ارسال Note به API
  Future<void> _submitNote(List<String> imageCodes) async {
    debugPrint('[NOTE_SUBMIT] ========== Step 3: Submit Note ==========');
    debugPrint('[NOTE_SUBMIT] attendanceId: $_currentAttendanceId');
    debugPrint('[NOTE_SUBMIT] note: ${_noteController.text}');
    debugPrint('[NOTE_SUBMIT] imageCodes count: ${imageCodes.length}');

    if (_currentAttendanceId == null) {
      debugPrint('[NOTE_SUBMIT] attendanceId is null, cannot submit');
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا: attendanceId یافت نشد')),
        );
      }
      return;
    }

    setState(() {
    });

    try {
      final note = _noteController.text.isNotEmpty ? _noteController.text : null;
      // فقط اولین file_id را به صورت string ارسال می‌کنیم
      final photoFileId = imageCodes.isNotEmpty ? imageCodes.first : null;

      // دریافت attendance موجود برای گرفتن checkOutAt
      // اگر بچه تازه check-in شده (از طریق Add Note)، نباید checkOutAt را ارسال کنیم
      final attendanceState = context.read<AttendanceBloc>().state;
      String? checkOutAt;
      if (attendanceState is GetAttendanceByClassIdSuccess) {
        // پیدا کردن attendance مربوط به این attendanceId
        final matchingAttendances = attendanceState.attendanceList.where(
          (att) => att.id == _currentAttendanceId,
        ).toList();
        
        if (matchingAttendances.isEmpty) {
          debugPrint('❌ Child not found for attendanceId: $_currentAttendanceId');
          setState(() {
            _isSubmitting = false;
            _noteSubmitted = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خطا: attendance یافت نشد')),
            );
          }
          return;
        }
        
        final attendance = matchingAttendances.first;
        // فقط اگر checkOutAt از قبل وجود داشته باشد، آن را ارسال می‌کنیم
        // اگر null است یا خالی است، یعنی بچه هنوز check-out نشده و نباید checkOutAt را ارسال کنیم
        if (attendance.checkOutAt != null && attendance.checkOutAt!.isNotEmpty) {
          checkOutAt = attendance.checkOutAt;
        }
      }

      debugPrint('[NOTE_SUBMIT] Dispatching UpdateAttendanceEvent');
      debugPrint('[NOTE_SUBMIT] - attendanceId: $_currentAttendanceId');
      debugPrint('[NOTE_SUBMIT] - checkOutAt: $checkOutAt (null if not checked out)');
      debugPrint('[NOTE_SUBMIT] - notes: $note');
      debugPrint('[NOTE_SUBMIT] - photo: $photoFileId');

      // علامت‌گذاری که note در حال ارسال است
      setState(() {
        _noteSubmitted = true;
      });
      
      context.read<AttendanceBloc>().add(
            UpdateAttendanceEvent(
              attendanceId: _currentAttendanceId!,
              checkOutAt: checkOutAt ?? '', // اگر null باشد، string خالی می‌فرستیم
              notes: note,
              photo: photoFileId,
            ),
          );
    } catch (e, stackTrace) {
      debugPrint('[NOTE_SUBMIT] Exception: $e');
      debugPrint('[NOTE_SUBMIT] StackTrace: $stackTrace');
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ارسال Note: $e')),
        );
      }
    }
  }

  /// منطق کلی Submit
  Future<void> _handleSubmit() async {
    debugPrint('[NOTE_HANDLE] ========== _handleSubmit START ==========');
    debugPrint('[NOTE_HANDLE] _isSubmitting: $_isSubmitting');
    debugPrint('[NOTE_HANDLE] _needsCheckIn: $_needsCheckIn');
    debugPrint('[NOTE_HANDLE] _currentAttendanceId: $_currentAttendanceId');

    if (_isSubmitting) {
      debugPrint('[NOTE_HANDLE] Already submitting, returning');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Step 1: Check In (در صورت نیاز)
      if (_needsCheckIn) {
        final checkInSuccess = await _performCheckIn();
        if (!checkInSuccess) {
          debugPrint('[NOTE_HANDLE] Check In failed, stopping');
          return;
        }
        // منتظر می‌مانیم تا CreateAttendanceSuccess بیاید
        // این در listener مدیریت می‌شود و سپس ادامه می‌دهیم
        return;
      }

      // اگر Check In نیاز نبود، مستقیماً ادامه می‌دهیم
      await _continueAfterCheckIn();
    } catch (e, stackTrace) {
      debugPrint('[NOTE_HANDLE] Exception: $e');
      debugPrint('[NOTE_HANDLE] StackTrace: $stackTrace');
      setState(() {
        _isSubmitting = false;
        _isCheckingIn = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  /// ادامه فرآیند بعد از Check In
  Future<void> _continueAfterCheckIn() async {
    debugPrint('[NOTE_CONTINUE] ========== Continuing after Check In ==========');
    debugPrint('[NOTE_CONTINUE] _currentAttendanceId: $_currentAttendanceId');

    if (_currentAttendanceId == null) {
      debugPrint('[NOTE_CONTINUE] attendanceId is still null, cannot continue');
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا: attendanceId یافت نشد')),
        );
      }
      return;
    }

    try {
      // Step 2: Upload Images
      final imageCodes = await _uploadImages();

      // Step 3: Submit Note
      await _submitNote(imageCodes);
    } catch (e) {
      debugPrint('[NOTE_CONTINUE] Exception: $e');
      setState(() {
        _isSubmitting = false;
      });
      rethrow;
    }
  }

  /// تعیین متن دکمه
  String get _buttonText {
    if (_needsCheckIn) {
      return 'Save & Check In';
    }
    return 'Save';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        debugPrint('[NOTE_LISTENER] State changed: ${state.runtimeType}');

        // Handle GetAttendanceByClassIdSuccess - بعد از Check In یا Update
        if (state is GetAttendanceByClassIdSuccess) {
          // اگر در حال Check In هستیم، پیدا کردن attendance جدید
          if (_isCheckingIn) {
            // پیدا کردن attendance جدید برای این child (که checkOutAt ندارد)
            final newAttendance = state.attendanceList.firstWhere(
              (att) => att.childId == widget.childId && 
                       att.checkOutAt == null,
              orElse: () => state.attendanceList.isNotEmpty ? state.attendanceList.last : state.attendanceList.firstWhere(
                (att) => att.childId == widget.childId,
                orElse: () => state.attendanceList.first,
              ),
            );
            
            if (newAttendance.id != null && newAttendance.id != _currentAttendanceId) {
              debugPrint('[NOTE_LISTENER] Check In successful, setting _currentAttendanceId');
              debugPrint('[NOTE_LISTENER] New attendance ID: ${newAttendance.id}');
              setState(() {
                _currentAttendanceId = newAttendance.id;
                _isCheckingIn = false;
                _needsCheckIn = false;
              });

              // حالا که Check In انجام شد، ادامه می‌دهیم
              debugPrint('[NOTE_LISTENER] Continuing with upload and submit...');
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && _currentAttendanceId != null) {
                  _continueAfterCheckIn();
                }
              });
            }
          } 
          // اگر در حال Update هستیم (نه Check In) و attendance به‌روز شده، به صفحه قبلی برگرد
          else if (!_isCheckingIn && _currentAttendanceId != null && _isSubmitting && _noteSubmitted) {
            final updatedAttendance = state.attendanceList.firstWhere(
              (att) => att.id == _currentAttendanceId,
              orElse: () => state.attendanceList.first,
            );
            
            // اگر attendance به‌روز شده (مثلاً note اضافه شده)، به صفحه قبلی برگرد
            if (updatedAttendance.id == _currentAttendanceId) {
              debugPrint('[NOTE_LISTENER] Attendance updated - Popping back to previous page');
              setState(() {
                _isSubmitting = false;
                _noteSubmitted = false; // reset flag
              });
              if (mounted) {
                // به جای رفتن به HomePage، به صفحه قبلی برگرد
                Navigator.of(context).pop();
              }
            }
          }
        } else if (state is CreateAttendanceFailure) {
          debugPrint('[NOTE_LISTENER] CreateAttendanceFailure: ${state.message}');
          setState(() {
            _isSubmitting = false;
            _isCheckingIn = false;
            _noteSubmitted = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        } else if (state is UpdateAttendanceFailure) {
          debugPrint('[NOTE_LISTENER] UpdateAttendanceFailure: ${state.message}');
          setState(() {
            _isSubmitting = false;
            _noteSubmitted = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
      },
      child: ModalBottomSheetWrapper(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const HeaderCheckOut(isIcon: false, title: 'Add Note'),
              const Divider(color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نمایش اطلاعات کودک
                    Row(
                      children: [
                        ChildAvatarWidget(
                          photoId: widget.childImage,
                          size: 48,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.childName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
                      isEnabled: !_isSubmitting,
                      onTap: _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CupertinoActivityIndicator(
                                radius: 10,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _buttonText,
                              style: const TextStyle(
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
