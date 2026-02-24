import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/lessen.dart';
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
  List<LearningPlanItem> _plans = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void didUpdateWidget(covariant LessenListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.classId != widget.classId) _loadPlans();
  }

  /// Call to refresh list (e.g. after adding a new plan). Parent can use a new key to force rebuild.
  void refresh() => _loadPlans();

  Future<void> _loadPlans() async {
    if (widget.classId == null || widget.classId!.isEmpty) {
      if (mounted) setState(() {
        _isLoading = false;
        _plans = [];
        _error = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = GetIt.instance<LearningPlanApi>();
      final list = await api.getLearningPlans(widget.classId!);
      if (mounted) setState(() {
        _plans = list;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() {
        _plans = [];
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.searchQuery.toLowerCase();
    final filtered = query.isEmpty
        ? _plans
        : _plans.where((p) {
            return p.title.toLowerCase().contains(query) ||
                p.categoryName.toLowerCase().contains(query) ||
                (p.description?.toLowerCase().contains(query) ?? false);
          }).toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadPlans,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_plans.isEmpty) {
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
  }
}
