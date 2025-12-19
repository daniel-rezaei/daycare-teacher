import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/features/auth/presentation/logout_widget.dart';
import 'package:teacher_app/features/auth/presentation/select_class_screen.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/features/profile/presentation/bloc/profile_bloc.dart';
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
    
    debugPrint('[PROFILE_DEBUG] Loading contactId: $savedContactId, authMode: $savedAuthMode, staffId: $savedStaffId, classId: $savedClassId');
    
    if (mounted && savedContactId != null && savedContactId.isNotEmpty) {
      setState(() {
        contactId = savedContactId;
        authMode = savedAuthMode;
        staffId = savedStaffId;
        classId = savedClassId;
      });
      context.read<ProfileBloc>().add(GetContactEvent(id: savedContactId));
    } else {
      debugPrint('[PROFILE_DEBUG] contactId is null or empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is GetContactLoading) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                _buildLoadingAvatar(),
                const SizedBox(width: 12),
                const Expanded(
                  child: CupertinoActivityIndicator(),
                ),
                _buildSwitchAccountIcon(),
              ],
            ),
          );
        }

        if (state is GetContactSuccess) {
          final contact = state.contact;
          final fullName = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
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

        if (state is GetContactFailure) {
          debugPrint('[PROFILE_DEBUG] GetContactFailure: ${state.message}');
          // در صورت خطا، placeholder نمایش بده
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
        }

        // Initial state - show placeholder
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
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? teacherName;
        String? teacherPhoto;
        String? className;
        
        if (state is GetContactSuccess) {
          final contact = state.contact;
          teacherName = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
          teacherPhoto = contact.photo;
        }
        
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is GetClassRoomsSuccess && classId != null) {
              try {
                final classRoom = authState.classRooms.firstWhere(
                  (room) => room.id == classId,
                );
                className = classRoom.roomName;
              } catch (e) {
                // ignore
              }
            }
            
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
        placeholder: (_, __) => _buildLoadingAvatar(),
        errorWidget: (_, __, ___) => _buildPlaceholderAvatar(),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? teacherName;
        String? teacherPhoto;
        String? className;

        if (state is GetContactSuccess) {
          final contact = state.contact;
          teacherName = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
          teacherPhoto = contact.photo;
        }

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is GetClassRoomsSuccess && classId != null) {
              try {
                final classRoom = authState.classRooms.firstWhere(
                  (room) => room.id == classId,
                );
                className = classRoom.roomName;
              } catch (e) {
                // ignore
              }
            }

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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const CupertinoActivityIndicator(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholderAvatar() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? teacherName;
        String? teacherPhoto;
        String? className;

        if (state is GetContactSuccess) {
          final contact = state.contact;
          teacherName = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
          teacherPhoto = contact.photo;
        }

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is GetClassRoomsSuccess && classId != null) {
              try {
                final classRoom = authState.classRooms.firstWhere(
                  (room) => room.id == classId,
                );
                className = classRoom.roomName;
              } catch (e) {
                // ignore
              }
            }

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

  void _navigateToSelectClass() {
    final authBloc = context.read<AuthBloc>();
    final currentState = authBloc.state;
    
    // اگر کلاس‌ها قبلاً دریافت شده باشند، مستقیماً به صفحه برو
    if (currentState is GetClassRoomsSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectClassScreen(
            classRooms: currentState.classRooms,
          ),
        ),
      );
    } else {
      // در غیر این صورت، ابتدا کلاس‌ها را دریافت کن
      authBloc.add(const GetClassRoomsEvent());
      
      // استفاده از BlocListener برای گوش دادن به state
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is GetClassRoomsSuccess) {
              Navigator.pop(dialogContext); // بستن dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectClassScreen(
                    classRooms: state.classRooms,
                  ),
                ),
              );
            } else if (state is GetClassRoomsFailure) {
              Navigator.pop(dialogContext); // بستن dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is GetClassRoomsLoading) {
                return const Center(
                  child: CupertinoActivityIndicator(),
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

