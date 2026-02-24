import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teacher_app/core/palette.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/widgets/tag_selector.dart';

class LessenScreen extends StatefulWidget {
  const LessenScreen({super.key, required this.plan});

  /// All display values come from the plan (from API).
  final LearningPlanItem plan;

  @override
  State<LessenScreen> createState() => _LessenScreenState();
}

class _LessenScreenState extends State<LessenScreen> {
  LearningPlanItem get _plan => widget.plan;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE9DFFF), Color(0xFFF3EFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Lessen', style: TextStyle(color: Colors.black)),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 8.0,
                      right: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _plan.title.isEmpty ? '—' : _plan.title,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Palette.textForeground,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.edit),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  Container(
                    constraints: BoxConstraints(minHeight: screenHeight * 4 / 5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Duration",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_calanders.svg',
                              ),
                              Expanded(
                                child: Text(
                                  ' ${_plan.dateRangeDisplay.isEmpty ? "—" : _plan.dateRangeDisplay}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.textForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          label("Category", _plan.categoryName.isEmpty ? '—' : _plan.categoryName),
                          const SizedBox(height: 8),
                          label("Age Band", _plan.ageBandName.isEmpty ? '—' : _plan.ageBandName),
                          const SizedBox(height: 8),
                          label("Class", _plan.roomName.isEmpty ? '—' : _plan.roomName),
                          const SizedBox(height: 14),
                          Text(
                            "Video Link",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (_plan.videoLink == null || _plan.videoLink!.isEmpty) ? '—' : _plan.videoLink!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Palette.txtPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TagSelectorWidget(
                            initialTags: _plan.tags,
                            hasBackground: false,
                            showSuggestions: false,
                          ),
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            (_plan.description == null || _plan.description!.isEmpty) ? '—' : _plan.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Palette.textForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget label(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Palette.textForeground, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Palette.textForeground,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
