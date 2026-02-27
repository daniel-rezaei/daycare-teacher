import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_new_lessen_bottom_sheet.dart';
import 'lessen_list.dart';

class LessenPlanScreen extends StatelessWidget {
  const LessenPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LessenPlanScreenView();
  }
}

class _LessenPlanScreenView extends StatefulWidget {
  const _LessenPlanScreenView();

  @override
  State<_LessenPlanScreenView> createState() => _LessenPlanScreenViewState();
}

class _LessenPlanScreenViewState extends State<_LessenPlanScreenView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _classId;

  @override
  void initState() {
    super.initState();
    _loadClassId();
  }

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(AppConstants.classIdKey);
    if (mounted) setState(() => _classId = id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _listRefreshKey = 0;

  void _openNewLessen() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const CreateNewLessenBottomSheet(),
    );
    // Only refresh list if a new lesson was really created
    if (mounted && (result == true)) {
      setState(() => _listRefreshKey++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE9DFFF), Color(0xFFF3EFFF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lessen Plan',
                  style: TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: _openNewLessen,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'New Lessen',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Palette.textForeground,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in All lessens...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.search),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.trim());
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: LessenListWidget(
                      key: ValueKey(_listRefreshKey),
                      classId: _classId,
                      searchQuery: _searchQuery,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
