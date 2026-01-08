import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/core/pallete.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/features/activity/activity_detail_screen.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/messages/select_childs_screen.dart';

class HistoryMealScreen extends StatelessWidget {
  final String activityType;
  final String? classId;

  const HistoryMealScreen({
    super.key,
    required this.activityType,
    this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return _LessenPlanScreenView(activityType: activityType, classId: classId);
  }
}

class _LessenPlanScreenView extends StatefulWidget {
  final String activityType;
  final String? classId;

  const _LessenPlanScreenView({required this.activityType, this.classId});

  @override
  State<_LessenPlanScreenView> createState() => _LessenPlanScreenViewState();
}

class _ActivityHistoryItem {
  final String childId;
  final String? childPhoto;
  final String? contactId;
  final String? firstName;
  final String? lastName;
  final String activityDate;
  final String activityType;
  final String? quantity;
  final String? type; // meal_type, drink_type, etc.

  _ActivityHistoryItem({
    required this.childId,
    this.childPhoto,
    this.contactId,
    this.firstName,
    this.lastName,
    required this.activityDate,
    required this.activityType,
    this.quantity,
    this.type,
  });
}

class _LessenPlanScreenViewState extends State<_LessenPlanScreenView> {
  List<_ActivityHistoryItem> _historyItems = [];
  List<_ActivityHistoryItem> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadChildrenAndContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadChildrenAndContacts() {
    final childState = context.read<ChildBloc>().state;
    if (childState.children == null) {
      context.read<ChildBloc>().add(const GetAllChildrenEvent());
    }
    if (childState.contacts == null) {
      context.read<ChildBloc>().add(const GetAllContactsEvent());
    }
  }

