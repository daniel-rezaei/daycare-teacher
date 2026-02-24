import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_plan_entity.dart';
import 'package:teacher_app/features/activity/lessen.dart';
import 'package:teacher_app/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:teacher_app/features/activity/widgets/lessen_card_colaps.dart';

class LessenListWidget extends StatefulWidget {
  const LessenListWidget({
    super.key,
    this.classId,
    this.searchQuery = '',
  });

  final String? classId;
  final String searchQuery;

  @override
  State<LessenListWidget> createState() => _LessenListWidgetState();
}

class _LessenListWidgetState extends State<LessenListWidget> {
  @override
  void initState() {
    super.initState();
    _loadPlansIfNeeded();
  }

  @override
  void didUpdateWidget(covariant LessenListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.classId != widget.classId) _loadPlansIfNeeded();
  }

  void _loadPlansIfNeeded() {
    if (widget.classId != null && widget.classId!.isNotEmpty) {
      context.read<ActivityBloc>().add(
            LoadLearningPlansEvent(classId: widget.classId!),
          );
    }
  }

  /// Call to refresh list (e.g. after adding a new plan). Parent can use a new key to force rebuild.
  void refresh() => _loadPlansIfNeeded();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      buildWhen: (prev, curr) =>
          curr is LoadLearningPlansLoading ||
          curr is LoadLearningPlansSuccess ||
          curr is LoadLearningPlansFailure,
      builder: (context, state) {
        final query = widget.searchQuery.toLowerCase();
        List<LearningPlanEntity> plans = [];
        bool isLoading = true;
        String? error;

        if (widget.classId == null || widget.classId!.isEmpty) {
          isLoading = false;
        } else if (state is LoadLearningPlansLoading) {
          isLoading = true;
          error = null;
        } else if (state is LoadLearningPlansSuccess) {
          plans = state.plans;
          isLoading = false;
          error = null;
        } else if (state is LoadLearningPlansFailure) {
          plans = [];
          isLoading = false;
          error = state.message;
        }

        final filtered = query.isEmpty
            ? plans
            : plans.where((p) {
                return p.title.toLowerCase().contains(query) ||
                    p.categoryName.toLowerCase().contains(query) ||
                    (p.description?.toLowerCase().contains(query) ?? false);
              }).toList();

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadPlansIfNeeded,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (plans.isEmpty) {
          return Center(
            child: Text(
              'No learning plans yet. Create one with "New Lessen".',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'No lessens match "${widget.searchQuery}"',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }

        final cards = <Widget>[];
        for (final plan in filtered) {
          cards.add(
            LessonCardCollapseWidget(
              title: plan.title,
              date: plan.startDate,
              category: plan.categoryName,
              ageBand: plan.ageBandName,
              room: plan.roomName,
              onArrowTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessenScreen(plan: plan),
                  ),
                );
              },
            ),
          );
          cards.add(const SizedBox(height: 12));
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(children: cards),
          ),
        );
      },
    );
  }
}
