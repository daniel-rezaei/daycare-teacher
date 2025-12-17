import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_profile/child_profile_screen.dart';
import 'package:teacher_app/features/child_status/widgets/appbar_child.dart';
import 'package:teacher_app/features/child_status/widgets/bottom_navigation_bar_child.dart';
import 'package:teacher_app/features/child_status/widgets/check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/more_details_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ChildStatus extends StatefulWidget {
  const ChildStatus({super.key});

  @override
  State<ChildStatus> createState() => _ChildStatusState();
}

class _ChildStatusState extends State<ChildStatus> {
  String? classId;
  bool _hasRequestedData = false;

  @override
  void initState() {
    super.initState();
    _loadClassId();
  }

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString('class_id');
    
    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
      });
      
      // بررسی اینکه آیا داده‌ها قبلاً لود شده‌اند
      final currentState = context.read<ChildBloc>().state;
      if (!_hasRequestedData) {
        _hasRequestedData = true;
        if (currentState.children == null) {
          context.read<ChildBloc>().add(const GetAllChildrenEvent());
        }
        if (currentState.contacts == null) {
          context.read<ChildBloc>().add(const GetAllContactsEvent());
        }
      }
    }
  }

  List<ChildEntity> _getChildrenInClass(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    // فیلتر Contacts با Role="child" و استخراج contact_id های آن‌ها
    final validChildContactIds = contacts
        .where((contact) => contact.role == 'child')
        .map((contact) => contact.id)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();
    
    debugPrint('[CHILD_STATUS_DEBUG] Valid child contact IDs: $validChildContactIds');
    debugPrint('[CHILD_STATUS_DEBUG] Filtering children (classId: $classId)');
    
    // Debug: بررسی همه بچه‌ها
    for (var child in children) {
      debugPrint('[CHILD_STATUS_DEBUG] Child: id=${child.id}, primaryRoomId=${child.primaryRoomId}, status=${child.status}, contactId=${child.contactId}');
    }
    
    // فیلتر بچه‌هایی که contact_id آن‌ها در validChildContactIds موجود است
    // نمایش همه بچه‌های active که contact آن‌ها با Role="child" است
    // حذف فیلتر primaryRoomId تا همه بچه‌ها نمایش داده شوند
    final filtered = children.where((child) {
      final isActive = child.status == 'active';
      final hasValidContactId = child.contactId != null && child.contactId!.isNotEmpty;
      final contactExists = hasValidContactId && validChildContactIds.contains(child.contactId);
      
      final shouldInclude = isActive && hasValidContactId && contactExists;
      
      debugPrint('[CHILD_STATUS_DEBUG] Child ${child.id}: primaryRoomId=${child.primaryRoomId}, isActive=$isActive, hasValidContactId=$hasValidContactId, contactExists=$contactExists, shouldInclude=$shouldInclude');
      
      return shouldInclude;
    }).toList();
    
    debugPrint('[CHILD_STATUS_DEBUG] Filtered children count: ${filtered.length}');
    
    return filtered;
  }

  ContactEntity? _getContactForChild(
    String? contactId,
    List<ContactEntity> contacts,
  ) {
    if (contactId == null || contactId.isEmpty) return null;
    
    try {
      return contacts.firstWhere((contact) => contact.id == contactId);
    } catch (e) {
      return null;
    }
  }

  String _getChildName(ContactEntity? contact) {
    if (contact == null) return 'Unknown';
    
    final firstName = contact.firstName ?? '';
    final lastName = contact.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    return fullName.isNotEmpty ? fullName : 'Unknown';
  }

  String _getPhotoUrl(String? photoId) {
    if (photoId == null || photoId.isEmpty) {
      return '';
    }
    return 'http://51.79.53.56:8055/assets/$photoId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppBarChild(),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFFFF),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -4),
                          blurRadius: 16,
                          color: const Color(0xff000000).withValues(alpha: .10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: BlocBuilder<ChildBloc, ChildState>(
                      builder: (context, state) {
                        if (state.isLoadingChildren || state.isLoadingContacts) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        }

                        final children = state.children;
                        final contacts = state.contacts;

                        if (children != null && contacts != null) {
                          // Debug: بررسی داده‌ها
                          debugPrint('[CHILD_STATUS_DEBUG] classId: $classId');
                          debugPrint('[CHILD_STATUS_DEBUG] Total children from API: ${children.length}');
                          debugPrint('[CHILD_STATUS_DEBUG] Total contacts with role=child: ${contacts.where((c) => c.role == 'child').length}');
                          
                          final childrenInClass = _getChildrenInClass(children, contacts);
                          
                          debugPrint('[CHILD_STATUS_DEBUG] Children in class after filtering: ${childrenInClass.length}');
                          for (var child in childrenInClass) {
                            debugPrint('[CHILD_STATUS_DEBUG] Child: ${child.id}, primaryRoomId: ${child.primaryRoomId}, contactId: ${child.contactId}');
                          }
                          
                          final totalCount = childrenInClass.length;
                          // TODO: باید API attendance اضافه شود برای تعداد حاضر
                          final presentCount = totalCount;

                          return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Children',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff444349),
                                      ),
                                    ),
                                    Text(
                                      '$presentCount/$totalCount',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff444349),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ListView.builder(
                                  itemCount: childrenInClass.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final child = childrenInClass[index];
                                    final contact = _getContactForChild(
                                      child.contactId,
                                      contacts,
                                    );
                                    final childName = _getChildName(contact);
                                    final photoUrl = _getPhotoUrl(child.photo);

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF4F4F5).withValues(alpha: .5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          width: 2,
                                          color: const Color(0xffFAFAFA),
                                        ),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          ClipOval(
                                            child: photoUrl.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: photoUrl,
                                                    httpHeaders: const {
                                                      'Authorization': 'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
                                                    },
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                    placeholder: (_, __) => Container(
                                                      width: 48,
                                                      height: 48,
                                                      color: Colors.grey.shade200,
                                                      child: const CupertinoActivityIndicator(),
                                                    ),
                                                    errorWidget: (_, __, ___) => Container(
                                                      width: 48,
                                                      height: 48,
                                                      color: Colors.grey.shade300,
                                                      child: const Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 48,
                                                    height: 48,
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  childName,
                                                  style: const TextStyle(
                                                    color: Color(0xff444349),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xffDAFEE8),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Assets.images.done.svg(),
                                                      const SizedBox(width: 4),
                                                      const Text(
                                                        'Present',
                                                        style: TextStyle(
                                                          color: Color(0xff0EAB52),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (index == 0) {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  useSafeArea: true,
                                                  builder: (context) {
                                                    return CheckOutWidget();
                                                  },
                                                );
                                              } else if (index == 1) {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  useSafeArea: true,
                                                  builder: (context) {
                                                    return MoreDetailsWidget();
                                                  },
                                                );
                                              } else if (index == 2) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ChildProfileScreen(),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xffFFFFFF),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 12,
                                              ),
                                              child: const Text(
                                                'Check Out',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff444349),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                        }

                        if (state.childrenError != null || 
                            state.contactsError != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                state.childrenError ?? state.contactsError ?? 'خطا در دریافت اطلاعات',
                                style: const TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarChild(),
    );
  }
}
