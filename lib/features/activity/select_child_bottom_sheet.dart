import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teacher_app/core/palette.dart';
import 'package:teacher_app/features/activity/widgets/staff_circle_item.dart';

Future<Map<String, String>?> showFilterBottomSheetAccident(
  BuildContext context,
) {
  final filters = {
    'Nature of injury': [
      'Bite',
      'Bump',
      'Burn',
      'Scratch',
      'Bruise',
      'Nosebleed',
      'Other',
    ],
    'Injured Body Part': [
      'Head',
      'Face',
      'Arm',
      'Hand',
      'Leg',
      'Knee',
      'Finger',
      'Other',
    ],
    'Location': [
      'Classroom',
      'Playground',
      'Hallway',
      'Dining area',
      'Bathroom',
      'Nap room',
    ],
    'First Aid Provided': [
      'Ice pack',
      'Bandage',
      'Antiseptic',
      'Cleaned with water',
      'Rested',
      'Other',
    ],
    'Childs Reaction': [
      'Calm',
      'Crying',
      'Scared',
      'Angry',
      'Shocked',
      'FineAfterCare',
    ],
  };
  final filter2 = {
    'Dated Notified': ['Today', 'Yesterday', '2 Days Ago', 'More Days Ago'],
  };
  final filter3 = {
    'How To Notify': ['Phone', 'Voicemail', 'Email', 'In-person'],
  };
  final List<Map<String, dynamic>> staff = [
    {
      "image": "assets/images/avatar1.png",
      "name": "Katy Smith",
      'subTitle': "Supervisor",
    },
    {
      "image": "assets/images/avatar1.png",
      "name": "Jane Doe",
      'subTitle': "Teacher",
    },
    {
      "image": "assets/images/avatar1.png",
      "name": "Henry Davis",
      'subTitle': "Supervisor",
    },
    {
      "image": "assets/images/avatar1.png",
      "name": "Anna Smith",
      'subTitle': "Teacher",
    },
  ];
  final Map<String, String> selected = {};
  int selectedIndex = 0;
  bool consent = false;
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Accident",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset('assets/images/ic_cancel.svg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Palette.bgBorder),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'July16,2025',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Palette.textForeground,
                        ),
                      ),
                      Text(
                        '12:00 Am',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Palette.textForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...filters.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Palette.textForeground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: entry.value.map((option) {
                              final isSelected = selected[entry.key] == option;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected[entry.key] = option;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Palette.txtTagForeground3.withOpacity(
                                            0.8,
                                          )
                                        : Palette.borderPrimary20,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Palette.textForeground,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  Text(
                    "Staff Involved",
                    style: TextStyle(
                      fontSize: 16,
                      color: Palette.textForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: staff.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: StaffCircleItemWidget(
                            image: staff[index]["image"],
                            name: staff[index]["name"],
                            subTitle: staff[index]["subTitle"],
                            isSelected: selectedIndex == index,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ...filter2.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Palette.textForeground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: entry.value.map((option) {
                              final isSelected = selected[entry.key] == option;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected[entry.key] = option;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Palette.txtTagForeground3.withOpacity(
                                            0.8,
                                          )
                                        : Palette.borderPrimary20,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Palette.textForeground,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Medical Follow-Up required'),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: consent,
                            activeColor: Palette.borderPrimary,
                            onChanged: (v) {
                              setState(() {
                                consent = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Incident Reported to Authority'),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: false,
                            activeColor: Colors.purple,
                            onChanged: (v) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Parent Notified'),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: false,
                            activeColor: Colors.purple,
                            onChanged: (v) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...filter3.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Palette.textForeground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: entry.value.map((option) {
                              final isSelected = selected[entry.key] == option;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected[entry.key] = option;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Palette.txtTagForeground3.withOpacity(
                                            0.8,
                                          )
                                        : Palette.borderPrimary20,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Palette.textForeground,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                  Text(
                    "Decription",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Please enter a description",
                        hintStyle: const TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.borderPrimary20,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/images/ic_attachh.svg'),
                          SizedBox(width: 8),
                          Text(
                            "Attach Photo",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Palette.borderPrimary80,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.borderPrimary80,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
