import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
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
                    selectedClass: selectedClass,
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

class TransferClassList extends StatefulWidget {
  final String? selectedClass;
  final void Function(String) onClassSelected;

  const TransferClassList({
    super.key,
    this.selectedClass,
    required this.onClassSelected,
  });

  @override
  State<TransferClassList> createState() => _TransferClassListState();
}

class _TransferClassListState extends State<TransferClassList> {
  final List<String> classes = [
    "Infants",
    "Toddler 1",
    "Toddler 2",
    "Preschool",
    "Pre-K",
    "Kinders",
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(classes.length, (index) {
        final item = classes[index];
        final bool isSelected = widget.selectedClass == item;

        return GestureDetector(
          onTap: () {
            widget.onClassSelected(item);
          },
          child: Container(
            width: 95,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xff9C5CFF) : Color(0xffEFEEF0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? Color(0xffF4F4F5) : Color(0xff444349),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }
}
