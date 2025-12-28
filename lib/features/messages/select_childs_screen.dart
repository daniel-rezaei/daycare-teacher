import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/features/activity/widgets/meal_activity_bottom_sheet.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class SelectChildsScreen extends StatefulWidget {
  /// If true, returns selected children when back button is pressed
  /// If false (default), works as before for Chat flow
  final bool returnSelectedChildren;
  
  /// Class ID to filter children by primary_room_id (only used when returnSelectedChildren is true)
  final String? classId;

  const SelectChildsScreen({
    super.key,
    this.returnSelectedChildren = false,
    this.classId,
  });

  @override
  State<SelectChildsScreen> createState() => _SelectChildsScreenState();
}

class _SelectChildsScreenState extends State<SelectChildsScreen> {
  /// آیتم‌های انتخاب شده (Child IDs)
  Set<String> selectedChildIds = {};

  @override
  void initState() {
    super.initState();
    debugPrint('[SELECT_CHILDS] ========== Entering SelectChildsScreen ==========');
    debugPrint('[SELECT_CHILDS] returnSelectedChildren: ${widget.returnSelectedChildren}');
    debugPrint('[SELECT_CHILDS] classId: ${widget.classId}');
    
    // Load children and contacts if needed
    final childState = context.read<ChildBloc>().state;
    if (childState.children == null) {
      debugPrint('[SELECT_CHILDS] Loading children...');
      context.read<ChildBloc>().add(const GetAllChildrenEvent());
    }
    if (childState.contacts == null) {
      debugPrint('[SELECT_CHILDS] Loading contacts...');
      context.read<ChildBloc>().add(const GetAllContactsEvent());
    }
  }

  bool get allSelected {
    final filteredChildren = _filteredChildren;
    return filteredChildren.isNotEmpty && selectedChildIds.length == filteredChildren.length;
  }

  List<ChildEntity> get _children {
    final childState = context.read<ChildBloc>().state;
    return childState.children ?? [];
  }

  /// Filter children by primary_room_id = class_id when used from Log Activity
  List<ChildEntity> get _filteredChildren {
    final allChildren = _children;
    
    // If returnSelectedChildren is true and classId is provided, filter by primary_room_id
    if (widget.returnSelectedChildren && widget.classId != null && widget.classId!.isNotEmpty) {
      debugPrint('[SELECT_CHILDS] Filtering children by class_id: ${widget.classId}');
      final filtered = allChildren.where((child) {
        final matches = child.primaryRoomId == widget.classId;
        if (matches) {
          debugPrint('[SELECT_CHILDS] Child ${child.id} matches class_id (primary_room_id: ${child.primaryRoomId})');
        }
        return matches;
      }).toList();
      debugPrint('[SELECT_CHILDS] Filtered children count: ${filtered.length} out of ${allChildren.length}');
      return filtered;
    }
    
    // No filtering for Chat flow
    return allChildren;
  }

  List<ContactEntity> get _contacts {
    final childState = context.read<ChildBloc>().state;
    return childState.contacts ?? [];
  }

  ContactEntity? _getContactForChild(ChildEntity child) {
    if (child.contactId == null || child.contactId!.isEmpty) return null;
    try {
      return _contacts.firstWhere((c) => c.id == child.contactId);
    } catch (e) {
      return null;
    }
  }

  String _getChildName(ChildEntity child) {
    final contact = _getContactForChild(child);
    if (contact == null) return 'Unknown';
    final firstName = contact.firstName ?? '';
    final lastName = contact.lastName ?? '';
    return '$firstName $lastName'.trim().isEmpty ? 'Unknown' : '$firstName $lastName'.trim();
  }

  void _handleBack() {
    debugPrint('[SELECT_CHILDS] ========== TOP BACK ICON TAPPED ==========');
    debugPrint('[SELECT_CHILDS] Back button pressed - navigating back only');
    debugPrint('[SELECT_CHILDS] Selected children count: ${selectedChildIds.length}');
    debugPrint('[SELECT_CHILDS] BottomSheet will NOT be triggered from back button');
    debugPrint('[SELECT_CHILDS] Navigation popped - returning to previous screen');
    
    // CRITICAL: Back button ALWAYS just navigates back
    // It NEVER returns children and NEVER triggers BottomSheet
    Navigator.pop(context);
    
    debugPrint('[SELECT_CHILDS] Navigation completed - BottomSheet not triggered');
  }

