import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class SelectChildsScreen extends StatefulWidget {
  const SelectChildsScreen({super.key});

  @override
  State<SelectChildsScreen> createState() => _SelectChildsScreenState();
}

class _SelectChildsScreenState extends State<SelectChildsScreen> {
  /// 20 آیتم نمونه
  final List<int> photos = List.generate(20, (i) => i);

  /// آیتم‌های انتخاب شده
  Set<int> selectedItems = {};

  bool get allSelected => selectedItems.length == photos.length;

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
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                    child: ListView.builder(
                      itemCount: photos.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedItems.contains(photos[index]);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedItems.remove(photos[index]);
                              } else {
                                selectedItems.add(photos[index]);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 22),
                            child: Row(
                              children: [
                                /// Avatar
                                SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: ClipOval(
                                    child: Assets
                                        .images
                                        .a71311088a9687505b49ce50537c803aa86b5242c
                                        .image(fit: BoxFit.cover),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                /// Name + Last Play
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Olivia Carter',
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          'Last Play',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 24,
                                          child: VerticalDivider(
                                            color: Color(0xffDBDADD),
                                            thickness: 1,
                                          ),
                                        ),

                                        Text(
                                          'July 16',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const Spacer(),

                                /// Checkbox (حفظ استایل شما)
                                isSelected
                                    ? Assets.images.checkbox.svg()
                                    : Assets.images.checkbox2.svg(),
                              ],
                            ),
                          ),
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
            /// Icon left
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: const Color(0xffDBDADD)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Assets.images.squareArrowRight.svg(),
            ),

            const SizedBox(width: 18),

            /// تعداد انتخاب شده‌ها
            Text(
              '${selectedItems.length} Item${selectedItems.length == 1 ? '' : 's'} Selected',
              style: const TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            /// Select All
            GestureDetector(
              onTap: () {
                setState(() {
                  if (allSelected) {
                    selectedItems.clear();
                  } else {
                    selectedItems = photos.toSet();
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
            ),
          ],
        ),
      ),
    );
  }
}
