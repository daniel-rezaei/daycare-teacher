import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/widgets/upcoming_events_header_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/day_strip_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BackTitleWidget(title: 'Personal Information'),
                  Row(
                    children: [
                      Container(
                        height: 68,
                        width: 68,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        margin: EdgeInsets.only(left: 16),
                        child: Assets.images.image.image(),
                      ),
                      SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            'Katy Smith',
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
                              border: Border.all(
                                width: 2,
                                color: Color(0xffFAFAFA),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Color(
                                    0xffE4D3FF,
                                  ).withValues(alpha: .5),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Assets.images.leftSlotItems.svg(),
                                SizedBox(width: 8),
                                Text(
                                  'Toddler 2',
                                  style: TextStyle(
                                    color: Color(0xff681AD6),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF).withValues(alpha: .4),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -4),
                          blurRadius: 16,
                          color: Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DayStripWidget(),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFFFFFF).withValues(alpha: .7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Assets.images.checkin.svg(),
                              SizedBox(width: 4),
                              Text(
                                'Check_In',
                                style: TextStyle(
                                  color: Color(0xff6D6B76),
                                  fontSize: 12,
                                  fontWeight: .w400,
                                ),
                              ),
                              SizedBox(width: 14),
                              Text(
                                '8:00',
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 16,
                                  fontWeight: .w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AM',
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 14,
                                  fontWeight: .w400,
                                ),
                              ),
                              SizedBox(width: 10),
                              Assets.images.checkout.svg(),
                              SizedBox(width: 4),
                              Text(
                                'Check_Out',
                                style: TextStyle(
                                  color: Color(0xff6D6B76),
                                  fontSize: 12,
                                  fontWeight: .w400,
                                ),
                              ),
                              SizedBox(width: 14),
                              Text(
                                '12:00',
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 16,
                                  fontWeight: .w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AM',
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 14,
                                  fontWeight: .w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFFFFFF),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                offset: Offset(0, -4),
                                color: Color(0xff000000).withValues(alpha: .1),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  MailCardWidget(
                                    icon: Assets.images.mailbox.svg(),
                                    title: 'Email',
                                    subTitle: 'Smith@gmail.com',
                                  ),
                                  SizedBox(width: 12),
                                  MailCardWidget(
                                    icon: Assets.images.phoneRounded.svg(),
                                    title: 'Phone',
                                    subTitle: '(123)456-7890',
                                  ),
                                ],
                              ),
                              SizedBox(height: 32),
                              Text(
                                'Schedule',
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 16,
                                  fontWeight: .w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              ListView.builder(
                                itemCount: 4,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? Color(0xffF0E7FF)
                                          : Color(0xffFFFFFF),
                                      borderRadius: BorderRadius.circular(16),
                                      border: index == 0
                                          ? Border.all(
                                              color: Color(0xffFAFAFA),
                                              width: 2,
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 8,
                                          color: Color(
                                            0xffE4D3FF,
                                          ).withValues(alpha: .5),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Tuesday',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 16,
                                            fontWeight: .w600,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          '09:00',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 16,
                                            fontWeight: .w600,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'AM',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 14,
                                            fontWeight: .w400,
                                          ),
                                        ),
                                        Text(
                                          ' - 12:00',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 16,
                                            fontWeight: .w600,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'AM',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 14,
                                            fontWeight: .w400,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: Color(0xffDBDADD),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'July 16',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 14,
                                            fontWeight: .w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 32),
                              UpcomingEventsHeaderWidget(),
                              SizedBox(height: 32),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Text(
                                      'Log Out',
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 16,
                                        fontWeight: .w600,
                                      ),
                                    ),
                                    Assets.images.arrowRight.svg(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MailCardWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subTitle;
  const MailCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffF7F7F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xffFAFAFA), width: 2),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            icon,
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: .w600,
              ),
            ),
            Text(
              subTitle,
              style: TextStyle(
                color: Color(0xff625F6A),
                fontSize: 14,
                fontWeight: .w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackTitleWidget extends StatelessWidget {
  final String title;
  const BackTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              color: Colors.transparent,
              child: Assets.images.arrowLeft2.svg(),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