  Future<void> _loadHistory() async {
    if (widget.classId == null || widget.classId!.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final activityTypeId = await _getActivityTypeId(widget.activityType);
      final response = await getIt<Dio>().get(
        '/items/activities',
        queryParameters: {
          'filter[activity_type_id][_eq]': activityTypeId,
          'filter[class_id][_eq]': widget.classId,
          'fields':
              'id,start_at,child_id.id,child_id.photo,child_id.contact_id.id,child_id.contact_id.first_name,child_id.contact_id.last_name',
          'sort': '-start_at',
        },
      );

      final activities = response.data['data'] as List<dynamic>;
      final List<_ActivityHistoryItem> items = [];

      for (final activity in activities) {
        final activityId = activity['id'] as String;
        final childId = activity['child_id']?['id'] as String?;
        final childPhoto = activity['child_id']?['photo'] as String?;
        final contactId = activity['child_id']?['contact_id']?['id'] as String?;
        final firstName =
            activity['child_id']?['contact_id']?['first_name'] as String?;
        final lastName =
            activity['child_id']?['contact_id']?['last_name'] as String?;
        final startAt = activity['start_at'] as String?;

        if (childId == null) continue;

        // Get activity details based on type
        final details = await _getActivityDetails(activityId);
        if (details != null) {
          items.add(
            _ActivityHistoryItem(
              childId: childId,
              childPhoto: childPhoto,
              contactId: contactId,
              firstName: firstName,
              lastName: lastName,
              activityDate: startAt ?? '',
              activityType: widget.activityType,
              quantity: details['quantity'],
              type: details['type'],
            ),
          );
        }
      }

      setState(() {
        _historyItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[HISTORY] Error loading history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getActivityTypeId(String type) async {
    final response = await getIt<Dio>().get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;
    for (final item in data) {
      if (item['type'] == type) {
        return item['id'] as String;
      }
    }
    throw Exception('Activity type not found: $type');
  }

  Future<Map<String, String?>?> _getActivityDetails(String activityId) async {
    try {
      String endpoint;
      String typeField;
      String? quantityField;

      switch (widget.activityType) {
        case 'meal':
          endpoint = '/items/activity_meals';
          typeField = 'meal_type';
          quantityField = 'quantity';
          break;
        case 'drink':
          endpoint = '/items/activity_drinks';
          typeField = 'drink_type';
          quantityField = 'quantity';
          break;
        case 'bathroom':
          endpoint = '/items/activity_bathroom';
          typeField = 'type';
          quantityField = null;
          break;
        case 'play':
          endpoint = '/items/activity_play';
          typeField = 'type';
          quantityField = null;
          break;
        case 'sleep':
          endpoint = '/items/activity_sleep';
          typeField = 'sleep_monitoring';
          quantityField = null;
          break;
        case 'accident':
        case 'incident':
          // These don't have simple type/quantity fields
          return {'type': widget.activityType, 'quantity': null};
        default:
          return null;
      }

      final response = await getIt<Dio>().get(
        endpoint,
        queryParameters: {
          'filter[activity_id][_eq]': activityId,
          'fields':
              'id,$typeField${quantityField != null ? ',$quantityField' : ''}',
          'limit': 1,
        },
      );

      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return null;

      final detail = data[0] as Map<String, dynamic>;
      return {
        'type': detail[typeField]?.toString(),
        'quantity': quantityField != null
            ? detail[quantityField]?.toString()
            : null,
      };
    } catch (e) {
      debugPrint('[HISTORY] Error getting activity details: $e');
      return null;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredItems = _historyItems;
      } else {
        _filteredItems = _historyItems.where((item) {
          final name = '${item.firstName ?? ''} ${item.lastName ?? ''}'
              .toLowerCase()
              .trim();
          return name.contains(_searchQuery);
        }).toList();
      }
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d', 'en_US').format(date);
    } catch (e) {
      return '';
    }
  }

  String _getChildName(_ActivityHistoryItem item) {
    final firstName = item.firstName ?? '';
    final lastName = item.lastName ?? '';
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Unknown' : name;
  }

  void _navigateToAddNew(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: widget.classId,
          activityType: widget.activityType,
        ),
      ),
    );
    // Reload history after returning
    _loadHistory();
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
                Text(
                  'History-${widget.activityType[0].toUpperCase()}${widget.activityType.substring(1)}',
                  style: const TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () => _navigateToAddNew(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Add New',
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
                      hintText: 'Search Child...',
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
                    onChanged: _onSearchChanged,
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'History Archive',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Palette.textForeground,
                                ),
                              ),
                              Text(
                                'Sort',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Palette.textForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _filteredItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'No history found',
                                    style: TextStyle(
                                      color: Palette.textForeground,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredItems[index];
                                    return HistoryMealCard(
                                      name: _getChildName(item),
                                      date: _formatDate(item.activityDate),
                                      type: item.type ?? '',
                                      quantity: item.quantity ?? '',
                                      photoId: item.childPhoto,
                                      childId: item.childId,
                                      activityDate: item.activityDate,
                                      activityType: widget.activityType,
                                      classId: widget.classId,
                                    );
                                  },
                                ),
                        ),
                      ],
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

class HistoryMealCard extends StatelessWidget {
  final String name;
  final String date;
  final String type;
  final String quantity;
  final String? photoId;
  final String childId;
  final String activityDate;
  final String activityType;
  final String? classId;

  const HistoryMealCard({
    super.key,
    required this.name,
    required this.date,
    required this.type,
    required this.quantity,
    this.photoId,
    required this.childId,
    required this.activityDate,
    required this.activityType,
    this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailScreen(
              childId: childId,
              childName: name,
              childPhoto: photoId,
              activityType: activityType,
              activityDate: activityDate,
              classId: classId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ChildAvatarWidget(photoId: photoId, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Palette.textForeground,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Palette.textForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (type.isNotEmpty) _InfoText(label: 'Type', value: type),
                if (type.isNotEmpty && quantity.isNotEmpty)
                  const SizedBox(width: 24),
                if (quantity.isNotEmpty)
                  _InfoText(label: 'Quantity', value: quantity),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Palette.txtPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
