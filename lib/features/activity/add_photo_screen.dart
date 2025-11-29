import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AddPhotoScreen extends StatelessWidget {
  const AddPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Assets.images.arrowLeft.svg(),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Add Photo – Toddler 2',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF).withValues(alpha: .6),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        topLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -4),
                          blurRadius: 16,
                          color: Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        Assets.images.photo.image(height: 116),
                        SizedBox(height: 24),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 30,
                            fontWeight: .w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Take a photo or select one from your gallery',
                          style: TextStyle(
                            color: Color(0xff71717A).withValues(alpha: .8),
                            fontSize: 16,
                            fontWeight: .w600,
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
      bottomNavigationBar: ButtonsInfoCardPhoto(),
    );
  }
}

class ButtonsInfoCardPhoto extends StatelessWidget {
  const ButtonsInfoCardPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 212,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          InfoCardPhoto(
            title: 'Take Photo',
            icon: Assets.images.photo2.image(height: 68),
          ),
          SizedBox(height: 16),
          InfoCardPhoto(
            title: 'Choose From library',
            icon: Assets.images.gallery.image(height: 68),
          ),
        ],
      ),
    );
  }
}

class InfoCardPhoto extends StatelessWidget {
  final String title;
  final Widget icon;
  const InfoCardPhoto({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        border: Border.all(width: 2, color: Color(0xffFAFAFA)),
        boxShadow: [
          BoxShadow(
            color: Color(0xffE4D3FF).withValues(alpha: .5),
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xff444349),
              fontSize: 16,
              fontWeight: .w600,
            ),
          ),
          icon,
        ],
      ),
    );
  }
}
