import 'package:flutter/material.dart';

class ItemWidget extends StatelessWidget {
  final Color colorIcon;
  final String title;
  final String dec;
  final Widget icon;
  final List<Widget>? childAvatars;
  const ItemWidget({
    super.key,
    required this.colorIcon,
    required this.title,
    required this.dec,
    required this.icon,
    this.childAvatars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        border: Border.all(width: 2, color: Color(0xffFAFAFA)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Color(0xffE4D3FF).withValues(alpha: .5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorIcon,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(8),
            child: icon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff681AD6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dec,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff444349),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (childAvatars != null && childAvatars!.isNotEmpty) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              height: 24,
              child: Align(
                alignment: Alignment.centerRight,
                child: Stack(
                  clipBehavior: Clip.none,
                children: childAvatars!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final avatar = entry.value;
                  return Positioned(
                    right: 16.0 * index,
                    child: avatar,
                  );
                }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
