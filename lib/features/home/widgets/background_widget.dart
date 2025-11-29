import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Assets.images.a031e3e91d4e9e9792cce85939482907d0c5dd37c.image(
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
