import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';

class TransferClassWidget extends StatefulWidget {
  const TransferClassWidget({super.key});

  @override
  State<TransferClassWidget> createState() => _TransferClassWidgetState();
}

class _TransferClassWidgetState extends State<TransferClassWidget> {
  String? selectedClass;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, -4),
              color: Color(0xff95939D).withValues(alpha: .2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            HeaderCheckOut(isIcon: false, title: 'Transfer Class'),
            Divider(color: Color(0xffDBDADD)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Transfer Class',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  TransferClassList(
                    rooms: const [],
                    selectedClassId: selectedClass,
                    onClassSelected: (value) {
                      setState(() {
                        selectedClass = value;
                      });
                    },
                  ),
                  SizedBox(height: 32),
                  if (selectedClass != null) ...[
                    SwitchRowWidget(title: 'Check out'),
                    SizedBox(height: 32),
                    SwitchRowWidget(title: 'Time out'),
                    SizedBox(height: 32),
                  ],
                  ButtonWidget(
                    title: 'Save',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwitchRowWidget extends StatefulWidget {
  final String title;
  const SwitchRowWidget({super.key, required this.title});

  @override
  State<SwitchRowWidget> createState() => _SwitchRowWidgetState();
}

class _SwitchRowWidgetState extends State<SwitchRowWidget> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: Color(0xff444349),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        Switch(
          value: value,
          activeThumbColor: Color(0xffFFFFFF),
          activeTrackColor: Color(0xff9C5CFF),
          inactiveThumbColor: Color(0xffFFFFFF),
          inactiveTrackColor: Color(0xffDBDADD),
          trackOutlineWidth: WidgetStatePropertyAll(0),
          onChanged: (newValue) {
            setState(() {
              value = newValue;
            });
          },
        ),
      ],
    );
  }
}

class TransferClassList extends StatelessWidget {
  final List<ClassRoomEntity> rooms;
  final String? selectedClassId;
  final ValueChanged<String> onClassSelected;

  const TransferClassList({
    super.key,
    required this.rooms,
    required this.selectedClassId,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔹 Empty state
    if (rooms.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No classes available',
          style: TextStyle(color: Color(0xff71717A), fontSize: 14),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: rooms.map((room) {
        final roomId = room.id;
        final roomName = room.roomName ?? 'Unknown';
        final isSelected = roomId != null && roomId == selectedClassId;

        return _ClassItem(
          id: roomId,
          name: roomName,
          isSelected: isSelected,
          onTap: roomId == null ? null : () => onClassSelected(roomId),
        );
      }).toList(),
    );
  }
}

class _ClassItem extends StatelessWidget {
  final String? id;
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ClassItem({
    required this.id,
    required this.name,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff9C5CFF)
                : const Color(0xffEFEEF0),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xffF4F4F5)
                  : const Color(0xff444349),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
