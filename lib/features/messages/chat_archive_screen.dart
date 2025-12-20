import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ChatArchiveScreen extends StatelessWidget {
  const ChatArchiveScreen({super.key});

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
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Assets.images.arrowLeft.svg(),
                            const SizedBox(width: 16),
                            const Text(
                              'Messages',
                              style: TextStyle(
                                color: Color(0xff444349),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: const Text(
                          'New message',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// --- Search ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffFFFFFF),
                        border: InputBorder.none,
                        hintText: 'Search Child...',
                        hintStyle: TextStyle(
                          color: const Color(0xff71717A).withValues(alpha: .8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 10),
                          child: Assets.images.search.svg(),
                        ),
                        prefixIconConstraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// --- Content Area ---
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFFFF).withValues(alpha: .7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: .1),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Chat archive',
                              style: TextStyle(
                                color: Color(0xff444349),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sort',
                              style: TextStyle(
                                color: Color(0xff444349),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// --- List ---
                        Expanded(
                          child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xffFFFFFF),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xffBAB9C0,
                                      ).withValues(alpha: .32),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
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

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Olivia Carter',
                                              style: TextStyle(
                                                color: Color(0xff444349),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Mother is Mia Turner',
                                              style: TextStyle(
                                                color: const Color(
                                                  0xff71717A,
                                                ).withValues(alpha: .8),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Spacer(),

                                        Text(
                                          '11:31 AM',
                                          style: TextStyle(
                                            color: const Color(
                                              0xff71717A,
                                            ).withValues(alpha: .8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      "Emma’s enjoyed painting today. Look at her masterpleace",
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