  void _handleActionIconTap() {
    debugPrint('[SELECT_CHILDS] ========== BOTTOM ACTION ICON TAPPED ==========');
    debugPrint('[SELECT_CHILDS] Action icon tapped');
    debugPrint('[SELECT_CHILDS] Selected children count: ${selectedChildIds.length}');
    
    if (selectedChildIds.isEmpty) {
      debugPrint('[SELECT_CHILDS] No children selected, action icon disabled');
      return;
    }

    if (!widget.returnSelectedChildren) {
      debugPrint('[SELECT_CHILDS] Not in return mode, ignoring action icon');
      return;
    }

    final selectedChildren = _filteredChildren.where((c) => c.id != null && selectedChildIds.contains(c.id)).toList();
    debugPrint('[SELECT_CHILDS] Opening MealActivityBottomSheet with ${selectedChildren.length} children');
    debugPrint('[SELECT_CHILDS] BottomSheet triggered from BOTTOM ACTION ICON only');
    
    if (selectedChildren.isNotEmpty) {
      final now = DateTime.now();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        builder: (context) => MealActivityBottomSheet(
          selectedChildren: selectedChildren,
          dateTime: now,
        ),
      );
      debugPrint('[SELECT_CHILDS] MealActivityBottomSheet opened successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Header ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _handleBack,
                    child: Row(
                      children: [
                        Assets.images.arrowLeft.svg(),
                        const SizedBox(width: 16),
                        const Text(
                          'Select Childs',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// --- Main Container ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFFFF),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                        topLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -4),
                          blurRadius: 16,
                          color: const Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),

                    /// --- List ---
                    child: BlocBuilder<ChildBloc, ChildState>(
                      builder: (context, state) {
                        if (state.isLoadingChildren) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final filteredChildren = _filteredChildren;
                        if (filteredChildren.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                widget.returnSelectedChildren && widget.classId != null
                                    ? 'No children found for this class'
                                    : 'No children found',
                                style: const TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredChildren.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final child = filteredChildren[index];
                            if (child.id == null) return const SizedBox.shrink();
                            
                            final isSelected = selectedChildIds.contains(child.id);
                            final childName = _getChildName(child);

                            return GestureDetector(
                              onTap: () {
                                debugPrint('[SELECT_CHILDS] Child tapped: ${child.id}, name: $childName');
                                setState(() {
                                  if (isSelected) {
                                    selectedChildIds.remove(child.id);
                                    debugPrint('[SELECT_CHILDS] Removed child: ${child.id}');
                                  } else {
                                    selectedChildIds.add(child.id!);
                                    debugPrint('[SELECT_CHILDS] Added child: ${child.id}');
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 22),
                                child: Row(
                                  children: [
                                    /// Avatar
                                    ChildAvatarWidget(
                                      photoId: child.photo,
                                      size: 48,
                                    ),

                                    const SizedBox(width: 8),

                                    /// Name
                                    Expanded(
                                      child: Text(
                                        childName,
                                        style: const TextStyle(
                                          color: Color(0xff444349),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    /// Checkbox
                                    isSelected
                                        ? Assets.images.checkbox.svg()
                                        : Assets.images.checkbox2.svg(),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// --- Bottom Bar ---
      bottomNavigationBar: Container(
        height: 86,
        decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff95939D).withValues(alpha: .2),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            /// Icon left - Action icon (only functional when returnSelectedChildren is true)
            GestureDetector(
              onTap: widget.returnSelectedChildren ? _handleActionIconTap : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.returnSelectedChildren && selectedChildIds.isNotEmpty ? 1.0 : 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: widget.returnSelectedChildren && selectedChildIds.isNotEmpty
                          ? const Color(0xff9C5CFF)
                          : const Color(0xffDBDADD),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: widget.returnSelectedChildren && selectedChildIds.isNotEmpty
                        ? const Color(0xffF0E7FF)
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Assets.images.squareArrowRight.svg(
                    colorFilter: widget.returnSelectedChildren && selectedChildIds.isNotEmpty
                        ? const ColorFilter.mode(Color(0xff9C5CFF), BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 18),

            /// تعداد انتخاب شده‌ها
            BlocBuilder<ChildBloc, ChildState>(
              builder: (context, state) {
                return Text(
                  '${selectedChildIds.length} Item${selectedChildIds.length == 1 ? '' : 's'} Selected',
                  style: const TextStyle(
                    color: Color(0xff444349),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),

            const Spacer(),

            /// Select All
            Builder(
              builder: (context) {
                final filteredChildren = _filteredChildren;
                final allChildIds = filteredChildren.where((c) => c.id != null).map((c) => c.id!).toSet();
                
                return GestureDetector(
                  onTap: () {
                    debugPrint('[SELECT_CHILDS] Select All tapped');
                    setState(() {
                      if (allSelected) {
                        selectedChildIds.clear();
                        debugPrint('[SELECT_CHILDS] Cleared all selections');
                      } else {
                        selectedChildIds = allChildIds;
                        debugPrint('[SELECT_CHILDS] Selected all: ${selectedChildIds.length}');
                      }
                    });
                  },
                  child: Row(
                    children: [
                      allSelected
                          ? Assets.images.checkbox.svg()
                          : Assets.images.checkbox2.svg(),
                      const SizedBox(width: 8),
                      const Text(
                        'Select All',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
