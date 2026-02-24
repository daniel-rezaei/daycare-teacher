import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teacher_app/core/utils/string_utils.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_guardian_entity.dart';
import 'package:teacher_app/features/child_management/widgets/phone_widget.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class InfoCardOverviewWidget extends StatelessWidget {
  final ChildGuardianEntity guardian;
  final ContactEntity? contact;

  const InfoCardOverviewWidget({
    super.key,
    required this.guardian,
    this.contact,
  });

  String _getPhotoUrl(String? photoId) {
    if (photoId == null || photoId.isEmpty) {
      return '';
    }
    return 'http://51.79.53.56:8055/assets/$photoId';
  }

  @override
  Widget build(BuildContext context) {
    final name = contact != null
        ? '${contact!.firstName ?? ''} ${contact!.lastName ?? ''}'.trim()
        : 'Unknown';
    final capitalizedRelation = StringUtils.capitalizeFirstLetter(guardian.relation);
    final relation = capitalizedRelation.isEmpty ? 'Unknown' : capitalizedRelation;
    final photo = contact?.photo;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffF0E7FF),
          border: Border.all(color: Color(0xffFAFAFA), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: photo != null && photo.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _getPhotoUrl(photo),
                            httpHeaders: const {
                              'Authorization':
                                  'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
                            },
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 32,
                              height: 32,
                              color: Colors.grey.shade200,
                              child: const CupertinoActivityIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                Assets.images.image.image(),
                          ),
                        )
                      : Assets.images.image.image(),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Unknown',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        relation,
                        style: TextStyle(
                          color: Color(0xff71717A).withValues(alpha: .8),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            PhoneWidget(phone: contact?.phone),
          ],
        ),
      ),
    );
  }
}
