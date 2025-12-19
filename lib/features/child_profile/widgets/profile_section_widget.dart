import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ProfileChildSectionWidget extends StatelessWidget {
  final String childName;
  final String? childPhoto;
  final String childId;

  const ProfileChildSectionWidget({
    super.key,
    required this.childName,
    this.childPhoto,
    required this.childId,
  });

  String _getPhotoUrl(String? photoId) {
    if (photoId == null || photoId.isEmpty) {
      return '';
    }
    return 'http://51.79.53.56:8055/assets/$photoId';
  }

  String _formatDateOfBirth(String? dob) {
    if (dob == null || dob.isEmpty) return '';
    try {
      final date = DateTime.parse(dob);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, state) {
        String? dob;
        if (state is GetChildByIdSuccess || state is GetChildByContactIdSuccess) {
          dob = state.child?.dob;
        }

        final dobFormatted = _formatDateOfBirth(dob);

        return Row(
          children: [
            SizedBox(width: 16),
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: childPhoto != null && childPhoto!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _getPhotoUrl(childPhoto),
                        httpHeaders: const {
                          'Authorization':
                              'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
                        },
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 68,
                          height: 68,
                          color: Colors.grey.shade200,
                          child: const CupertinoActivityIndicator(),
                        ),
                        errorWidget: (_, __, ___) => Assets.images
                            .a6fadd07775295cc625abaf33feed2e172cf00a8c
                            .image(),
                      )
                    : Assets.images.a6fadd07775295cc625abaf33feed2e172cf00a8c
                        .image(),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffEFEEF0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 2, color: Color(0xffFAFAFA)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Color(0xffE4D3FF).withValues(alpha: .5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Assets.images.gift.svg(),
                      SizedBox(width: 8),
                      Text(
                        'Date of Birth',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 1,
                        height: 24,
                        decoration: BoxDecoration(color: Color(0xffDBDADD)),
                      ),
                      SizedBox(width: 4),
                      Text(
                        dobFormatted.isNotEmpty ? dobFormatted : 'Not available',
                        style: TextStyle(
                          color: Color(0xff7B2AF3),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
