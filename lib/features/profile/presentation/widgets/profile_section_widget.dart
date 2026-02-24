import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/widgets/shimmer_placeholder.dart';
import 'package:teacher_app/features/auth/presentation/logout_widget.dart';
import 'package:teacher_app/features/auth/presentation/select_class_screen.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ProfileSectionWidget extends StatefulWidget {
  const ProfileSectionWidget({super.key});

  @override
  State<ProfileSectionWidget> createState() => _ProfileSectionWidgetState();
}

class _ProfileSectionWidgetState extends State<ProfileSectionWidget> {
  String? contactId;
  String? authMode;
  String? staffId;
  String? classId;

  @override
  void initState() {
    super.initState();
    _loadContactId();
  }

  Future<void> _loadContactId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedContactId = prefs.getString('contact_id');
    final savedAuthMode = prefs.getString('auth_mode');
    final savedStaffId = prefs.getString('staff_id');
    final savedClassId = prefs.getString('class_id');
    if (mounted && savedContactId != null && savedContactId.isNotEmpty) {
      setState(() {
        contactId = savedContactId;
        authMode = savedAuthMode;
        staffId = savedStaffId;
        classId = savedClassId;
      });
      // LoadContact از LoadHomeDataEvent در HomeScreen صدا زده می‌شود؛ درخواست تکراری نزن
      final homeState = context.read<HomeBloc>().state;
      if (homeState.contact == null && !homeState.isLoadingContact) {
        context.read<HomeBloc>().add(LoadContactEvent(savedContactId));
      }
    }
  }

  String? _getClassName() {
    if (classId == null) return null;
    final homeState = context.read<HomeBloc>().state;
    if (homeState.classRooms == null) return null;

    try {
      final classRoom = homeState.classRooms!.firstWhere(
        (room) => room.id == classId,
      );
      return classRoom.roomName;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) =>
          prev.contact != curr.contact ||
          prev.isLoadingContact != curr.isLoadingContact,
      builder: (context, state) {
        if (state.isLoadingContact) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                const ShimmerCircle(size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: ShimmerPlaceholder(
                    width: double.infinity,
                    height: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                _buildSwitchAccountIcon(),
              ],
            ),
          );
        }

        if (state.contact != null) {
          final contact = state.contact!;
          final fullName =
              '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
          final displayName = fullName.isNotEmpty ? fullName : 'User';

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                _buildProfileAvatar(contact.photo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff444349),
                    ),
                  ),
                ),
                _buildSwitchAccountIcon(),
              ],
            ),
          );
        }

        // Initial state or error - show placeholder
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              _buildPlaceholderAvatar(),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff444349),
                  ),
                ),
              ),
              _buildSwitchAccountIcon(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(String? photoId) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String? teacherName;
        String? teacherPhoto;
        String? className;

        if (state.contact != null) {
          final contact = state.contact!;
          teacherName = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'
              .trim();
          teacherPhoto = contact.photo;
        }

        className = _getClassName();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalInformationScreen(
                  teacherName: teacherName ?? '',
                  teacherPhoto: teacherPhoto,
                  className: className ?? '',
                  staffId: staffId ?? '',
                  contactId: contactId ?? '',
                ),
              ),
            );
          },
          child: photoId == null || photoId.isEmpty
              ? _buildPlaceholderAvatar()
              : _buildAvatarImage(photoId),
        );
      },
    );
  }

  Widget _buildAvatarImage(String photoId) {
    final imageUrl = 'http://51.79.53.56:8055/assets/$photoId';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        httpHeaders: const {
          'Authorization': 'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
        },
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingAvatar(),
        errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String? teacherName;
        String? teacherPhoto;
        String? className;

        if (state.contact != null) {
          final contact = state.contact!;
          teacherName = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'
              .trim();
          teacherPhoto = contact.photo;
        }

        className = _getClassName();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalInformationScreen(
                  teacherName: teacherName ?? '',
                  teacherPhoto: teacherPhoto,
                  className: className ?? '',
                  staffId: staffId ?? '',
                  contactId: contactId ?? '',
                ),
              ),
            );
          },
          child: const ShimmerCircle(size: 48),
        );
      },
    );
  }

  Widget _buildPlaceholderAvatar() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String? teacherName;
        String? teacherPhoto;
        String? className;

        if (state.contact != null) {
          final contact = state.contact!;
          teacherName = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'
              .trim();
          teacherPhoto = contact.photo;
        }

        className = _getClassName();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalInformationScreen(
                  teacherName: teacherName ?? '',
                  teacherPhoto: teacherPhoto,
                  className: className ?? '',
                  staffId: staffId ?? '',
                  contactId: contactId ?? '',
                ),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildSwitchAccountIcon() {
    return GestureDetector(
      onTap: () {
        if (authMode == 'individual') {
          // نمایش LogoutWidget به صورت bottom sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useSafeArea: true,
            builder: (_) => const LogoutWidget(),
          );
        } else if (authMode == 'shared') {
          // انتقال به SelectClassScreen
          _navigateToSelectClass();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Assets.images.switchAccount.svg(),
      ),
    );
  }

  void _navigateToSelectClass() async {
    // CRITICAL: Clear session context immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('class_id');
    await prefs.remove('contact_id');
    await prefs.remove('staff_id');
    await prefs.remove('selected_class');

    // Clear HomeBloc state by resetting to initial
    final homeBloc = context.read<HomeBloc>();
    // Note: HomeBloc state will be naturally cleared when navigating away

    final currentState = homeBloc.state;

    // CRITICAL: Use pushAndRemoveUntil to reset entire navigation stack
    // This makes returning to Home technically impossible
    if (currentState.classRooms != null &&
        currentState.classRooms!.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SelectClassScreen(
            classRooms: currentState.classRooms!,
            fromSharedModeSwitch:
                true, // CRITICAL: Flag for back button interception
          ),
        ),
        (_) => false, // Remove all previous routes
      );
    } else {
      // در غیر این صورت، ابتدا کلاس‌ها را دریافت کن
      homeBloc.add(const LoadClassRoomsEvent());

      // استفاده از BlocListener برای گوش دادن به state
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.classRooms != null && state.classRooms!.isNotEmpty) {
              Navigator.pop(dialogContext); // بستن dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => SelectClassScreen(
                    classRooms: state.classRooms!,
                    fromSharedModeSwitch:
                        true, // CRITICAL: Flag for back button interception
                  ),
                ),
                (_) => false, // Remove all previous routes
              );
            } else if (state.classRoomsError != null) {
              Navigator.pop(dialogContext); // بستن dialog
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.classRoomsError!)));
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.isLoadingClassRooms) {
                return const Center(
                  child: ShimmerPlaceholder(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }
  }
}
