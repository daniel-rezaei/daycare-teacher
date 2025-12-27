import 'package:flutter/material.dart';
import 'package:teacher_app/core/utils/string_utils.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class PhoneWidget extends StatelessWidget {
  final String? phone;

  const PhoneWidget({super.key, this.phone});

  @override
  Widget build(BuildContext context) {
    final formattedPhone = phone != null && phone!.isNotEmpty
        ? StringUtils.formatCanadianPhoneNumber(phone)
        : null;
    
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Assets.images.phoneRounded2.svg(),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              formattedPhone != null && formattedPhone.isNotEmpty
                  ? formattedPhone
                  : 'Not available',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
