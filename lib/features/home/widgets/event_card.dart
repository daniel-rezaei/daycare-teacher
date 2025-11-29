// import 'package:flutter/material.dart';
// import 'package:teacher_app/gen/assets.gen.dart';

// Widget eventCard(int index, int stackIndex, BuildContext context) {
//   return Container(
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(16),
//       color: Color(0xffDEF4FF),
//       border: Border.all(width: 2, color: Color(0xffFAFAFA)),
//       boxShadow: [
//         BoxShadow(
//           blurRadius: 8,
//           color: Color(0xffE4D3FF).withValues(alpha: 0.5),
//         ),
//       ],
//     ),
//     padding: EdgeInsets.all(20),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Field Trip To Zoo",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Color(0xff444349),
//           ),
//         ),
//         SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: Color(0xffFFFFFF).withValues(alpha: 0.7),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 blurRadius: 8,
//                 color: Color(0xffE4D3FF).withValues(alpha: 0.5),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//           child: Row(
//             children: [
//               Assets.images.calendarDate.svg(),
//               SizedBox(width: 10),
//               Text("Monday", style: TextStyle(fontSize: 14)),
//               SizedBox(width: 4),
//               Container(width: 1, height: 24, color: Color(0xffDBDADD)),
//               SizedBox(width: 4),
//               Text("July 16", style: TextStyle(fontSize: 14)),
//               SizedBox(width: 4),
//               Container(width: 1, height: 24, color: Color(0xffDBDADD)),
//               SizedBox(width: 4),
//               Text("12:00 AM", style: TextStyle(fontSize: 14)),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
