import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/card_item_list_widget.dart';
import 'package:teacher_app/features/home/widgets/card_notifications_widget.dart';
import 'package:teacher_app/features/home/widgets/total_notification_widget.dart';
import 'package:teacher_app/features/home/widgets/upcoming_events_header_widget.dart';

class CardWidget extends StatefulWidget {
  const CardWidget({super.key});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF).withValues(alpha: .7),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -4),
            blurRadius: 16,
            color: Color(0xff95939D).withValues(alpha: .2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CardNotificationsWidget(),
          SizedBox(height: 12),
          TotalNotificationWidget(),
          SizedBox(height: 32),
          UpcomingEventsHeaderWidget(),
          SizedBox(height: 32),
          CardItemListWidget(),
        ],
      ),
    );
  }
}
