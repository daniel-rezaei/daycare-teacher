import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/core/palette.dart';
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

  // Cache for activity type IDs to avoid repeated API calls
  static final Map<String, String> _activityTypeIdCache = {};

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

  /// Get activity type ID with caching
  Future<String> _getActivityTypeId(String type) async {
    // Check cache first
    if (_activityTypeIdCache.containsKey(type)) {
      return _activityTypeIdCache[type]!;
    }

    try {
      final response = await getIt<Dio>().get('/items/activity_types');
      final data = response.data['data'] as List<dynamic>;

      for (final item in data) {
        final itemType = item['type'] as String?;
        final itemId = item['id'] as String?;
        if (itemType != null && itemId != null) {
          _activityTypeIdCache[itemType] = itemId;
        }
      }

      if (_activityTypeIdCache.containsKey(type)) {
        return _activityTypeIdCache[type]!;
      }

      throw Exception('Activity type not found: $type');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadHistory() async {
    if (widget.classId == null || widget.classId!.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _historyItems = [];
        _filteredItems = [];
      });
    }

    try {
      // Get activity type ID (cached)
      final activityTypeId = await _getActivityTypeId(widget.activityType);

      // Fetch all activities in one call
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

      if (activities.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Extract activity IDs for batch fetching
      final activityIds = activities
          .map((a) => a['id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      // Batch fetch all activity details in parallel
      final detailsMap = await _batchGetActivityDetails(activityIds);

      // Build items list
      final List<_ActivityHistoryItem> items = [];

      for (final activity in activities) {
        final activityId = activity['id'] as String?;
        if (activityId == null) continue;

        final childId = activity['child_id']?['id'] as String?;
        if (childId == null) continue;

        final details = detailsMap[activityId];
        if (details == null) {
          // Skip activities without details, but log for debugging
          continue;
        }

        final childPhoto = activity['child_id']?['photo'] as String?;
        final contactId = activity['child_id']?['contact_id']?['id'] as String?;
        final firstName =
            activity['child_id']?['contact_id']?['first_name'] as String?;
        final lastName =
            activity['child_id']?['contact_id']?['last_name'] as String?;
        final startAt = activity['start_at'] as String?;

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

      if (mounted) {
        setState(() {
          _historyItems = items;
          _filteredItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Batch fetch activity details for all activity IDs in parallel
  /// Uses parallel fetching with optimal batch size for best performance
  Future<Map<String, Map<String, String?>>> _batchGetActivityDetails(
    List<String> activityIds,
  ) async {
    if (activityIds.isEmpty) return {};

    // Get endpoint configuration
    final config = _getActivityDetailsConfig();
    if (config == null) return {};

    final String? endpoint = config['endpoint'] as String?;
    if (endpoint == null) {
      // For accident/incident, return simple type for all
      final Map<String, Map<String, String?>> result = {};
      for (final id in activityIds) {
        result[id] = {'type': widget.activityType, 'quantity': null};
      }
      return result;
    }

    final String typeField = config['typeField'] as String;
    final String? quantityField = config['quantityField'] as String?;
    final bool needsResolveId = config['needsResolveId'] as bool? ?? false;
    final String? resolveEndpoint = config['resolveEndpoint'] as String?;

    // Fetch all details in parallel batches for optimal performance
    // Using smaller batches to avoid overwhelming the server
    const batchSize = 20;
    final Map<String, Map<String, String?>> result = {};
    final Set<String> idsToResolve = {};

    // Process in batches
    for (int i = 0; i < activityIds.length; i += batchSize) {
      final batch = activityIds.skip(i).take(batchSize).toList();

      // Fetch all details in this batch in parallel
      final futures = batch.map((activityId) async {
        try {
          final response = await getIt<Dio>().get(
            endpoint,
            queryParameters: {
              'filter[activity_id][_eq]': activityId,
              'fields':
                  'id,activity_id,$typeField${quantityField != null ? ',$quantityField' : ''}',
              'limit': 1,
            },
          );

          final data = response.data['data'] as List<dynamic>;
          if (data.isEmpty) {
            return MapEntry<String, Map<String, String?>?>(activityId, null);
          }

          final detail = data[0] as Map<String, dynamic>;
          final typeValue = detail[typeField]?.toString();

          // Collect IDs that need resolution
          if (needsResolveId && typeValue != null && typeValue.isNotEmpty) {
            idsToResolve.add(typeValue);
          }

          return MapEntry(activityId, {
            'type': typeValue,
            'quantity': quantityField != null
                ? detail[quantityField]?.toString()
                : null,
            '_rawTypeValue': typeValue, // Store original for resolution
          });
        } catch (e) {
          return MapEntry<String, Map<String, String?>?>(activityId, null);
        }
      });

      final batchResults = await Future.wait(futures);
      for (final entry in batchResults) {
        if (entry.value != null) {
          result[entry.key] = entry.value!;
        }
      }
    }

    // Batch resolve IDs to names if needed
    if (needsResolveId && idsToResolve.isNotEmpty && resolveEndpoint != null) {
      try {
        // Fetch all names in parallel batches
        final Map<String, String> idToNameMap = {};

        final idsList = idsToResolve.toList();
        for (int i = 0; i < idsList.length; i += batchSize) {
          final batch = idsList.skip(i).take(batchSize).toList();

          final resolveFutures = batch.map((id) async {
            try {
              final resolveResponse = await getIt<Dio>().get(
                resolveEndpoint,
                queryParameters: {
                  'filter[id][_eq]': id,
                  'fields': 'id,name',
                  'limit': 1,
                },
              );

              final resolveData = resolveResponse.data['data'] as List<dynamic>;
              if (resolveData.isNotEmpty) {
                final name = resolveData[0]['name']?.toString();
                if (name != null) {
                  return MapEntry(id, name);
                }
              }
              return MapEntry<String, String?>(id, null);
            } catch (e) {
              return MapEntry<String, String?>(id, null);
            }
          });

          final resolveResults = await Future.wait(resolveFutures);
          for (final entry in resolveResults) {
            if (entry.value != null) {
              idToNameMap[entry.key] = entry.value!;
            }
          }
        }

        // Update details with resolved names
        for (final entry in result.entries) {
          final rawTypeValue = entry.value['_rawTypeValue'];
          if (rawTypeValue is String && idToNameMap.containsKey(rawTypeValue)) {
            entry.value['type'] = idToNameMap[rawTypeValue];
          }
          // Remove temporary field
          entry.value.remove('_rawTypeValue');
        }
      } catch (e) {
        // Remove temporary fields even on error
        for (final entry in result.entries) {
          entry.value.remove('_rawTypeValue');
        }
        // Continue with IDs if resolution fails
      }
    }

    return result;
  }

  /// Get configuration for activity details endpoint
  Map<String, dynamic>? _getActivityDetailsConfig() {
    switch (widget.activityType) {
      case 'meal':
        return {
          'endpoint': '/items/activity_meals',
          'typeField': 'meal_type',
          'quantityField': 'quantity',
          'needsResolveId': false,
        };
      case 'drink':
        return {
          'endpoint': '/items/activity_drinks',
          'typeField': 'type',
          'quantityField': 'quantity',
          'needsResolveId': false,
        };
      case 'bathroom':
        return {
          'endpoint': '/items/activity_bathroom',
          'typeField': 'type',
          'quantityField': null,
          'needsResolveId': false,
        };
      case 'play':
        return {
          'endpoint': '/items/activity_play',
          'typeField': 'type',
          'quantityField': null,
          'needsResolveId': false,
        };
      case 'sleep':
        return {
          'endpoint': '/items/activity_sleep',
          'typeField': 'sleep_monitoring',
          'quantityField': null,
          'needsResolveId': false,
        };
      case 'observation':
        return {
          'endpoint': '/items/Observation_Record',
          'typeField': 'category_id',
          'quantityField': null,
          'needsResolveId': true,
          'resolveEndpoint': '/items/observation_category',
        };
      case 'mood':
        return {
          'endpoint': '/items/activity_mood',
          'typeField': 'mood_id',
          'quantityField': null,
          'needsResolveId': true,
          'resolveEndpoint': '/items/mood',
        };
      case 'accident':
      case 'incident':
        // These don't have simple type/quantity fields
        return {
          'endpoint': null,
          'typeField': null,
          'quantityField': null,
          'needsResolveId': false,
        };
      default:
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
        builder: (context) => SelectChildrenScreen(
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
                                    return HistoryMealCardWidget(
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

class HistoryMealCardWidget extends StatelessWidget {
  final String name;
  final String date;
  final String type;
  final String quantity;
  final String? photoId;
  final String childId;
  final String activityDate;
  final String activityType;
  final String? classId;

  const HistoryMealCardWidget({
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
