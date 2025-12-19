import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
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
    return ModalBottomSheetWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderCheckOut(isIcon: false, title: 'Transfer Class'),
          const Divider(color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transfer Class',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TransferClassList(
                  rooms: const [],
                  selectedClassId: selectedClass,
                  onClassSelected: (value) {
                    setState(() {
                      selectedClass = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                if (selectedClass != null) ...[
                  const SwitchRowWidget(title: 'Check out'),
                  const SizedBox(height: 32),
                  const SwitchRowWidget(title: 'Time out'),
                  const SizedBox(height: 32),
                ],
                ButtonWidget(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save',
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          activeThumbColor: AppColors.backgroundWhite,
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: AppColors.backgroundWhite,
          inactiveTrackColor: AppColors.divider,
          trackOutlineWidth: const WidgetStatePropertyAll(0),
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
          style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
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
                ? AppColors.primary
                : AppColors.backgroundGray,
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
                  ? AppColors.backgroundLight
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
