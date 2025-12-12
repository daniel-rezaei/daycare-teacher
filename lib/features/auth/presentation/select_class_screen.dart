import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/presentation/select_your_profile.dart';
import 'package:teacher_app/features/child_status/widgets/transfer_class_widget.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class SelectClassScreen extends StatefulWidget {
  final List<ClassRoomEntity> classRooms;
  final List<StaffClassEntity> staffClasses;

  const SelectClassScreen({
    super.key,
    required this.classRooms,
    required this.staffClasses,
  });

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  String? selectedClassId;

  @override
  Widget build(BuildContext context) {
    final List<ClassRoomEntity> rooms = widget.classRooms
        .where((e) => e.id != null)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Header
            BackTitleWidget(
              title: 'Select Class',
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 40),
            Assets.images.logoSample.image(height: 116),

            const SizedBox(height: 24),
            const Text(
              'Select Your Class',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Choose the class you want to access',
              style: TextStyle(
                color: const Color(0xff71717A).withValues(alpha: .8),
              ),
            ),

            const SizedBox(height: 48),

            /// 🔹 Classes (from server)
            TransferClassList(
              rooms: rooms,
              selectedClassId: selectedClassId,
              onClassSelected: (classId) {
                setState(() {
                  selectedClassId = classId;
                });
              },
            ),

            const Spacer(),

            /// 🔹 Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: ButtonWidget(
                title: 'Continue',
                isEnabled: selectedClassId != null,
                onTap: selectedClassId == null
                    ? null
                    : () {
                        final selectedStaff = widget.staffClasses
                            .where(
                              (staff) =>
                                  staff.classIds?.contains(selectedClassId) ??
                                  false,
                            )
                            .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectYourProfileScreen(
                              classId: selectedClassId!,
                              staffClasses: selectedStaff,
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
