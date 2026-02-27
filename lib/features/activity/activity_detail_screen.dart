import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/core/utils/photo_utils.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/widgets/staff_avatar_widget.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_bathroom_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_drinks_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_meals_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_play_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_sleep_api.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/day_strip_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String? childPhoto;
  final String activityType;
  final String activityDate; // ISO date string from activity
  final String? classId;
  /// When true (e.g. opened from history), the displayed date is fixed to the activity day and date navigation is disabled.
  final bool fromHistory;

  const ActivityDetailScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.childPhoto,
    required this.activityType,
    required this.activityDate,
    this.classId,
    this.fromHistory = false,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  List<_ActivityDetailItem> _activities = [];
  bool _isLoading = true;

  // API instances
  final ActivityMealsApi _mealsApi = GetIt.instance<ActivityMealsApi>();
  final ActivityDrinksApi _drinksApi = GetIt.instance<ActivityDrinksApi>();
  final ActivityBathroomApi _bathroomApi =
      GetIt.instance<ActivityBathroomApi>();
  final ActivityPlayApi _playApi = GetIt.instance<ActivityPlayApi>();
  final ActivitySleepApi _sleepApi = GetIt.instance<ActivitySleepApi>();

  // Options for each activity type
  List<String> _typeOptions = [];
  List<String> _quantityOptions = [];
  List<String> _subTypeOptions = [];

  @override
  void initState() {
    super.initState();
    // Parse activity date and set as selected date
    try {
      final parsedDate = DateTime.parse(widget.activityDate);
      _selectedDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );
    } catch (e) {
      _selectedDate = DateTime.now();
    }
    _loadActivitiesForDate(_selectedDate);
    _loadChildrenAndContacts();
    _loadAllOptions();
  }

  Future<void> _loadAllOptions() async {
    try {
      switch (widget.activityType) {
        case 'meal':
          final mealTypes = await _mealsApi.getMealTypes();
          final quantities = await _mealsApi.getQuantities();
          if (!mounted) return;
          setState(() {
            _typeOptions = mealTypes;
            _quantityOptions = quantities;
            _subTypeOptions = [];
          });
          break;
        case 'drink':
          final drinkTypes = await _drinksApi.getDrinkTypes();
          final quantities = await _drinksApi.getQuantities();
          if (!mounted) return;
          setState(() {
            _typeOptions = drinkTypes;
            _quantityOptions = quantities;
            _subTypeOptions = [];
          });
          break;
        case 'bathroom':
          final types = await _bathroomApi.getBathroomTypes();
          final subTypes = await _bathroomApi.getSubTypes();
          if (!mounted) return;
          setState(() {
            _typeOptions = types;
            _quantityOptions = [];
            _subTypeOptions = subTypes;
          });
          break;
        case 'play':
          final types = await _playApi.getPlayTypes();
          if (!mounted) return;
          setState(() {
            _typeOptions = types;
            _quantityOptions = [];
            _subTypeOptions = [];
          });
          break;
        case 'sleep':
          final types = await _sleepApi.getSleepTypes();
          if (!mounted) return;
          setState(() {
            _typeOptions = types;
            _quantityOptions = [];
            _subTypeOptions = [];
          });
          break;
        default:
          if (!mounted) return;
          setState(() {
            _typeOptions = [];
            _quantityOptions = [];
            _subTypeOptions = [];
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _typeOptions = [];
        _quantityOptions = [];
        _subTypeOptions = [];
      });
    }
  }

  void _loadChildrenAndContacts() {
    final childState = context.read<ChildBloc>().state;
    if (childState.children == null) {
      context.read<ChildBloc>().add(const GetAllChildrenEvent());
    }
    if (childState.contacts == null) {
      context.read<ChildBloc>().add(const GetAllContactsEvent());
    }
    final homeState = context.read<HomeBloc>().state;
    if (homeState.classRooms == null) {
      context.read<HomeBloc>().add(const LoadClassRoomsEvent());
    }
  }

  Future<void> _loadActivitiesForDate(DateTime date) async {
    print(
      '🟣 [_loadActivitiesForDate] Starting - Date: $date, Type: ${widget.activityType}, ChildId: ${widget.childId}',
    );
    if (widget.classId == null || widget.classId!.isEmpty) {
      print('🔴 [_loadActivitiesForDate] classId is null or empty');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

    try {
      // Handle accident and incident differently - query directly from their tables
      if (widget.activityType == 'accident') {
        print('🟣 [_loadActivitiesForDate] Calling _loadAccidentActivities');
        await _loadAccidentActivities(date);
        return;
      }
      if (widget.activityType == 'incident') {
        print('🟣 [_loadActivitiesForDate] Calling _loadIncidentActivities');
        await _loadIncidentActivities(date);
        return;
      }

      print(
        '🟣 [_loadActivitiesForDate] Getting activity type ID for: ${widget.activityType}',
      );
      final activityTypeId = await _getActivityTypeId(widget.activityType);
      print('🟣 [_loadActivitiesForDate] Activity type ID: $activityTypeId');
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

      print(
        '🟣 [_loadActivitiesForDate] Querying /items/activities with filters',
      );
      final response = await getIt<Dio>().get(
        '/items/activities',
        queryParameters: {
          'filter[activity_type_id][_eq]': activityTypeId,
          'filter[class_id][_eq]': widget.classId,
          'filter[child_id][_eq]': widget.childId,
          'filter[start_at][_gte]': dateStart.toUtc().toIso8601String(),
          'filter[start_at][_lt]': dateEnd.toUtc().toIso8601String(),
          'fields':
              'id,start_at,child_id.id,child_id.photo,child_id.contact_id.id,child_id.contact_id.first_name,child_id.contact_id.last_name',
          'sort': '-start_at',
        },
      );

      final activities = response.data['data'] as List<dynamic>;
      print(
        '🟣 [_loadActivitiesForDate] Found ${activities.length} activities',
      );
      final List<_ActivityDetailItem> items = [];

      for (final activity in activities) {
        final activityId = activity['id'] as String;
        final startAt = activity['start_at'] as String?;
        print(
          '🟣 [_loadActivitiesForDate] Processing activity: $activityId, startAt: $startAt',
        );

        // Get activity details based on type
        final details = await _getActivityDetails(activityId);
        print(
          '🟣 [_loadActivitiesForDate] Details received: ${details != null}',
        );
        if (details != null) {
          print(
            '🟣 [_loadActivitiesForDate] Details: type=${details['type']}, description=${details['description']}, tags=${details['tags']}',
          );

          // Convert observationFields to proper type (similar to accident/incident)
          Map<String, List<String>>? observationFieldsMap;
          if (details['observationFields'] != null) {
            final rawMap = details['observationFields'] as Map;
            observationFieldsMap = <String, List<String>>{};
            rawMap.forEach((key, value) {
              if (value is List) {
                observationFieldsMap![key.toString()] = value
                    .map<String>((e) => e.toString())
                    .toList();
              }
            });
            print(
              '🟣 [_loadActivitiesForDate] observationFieldsMap: $observationFieldsMap',
            );
          }

          print(
            '📷 [_loadActivitiesForDate] Adding item activityId=$activityId details["photo"]=${details['photo']}',
          );
          items.add(
            _ActivityDetailItem(
              activityId: activityId,
              startAt: startAt ?? '',
              type: details['type'],
              quantity: details['quantity'],
              description: details['description'],
              tags: details['tags'],
              photo: details['photo'],
              subType: details['subType'],
              startAtTime: details['startAtTime'],
              endAtTime: details['endAtTime'],
              observationFields: observationFieldsMap,
            ),
          );
        } else {
          print(
            '🔴 [_loadActivitiesForDate] Details is null for activityId: $activityId',
          );
        }
      }

      print('🟣 [_loadActivitiesForDate] Total items created: ${items.length}');
      for (var i = 0; i < items.length; i++) {
        print(
          '📷 [_loadActivitiesForDate] items[$i] activityId=${items[i].activityId} photo=${items[i].photo}',
        );
      }
      if (!mounted) return;
      setState(() {
        _activities = items;
        _isLoading = false;
      });
      print(
        '🟣 [_loadActivitiesForDate] State updated with ${_activities.length} activities',
      );
    } catch (e, stackTrace) {
      print('🔴 [_loadActivitiesForDate] Error: $e');
      print('🔴 [_loadActivitiesForDate] StackTrace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAccidentActivities(DateTime date) async {
    try {
      print(
        '🔵 [_loadAccidentActivities] Starting - Date: $date, ChildId: ${widget.childId}',
      );
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

      // Get all accident records; request contact_id expanded for Staff (name + photo)
      print('🔵 [_loadAccidentActivities] Fetching all accident records...');
      final response = await getIt<Dio>().get(
        '/items/Child_Accident_Report',
        queryParameters: {
          'fields':
              '*,contact_id.first_name,contact_id.last_name,contact_id.photo',
        },
      );

      var allData = response.data['data'] as List<dynamic>;
      print(
        '🔵 [_loadAccidentActivities] Total records received: ${allData.length}',
      );

      // Filter by child_id and date on client side
      final filteredData = allData.where((record) {
        final childId = record['child_id'] as String?;
        if (childId != widget.childId) return false;

        // Try filtering by date_time_notified first
        final dateTimeNotified = record['date_time_notified'] as String?;
        if (dateTimeNotified != null) {
          try {
            final recordDate = DateTime.parse(dateTimeNotified).toUtc();
            if (recordDate.isAfter(
                  dateStart.toUtc().subtract(const Duration(seconds: 1)),
                ) &&
                recordDate.isBefore(dateEnd.toUtc())) {
              return true;
            }
          } catch (e) {
            // If parsing fails, try date_created
          }
        }

        // Fallback to date_created
        final dateCreated = record['date_created'] as String?;
        if (dateCreated != null) {
          try {
            final recordDate = DateTime.parse(dateCreated).toUtc();
            if (recordDate.isAfter(
                  dateStart.toUtc().subtract(const Duration(seconds: 1)),
                ) &&
                recordDate.isBefore(dateEnd.toUtc())) {
              return true;
            }
          } catch (e) {
            return false;
          }
        }

        return false;
      }).toList();

      print(
        '🔵 [_loadAccidentActivities] Filtered records: ${filteredData.length}',
      );

      // Sort by date_time_notified or date_created (descending)
      filteredData.sort((a, b) {
        final dateA =
            a['date_time_notified'] as String? ??
            a['date_created'] as String? ??
            '';
        final dateB =
            b['date_time_notified'] as String? ??
            b['date_created'] as String? ??
            '';
        if (dateA.isEmpty) return 1;
        if (dateB.isEmpty) return -1;
        try {
          return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
        } catch (e) {
          return 0;
        }
      });

      final List<_ActivityDetailItem> items = [];

      for (final record in filteredData) {
        final recordId = record['id'];
        final dateTimeNotified = record['date_time_notified'] as String?;
        final dateCreated = record['date_created'] as String?;
        final activityId = record['activity_id'] as String?;

        print('🔵 [_loadAccidentActivities] Processing record: $recordId');

        // Get full accident details (will use the full record data)
        final details = await _getAccidentDetails(record);
        print(
          '🔵 [_loadAccidentActivities] Details received: ${details != null}',
        );
        if (details != null) {
          print(
            '🔵 [_loadAccidentActivities] accidentFields: ${details['accidentFields']}',
          );
          print(
            '🔵 [_loadAccidentActivities] accidentFields type: ${details['accidentFields'].runtimeType}',
          );
          // Convert accidentFields to proper type
          Map<String, List<String>>? accidentFieldsMap;
          if (details['accidentFields'] != null) {
            try {
              final rawMap = details['accidentFields'] as Map;
              print(
                '🔵 [_loadAccidentActivities] rawMap type: ${rawMap.runtimeType}',
              );
              accidentFieldsMap = <String, List<String>>{};
              rawMap.forEach((key, value) {
                print(
                  '🔵 [_loadAccidentActivities] Processing key: $key, value type: ${value.runtimeType}',
                );
                if (value is List) {
                  final stringList = value
                      .map<String>((e) => e.toString())
                      .toList();
                  print(
                    '🔵 [_loadAccidentActivities] stringList: $stringList, type: ${stringList.runtimeType}',
                  );
                  accidentFieldsMap![key.toString()] = stringList;
                }
              });
              print(
                '🔵 [_loadAccidentActivities] accidentFieldsMap after conversion: $accidentFieldsMap',
              );
            } catch (e) {
              print(
                '🔴 [_loadAccidentActivities] Error converting accidentFields: $e',
              );
            }
          }
          print(
            '🔵 [_loadAccidentActivities] accidentFieldsMap type: ${accidentFieldsMap.runtimeType}',
          );
          items.add(
            _ActivityDetailItem(
              activityId: activityId ?? recordId.toString(),
              startAt: dateTimeNotified ?? dateCreated ?? '',
              type: details['type'] as String?,
              quantity: details['quantity'] as String?,
              description: details['description'] as String?,
              tags:
                  (details['tags'] as List<dynamic>?)?.cast<String>() ??
                  <String>[],
              photo: details['photo'] as String?,
              subType: details['subType'] as String?,
              startAtTime: details['startAtTime'] as String?,
              endAtTime: details['endAtTime'] as String?,
              // Accident-specific fields
              accidentFields: accidentFieldsMap,
              accidentStaffInvolved:
                  (details['accidentStaffInvolved'] as List<Map<String, String?>>?),
            ),
          );
        }
      }

      print(
        '🔵 [_loadAccidentActivities] Total items created: ${items.length}',
      );
      print(
        '🔵 [_loadAccidentActivities] First item accidentFields: ${items.isNotEmpty ? items[0].accidentFields : null}',
      );

      if (!mounted) return;
      setState(() {
        _activities = items;
        _isLoading = false;
      });
      print(
        '🔵 [_loadAccidentActivities] State updated with ${_activities.length} activities',
      );
    } catch (e) {
      print('🔴 [_loadAccidentActivities] Error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadIncidentActivities(DateTime date) async {
    try {
      print(
        '🟢 [_loadIncidentActivities] Starting - Date: $date, ChildId: ${widget.childId}',
      );
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

      // Get all incident records; request contact_id expanded for Staff involved names
      print('🟢 [_loadIncidentActivities] Fetching all incident records...');
      final response = await getIt<Dio>().get(
        '/items/Child_Incident_Report',
        queryParameters: {
          'fields': '*,contact_id.first_name,contact_id.last_name',
        },
      );

      var allData = response.data['data'] as List<dynamic>;
      print(
        '🟢 [_loadIncidentActivities] Total records received: ${allData.length}',
      );

      // Filter by child_id and date on client side
      final filteredData = allData.where((record) {
        final childId = record['child_id'] as String?;
        if (childId != widget.childId) return false;

        final dateCreated = record['date_created'] as String?;
        if (dateCreated != null) {
          try {
            final recordDate = DateTime.parse(dateCreated).toUtc();
            if (recordDate.isAfter(
                  dateStart.toUtc().subtract(const Duration(seconds: 1)),
                ) &&
                recordDate.isBefore(dateEnd.toUtc())) {
              return true;
            }
          } catch (e) {
            return false;
          }
        }

        return false;
      }).toList();

      print(
        '🟢 [_loadIncidentActivities] Filtered records: ${filteredData.length}',
      );

      // Sort by date_created (descending)
      filteredData.sort((a, b) {
        final dateA = a['date_created'] as String? ?? '';
        final dateB = b['date_created'] as String? ?? '';
        if (dateA.isEmpty) return 1;
        if (dateB.isEmpty) return -1;
        try {
          return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
        } catch (e) {
          return 0;
        }
      });

      final List<_ActivityDetailItem> items = [];

      for (final record in filteredData) {
        final recordId = record['id'];
        final dateCreated = record['date_created'] as String?;
        final activityId = record['activity_id'] as String?;

        print('🟢 [_loadIncidentActivities] Processing record: $recordId');

        // Get full incident details (will use the full record data)
        final details = await _getIncidentDetails(record);
        print(
          '🟢 [_loadIncidentActivities] Details received: ${details != null}',
        );
        if (details != null) {
          print(
            '🟢 [_loadIncidentActivities] incidentFields: ${details['incidentFields']}',
          );
          // Convert incidentFields to proper type
          Map<String, List<String>>? incidentFieldsMap;
          if (details['incidentFields'] != null) {
            final rawMap = details['incidentFields'] as Map;
            incidentFieldsMap = <String, List<String>>{};
            rawMap.forEach((key, value) {
              if (value is List) {
                incidentFieldsMap![key.toString()] = value
                    .map<String>((e) => e.toString())
                    .toList();
              }
            });
          }
          print(
            '🟢 [_loadIncidentActivities] incidentFieldsMap type: ${incidentFieldsMap.runtimeType}',
          );
          items.add(
            _ActivityDetailItem(
              activityId: activityId ?? recordId.toString(),
              startAt: dateCreated ?? '',
              type: details['type'] as String?,
              quantity: details['quantity'] as String?,
              description: details['description'] as String?,
              tags:
                  (details['tags'] as List<dynamic>?)?.cast<String>() ??
                  <String>[],
              photo: details['photo'] as String?,
              subType: details['subType'] as String?,
              startAtTime: details['startAtTime'] as String?,
              endAtTime: details['endAtTime'] as String?,
              // Incident-specific fields
              incidentFields: incidentFieldsMap,
            ),
          );
        }
      }

      print(
        '🟢 [_loadIncidentActivities] Total items created: ${items.length}',
      );
      print(
        '🟢 [_loadIncidentActivities] First item incidentFields: ${items.isNotEmpty ? items[0].incidentFields : null}',
      );

      if (!mounted) return;
      setState(() {
        _activities = items;
        _isLoading = false;
      });
      print(
        '🟢 [_loadIncidentActivities] State updated with ${_activities.length} activities',
      );
    } catch (e) {
      print('🔴 [_loadIncidentActivities] Error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _getAccidentDetails(dynamic record) async {
    try {
      print('🟡 [_getAccidentDetails] Starting');
      // Use the record data directly (already fetched in _loadAccidentActivities)
      final detail = record is Map<String, dynamic> ? record : null;
      if (detail == null) {
        print('🟡 [_getAccidentDetails] Record is null or not a Map');
        return null;
      }
      print('🟡 [_getAccidentDetails] Record ID: ${detail['id']}');

      // Handle photo (Map, String, or List from M2M - junction or expanded file)
      String? photoId;
      if (detail['photo'] != null) {
        if (detail['photo'] is Map) {
          photoId = detail['photo']['id'] as String?;
        } else if (detail['photo'] is String) {
          photoId = detail['photo'] as String;
        } else if (detail['photo'] is List &&
            (detail['photo'] as List).isNotEmpty) {
          final photoList = detail['photo'] as List;
          final first = photoList[0];
          if (first is Map) {
            photoId =
                first['directus_files_id'] as String? ?? first['id'] as String?;
          } else if (first is String || first is int) {
            photoId = first.toString();
          }
        }
      }

      // Convert array fields to lists of strings
      List<String> convertArrayField(dynamic field) {
        if (field == null) return <String>[];
        if (field is List) {
          return field
              .map<String>((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        return <String>[];
      }

      // Format date/time for display
      String? formatDateTime(dynamic dateTime) {
        if (dateTime == null) return null;
        try {
          final dt = DateTime.parse(dateTime.toString());
          return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
        } catch (e) {
          return dateTime.toString();
        }
      }

      // Extract staff display names from contact_id (object, list, or raw ID)
      List<String> staffDisplayFromContactId(dynamic contactId) {
        if (contactId == null) return <String>[];
        if (contactId is Map) {
          final first = (contactId['first_name']?.toString().trim() ?? '')
              .toString();
          final last = (contactId['last_name']?.toString().trim() ?? '')
              .toString();
          final name = '$first $last'.trim();
          return name.isEmpty ? <String>[] : [name];
        }
        if (contactId is List) {
          final list = <String>[];
          for (final e in contactId) {
            if (e is Map) {
              final first = (e['first_name']?.toString().trim() ?? '')
                  .toString();
              final last = (e['last_name']?.toString().trim() ?? '').toString();
              final name = '$first $last'.trim();
              if (name.isNotEmpty) list.add(name);
            } else if (e != null && e.toString().trim().isNotEmpty) {
              list.add(e.toString().trim());
            }
          }
          return list;
        }
        final s = contactId.toString().trim();
        return s.isEmpty ? <String>[] : [s];
      }

      // Extract staff with name and photo from contact_id for display
      List<Map<String, String?>> _staffDetailsFromContactId(dynamic contactId) {
        if (contactId == null) return [];
        String? photoIdFrom(dynamic photo) {
          if (photo == null) return null;
          if (photo is String && photo.trim().isNotEmpty) return photo.trim();
          if (photo is Map) {
            final id = photo['id'];
            return id?.toString().trim();
          }
          return null;
        }
        if (contactId is Map) {
          final first = (contactId['first_name']?.toString().trim() ?? '').toString();
          final last = (contactId['last_name']?.toString().trim() ?? '').toString();
          final name = '$first $last'.trim();
          final photo = photoIdFrom(contactId['photo']);
          return [{'name': name.isEmpty ? null : name, 'photoId': photo}];
        }
        if (contactId is List) {
          final list = <Map<String, String?>>[];
          for (final e in contactId) {
            if (e is Map) {
              final first = (e['first_name']?.toString().trim() ?? '').toString();
              final last = (e['last_name']?.toString().trim() ?? '').toString();
              final name = '$first $last'.trim();
              final photo = photoIdFrom(e['photo']);
              list.add({'name': name.isEmpty ? null : name, 'photoId': photo});
            }
          }
          return list;
        }
        return [];
      }

      // Store accident fields separately with their titles
      final natureOfInjury = convertArrayField(detail['nature_of_injury']);
      final injuredBodyType = convertArrayField(detail['injured_body_type']);
      final location = convertArrayField(detail['location']);
      final firstAidProvided = convertArrayField(detail['first_aid_provided']);
      final childReaction = convertArrayField(detail['child_reaction']);
      final notifyBy = convertArrayField(detail['notify_by']);

      print('🟡 [_getAccidentDetails] nature_of_injury: $natureOfInjury');
      print('🟡 [_getAccidentDetails] injured_body_type: $injuredBodyType');
      print('🟡 [_getAccidentDetails] location: $location');
      print('🟡 [_getAccidentDetails] first_aid_provided: $firstAidProvided');
      print('🟡 [_getAccidentDetails] child_reaction: $childReaction');
      print('🟡 [_getAccidentDetails] notify_by: $notifyBy');

      // Staff involved (names for chips; full details with photo for UI)
      final staffInvolved = staffDisplayFromContactId(detail['contact_id']);
      final staffDetails = _staffDetailsFromContactId(detail['contact_id']);
      final dateNotified = detail['date_time_notified'];
      final dateNotifiedStr = dateNotified != null && dateNotified.toString().trim().isNotEmpty
          ? (formatDateTime(dateNotified) ?? dateNotified.toString())
          : null;
      final medicalFollowUp = detail['medical_follow_up_required'];
      final reportedToAuthority = detail['incident_reported_to_authority'];
      final parentNotified = detail['parent_notified'];

      // All accident fields in fixed order with form labels; always present for consistent display
      final accidentFields = <String, List<String>>{
        'Nature of Injury': natureOfInjury.isNotEmpty ? natureOfInjury : ['—'],
        'Injured Body Part': injuredBodyType.isNotEmpty ? injuredBodyType : ['—'],
        'Location': location.isNotEmpty ? location : ['—'],
        'First Aid Provided': firstAidProvided.isNotEmpty ? firstAidProvided : ['—'],
        "Child's Reaction": childReaction.isNotEmpty ? childReaction : ['—'],
        'Staff Involved': staffInvolved.isNotEmpty ? staffInvolved : ['—'],
        'Date Notified': dateNotifiedStr != null ? [dateNotifiedStr] : ['—'],
        'Medical Follow-Up required': [
          medicalFollowUp == true ? 'Yes' : (medicalFollowUp == false ? 'No' : '—'),
        ],
        'Incident Reported to Authority': [
          reportedToAuthority == true ? 'Yes' : (reportedToAuthority == false ? 'No' : '—'),
        ],
        'Parent Notified': [
          parentNotified == true ? 'Yes' : (parentNotified == false ? 'No' : '—'),
        ],
        'How to Notify': notifyBy.isNotEmpty ? notifyBy : ['—'],
      };

      print('🟡 [_getAccidentDetails] accidentFields map: $accidentFields');
      print(
        '🟡 [_getAccidentDetails] accidentFields isEmpty: ${accidentFields.isEmpty}',
      );
      print(
        '🟡 [_getAccidentDetails] accidentFields entries: ${accidentFields.entries.length}',
      );

      final result = <String, dynamic>{
        'type': null,
        'quantity': null,
        'subType': null,
        'description': detail['description']?.toString(),
        'tags':
            <
              String
            >[], // Empty tags for accidents - we use accidentFields instead
        'photo': photoId,
        'startAtTime': null,
        'endAtTime': null,
        'accidentFields': accidentFields,
        'accidentStaffInvolved': staffDetails,
      };

      print(
        '🟡 [_getAccidentDetails] Returning result with accidentFields: ${result['accidentFields']}',
      );
      print(
        '🟡 [_getAccidentDetails] accidentFields runtimeType: ${(result['accidentFields'] as Map).runtimeType}',
      );
      return result;
    } catch (e) {
      print('🔴 [_getAccidentDetails] Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getIncidentDetails(dynamic record) async {
    try {
      print('🟠 [_getIncidentDetails] Starting');
      // Use the record data directly (already fetched in _loadIncidentActivities)
      final detail = record is Map<String, dynamic> ? record : null;
      if (detail == null) {
        print('🟠 [_getIncidentDetails] Record is null or not a Map');
        return null;
      }
      print('🟠 [_getIncidentDetails] Record ID: ${detail['id']}');

      // Handle photo (Map, String, or List from M2M - junction or expanded file)
      String? photoId;
      if (detail['photo'] != null) {
        if (detail['photo'] is Map) {
          photoId = detail['photo']['id'] as String?;
        } else if (detail['photo'] is String) {
          photoId = detail['photo'] as String;
        } else if (detail['photo'] is List &&
            (detail['photo'] as List).isNotEmpty) {
          final photoList = detail['photo'] as List;
          final first = photoList[0];
          if (first is Map) {
            photoId =
                first['directus_files_id'] as String? ?? first['id'] as String?;
          } else if (first is String || first is int) {
            photoId = first.toString();
          }
        }
      }

      // Convert array fields to lists of strings
      List<String> convertArrayField(dynamic field) {
        if (field == null) return <String>[];
        if (field is List) {
          return field
              .map<String>((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        return <String>[];
      }

      // Format date time for display
      String? formatDateTime(dynamic dateTime) {
        if (dateTime == null) return null;
        try {
          final dt = DateTime.parse(dateTime.toString());
          return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
        } catch (e) {
          return dateTime.toString();
        }
      }

      // Extract staff display names from contact_id (object, list, or raw ID)
      List<String> staffDisplayFromContactId(dynamic contactId) {
        if (contactId == null) return <String>[];
        if (contactId is Map) {
          final first = (contactId['first_name']?.toString().trim() ?? '')
              .toString();
          final last = (contactId['last_name']?.toString().trim() ?? '')
              .toString();
          final name = '$first $last'.trim();
          return name.isEmpty ? <String>[] : [name];
        }
        if (contactId is List) {
          final list = <String>[];
          for (final e in contactId) {
            if (e is Map) {
              final first = (e['first_name']?.toString().trim() ?? '')
                  .toString();
              final last = (e['last_name']?.toString().trim() ?? '').toString();
              final name = '$first $last'.trim();
              if (name.isNotEmpty) list.add(name);
            } else if (e != null && e.toString().trim().isNotEmpty) {
              list.add(e.toString().trim());
            }
          }
          return list;
        }
        final s = contactId.toString().trim();
        return s.isEmpty ? <String>[] : [s];
      }

      // Store incident fields separately with their titles
      final incidentFields = <String, List<String>>{};

      // Staff involved
      final staffInvolved = staffDisplayFromContactId(detail['contact_id']);
      if (staffInvolved.isNotEmpty) {
        incidentFields['Staff involved'] = staffInvolved;
      }

      // Add array fields
      final natureOfIncident = convertArrayField(detail['nature_of_incident']);
      if (natureOfIncident.isNotEmpty) {
        incidentFields['Nature of Incident'] = natureOfIncident;
      }

      final location = convertArrayField(detail['location']);
      if (location.isNotEmpty) {
        incidentFields['Location'] = location;
      }

      final notifyParentBy = convertArrayField(detail['notify_parent_by']);
      if (notifyParentBy.isNotEmpty) {
        final dateTime = formatDateTime(detail['notify_parent_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Parent By'] = [
            ...notifyParentBy,
            'Date: $dateTime',
          ];
        } else {
          incidentFields['Notify Parent By'] = notifyParentBy;
        }
      } else if (detail['notify_parent_date_time'] != null) {
        final dateTime = formatDateTime(detail['notify_parent_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Parent'] = ['Date: $dateTime'];
        }
      }

      final notifyMinistryBy = convertArrayField(detail['notify_ministry_by']);
      if (notifyMinistryBy.isNotEmpty) {
        final dateTime = formatDateTime(detail['notify_ministry_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Ministry By'] = [
            ...notifyMinistryBy,
            'Date: $dateTime',
          ];
        } else {
          incidentFields['Notify Ministry By'] = notifyMinistryBy;
        }
      } else if (detail['notify_ministry_date_time'] != null) {
        final dateTime = formatDateTime(detail['notify_ministry_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Ministry'] = ['Date: $dateTime'];
        }
      }

      final notifySupervisorBy = convertArrayField(
        detail['notify_supervisor_by'],
      );
      if (notifySupervisorBy.isNotEmpty) {
        final dateTime = formatDateTime(detail['notify_supervisor_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Supervisor By'] = [
            ...notifySupervisorBy,
            'Date: $dateTime',
          ];
        } else {
          incidentFields['Notify Supervisor By'] = notifySupervisorBy;
        }
      } else if (detail['notify_supervisor_date_time'] != null) {
        final dateTime = formatDateTime(detail['notify_supervisor_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Supervisor'] = ['Date: $dateTime'];
        }
      }

      final notifyCasBy = convertArrayField(detail['notify_cas_by']);
      if (notifyCasBy.isNotEmpty) {
        final dateTime = formatDateTime(detail['notify_cas_date_time']);
        if (dateTime != null) {
          incidentFields['Notify CAS By'] = [...notifyCasBy, 'Date: $dateTime'];
        } else {
          incidentFields['Notify CAS By'] = notifyCasBy;
        }
      } else if (detail['notify_cas_date_time'] != null) {
        final dateTime = formatDateTime(detail['notify_cas_date_time']);
        if (dateTime != null) {
          incidentFields['Notify CAS'] = ['Date: $dateTime'];
        }
      }

      final notifyPoliceBy = convertArrayField(detail['notify_police_by']);
      if (notifyPoliceBy.isNotEmpty) {
        final dateTime = formatDateTime(detail['notify_police_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Police By'] = [
            ...notifyPoliceBy,
            'Date: $dateTime',
          ];
        } else {
          incidentFields['Notify Police By'] = notifyPoliceBy;
        }
      } else if (detail['notify_police_date_time'] != null) {
        final dateTime = formatDateTime(detail['notify_police_date_time']);
        if (dateTime != null) {
          incidentFields['Notify Police'] = ['Date: $dateTime'];
        }
      }

      print('🟠 [_getIncidentDetails] incidentFields map: $incidentFields');
      print(
        '🟠 [_getIncidentDetails] incidentFields isEmpty: ${incidentFields.isEmpty}',
      );
      print(
        '🟠 [_getIncidentDetails] incidentFields entries: ${incidentFields.entries.length}',
      );

      final result = <String, dynamic>{
        'type': null,
        'quantity': null,
        'subType': null,
        'description': detail['description']?.toString(),
        'tags':
            <
              String
            >[], // Empty tags for incidents - we use incidentFields instead
        'photo': photoId,
        'startAtTime': null,
        'endAtTime': null,
        'incidentFields': incidentFields,
      };

      print(
        '🟠 [_getIncidentDetails] Returning result with incidentFields: ${result['incidentFields']}',
      );
      print(
        '🟠 [_getIncidentDetails] incidentFields runtimeType: ${(result['incidentFields'] as Map).runtimeType}',
      );
      return result;
    } catch (e) {
      print('🔴 [_getIncidentDetails] Error: $e');
      return null;
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

  Future<Map<String, dynamic>?> _getActivityDetails(String activityId) async {
    try {
      print(
        '🟣 [_getActivityDetails] Starting for activityId: $activityId, type: ${widget.activityType}',
      );
      String endpoint;
      String? typeField;
      String? quantityField;
      String? subTypeField;
      bool hasTimeFields = false;
      bool needsResolveId = false;
      String? resolveEndpoint;

      switch (widget.activityType) {
        case 'meal':
          endpoint = '/items/activity_meals';
          typeField = 'meal_type';
          quantityField = 'quantity';
          subTypeField = null;
          hasTimeFields = false;
          break;
        case 'drink':
          endpoint = '/items/activity_drinks';
          typeField = 'type';
          quantityField = 'quantity';
          subTypeField = null;
          hasTimeFields = false;
          break;
        case 'bathroom':
          endpoint = '/items/activity_bathroom';
          typeField = 'type';
          quantityField = null;
          subTypeField = 'sub_type';
          hasTimeFields = false;
          break;
        case 'play':
          endpoint = '/items/activity_play';
          typeField = 'type';
          quantityField = null;
          subTypeField = null;
          hasTimeFields = true;
          break;
        case 'sleep':
          endpoint = '/items/activity_sleep';
          typeField = 'sleep_monitoring';
          quantityField = null;
          subTypeField = null;
          hasTimeFields = true;
          break;
        case 'observation':
          endpoint = '/items/Observation_Record';
          typeField = 'category_id';
          quantityField = null;
          subTypeField = null;
          hasTimeFields = false;
          needsResolveId = true;
          resolveEndpoint = '/items/observation_category';
          print(
            '🟣 [_getActivityDetails] Observation case - needsResolveId: true',
          );
          break;
        case 'mood':
          endpoint = '/items/activity_mood';
          typeField = 'mood_id';
          quantityField = null;
          subTypeField = null;
          hasTimeFields = false;
          needsResolveId = true;
          resolveEndpoint = '/items/mood';
          break;
        case 'accident':
          endpoint = '/items/Child_Accident_Report';
          typeField = null;
          quantityField = null;
          subTypeField = null;
          hasTimeFields = false;
          break;
        case 'incident':
          endpoint = '/items/Child_Incident_Report';
          typeField = null;
          quantityField = null;
          subTypeField = null;
          hasTimeFields = false;
          break;
        default:
          print(
            '🔴 [_getActivityDetails] Unknown activity type: ${widget.activityType}',
          );
          return null;
      }

      print(
        '🟣 [_getActivityDetails] Endpoint: $endpoint, typeField: $typeField',
      );

      final fields = <String>['id'];
      if (typeField != null) fields.add(typeField);
      if (quantityField != null) fields.add(quantityField);
      if (subTypeField != null) fields.add(subTypeField);
      if (hasTimeFields) {
        fields.add('start_at');
        fields.add('end_at');
      }
      fields.add('description');
      fields.add('tag');
      // Request nested directus_files_id so we get actual file ID (not junction row ID)
      final isPhotoM2M =
          widget.activityType == 'meal' ||
          widget.activityType == 'drink' ||
          widget.activityType == 'bathroom' ||
          widget.activityType == 'play' ||
          widget.activityType == 'mood';
      if (isPhotoM2M) {
        fields.add('photo.directus_files_id');
      } else {
        fields.add('photo');
      }

      // For observation, also fetch skill_observed and activity_id (needed for filtering)
      if (widget.activityType == 'observation') {
        fields.add('skill_observed');
        fields.add('activity_id'); // Needed for client-side filtering
      }

      print('🟣 [_getActivityDetails] Fields: ${fields.join(',')}');
      print(
        '🟣 [_getActivityDetails] Querying endpoint: $endpoint with activityId: $activityId',
      );

      // For observation, try fetching all records first (like accident/incident)
      // because query parameters might cause 403 error
      final response = widget.activityType == 'observation'
          ? await getIt<Dio>().get(endpoint)
          : await getIt<Dio>().get(
              endpoint,
              queryParameters: {
                'filter[activity_id][_eq]': activityId,
                'fields': fields.join(','),
                'limit': 1,
              },
            );

      print('🟣 [_getActivityDetails] Response received');
      var data = response.data['data'] as List<dynamic>;
      print('🟣 [_getActivityDetails] Data length: ${data.length}');

      // For observation, filter by activity_id on client side
      if (widget.activityType == 'observation') {
        print(
          '🟣 [_getActivityDetails] Filtering observation records by activity_id: $activityId',
        );
        data = data.where((record) {
          final recordActivityId = record['activity_id']?.toString();
          print(
            '🟣 [_getActivityDetails] Comparing: $recordActivityId == $activityId',
          );
          return recordActivityId == activityId;
        }).toList();
        print('🟣 [_getActivityDetails] Filtered data length: ${data.length}');
      }

      if (data.isEmpty) {
        print(
          '🔴 [_getActivityDetails] No data found for activityId: $activityId',
        );
        return null;
      }

      final detail = data[0] as Map<String, dynamic>;
      print('🟣 [_getActivityDetails] Detail keys: ${detail.keys.toList()}');

      // DEBUG: raw photo from API
      final rawPhoto = detail['photo'];
      print(
        '📷 [_getActivityDetails] activityType=${widget.activityType} activityId=$activityId',
      );
      print(
        '📷 [_getActivityDetails] raw photo: $rawPhoto (runtimeType: ${rawPhoto?.runtimeType})',
      );
      if (rawPhoto is List && rawPhoto.isNotEmpty) {
        final first = rawPhoto[0];
        print(
          '📷 [_getActivityDetails] photo list[0]: $first (runtimeType: ${first.runtimeType})',
        );
      } else if (rawPhoto is Map) {
        print(
          '📷 [_getActivityDetails] photo map keys: ${rawPhoto.keys.toList()}',
        );
      }

      // Handle photo - could be nested (Map, String, or List from M2M relation)
      String? photoId;
      if (detail['photo'] != null) {
        if (detail['photo'] is Map) {
          final photoMap = detail['photo'] as Map;
          photoId =
              photoMap['id'] as String? ??
              photoMap['directus_files_id']?.toString();
          print(
            '📷 [_getActivityDetails] photo parsed from Map -> photoId: $photoId',
          );
        } else if (detail['photo'] is String) {
          photoId = detail['photo'] as String;
          print(
            '📷 [_getActivityDetails] photo parsed from String -> photoId: $photoId',
          );
        } else if (detail['photo'] is List &&
            (detail['photo'] as List).isNotEmpty) {
          final photoList = detail['photo'] as List;
          final first = photoList[0];
          if (first is Map) {
            // directus_files_id = junction row; id = expanded file record (may be int or String)
            final fd = first['directus_files_id'];
            final fid = first['id'];
            photoId = fd?.toString() ?? fid?.toString();
            print(
              '📷 [_getActivityDetails] photo parsed from List[Map] -> photoId: $photoId',
            );
          } else if (first is String || first is int) {
            // Directus can return list of IDs as primitives: [11] or ["uuid"]
            photoId = first.toString();
            print(
              '📷 [_getActivityDetails] photo parsed from List[int/String] -> photoId: $photoId',
            );
          } else {
            print(
              '📷 [_getActivityDetails] photo is List but first element type not handled: ${first.runtimeType}',
            );
          }
        } else {
          print(
            '📷 [_getActivityDetails] photo not Map/String/List, skipping. type=${detail['photo'].runtimeType}',
          );
        }
      } else {
        print('📷 [_getActivityDetails] detail["photo"] is null');
      }
      print('📷 [_getActivityDetails] final photoId for item: $photoId');

      // Handle tags - parse and clean up brackets and quotes
      List<String> tags = [];
      if (detail['tag'] != null) {
        if (detail['tag'] is List) {
          tags = (detail['tag'] as List).map((e) {
            String tag = e.toString();
            // Remove brackets and quotes if present
            tag = tag.replaceAll('[', '').replaceAll(']', '');
            tag = tag.replaceAll('"', '').replaceAll("'", '');
            return tag.trim();
          }).toList();
        } else if (detail['tag'] is String) {
          String tag = detail['tag'] as String;
          // Try to parse if it's a JSON-like string
          if (tag.startsWith('[') && tag.endsWith(']')) {
            try {
              // Remove brackets and parse
              tag = tag.substring(1, tag.length - 1);
              // Remove quotes
              tag = tag.replaceAll('"', '').replaceAll("'", '');
              tags = tag
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            } catch (e) {
              // If parsing fails, use as is after cleaning
              tag = tag.replaceAll('[', '').replaceAll(']', '');
              tag = tag.replaceAll('"', '').replaceAll("'", '');
              tags = [tag.trim()];
            }
          } else {
            // Remove quotes if present
            tag = tag.replaceAll('"', '').replaceAll("'", '');
            tags = [tag.trim()];
          }
        }
      }

      // Resolve type ID to name for types that need it (observation, mood)
      String? resolvedType;
      if (needsResolveId && typeField != null && detail[typeField] != null) {
        final typeId = detail[typeField].toString();
        print(
          '🟣 [_getActivityDetails] Resolving type id: $typeId (${widget.activityType})',
        );
        try {
          if (resolveEndpoint != null) {
            final resolveResponse = await getIt<Dio>().get(
              resolveEndpoint,
              queryParameters: {
                'filter[id][_eq]': typeId,
                'fields': 'id,name',
                'limit': 1,
              },
            );
            final resolveData = resolveResponse.data['data'] as List<dynamic>;
            if (resolveData.isNotEmpty) {
              resolvedType = resolveData[0]['name']?.toString();
              print('🟣 [_getActivityDetails] Resolved name: $resolvedType');
            } else {
              resolvedType = typeId; // Fallback to ID
            }
          }
        } catch (e) {
          print('🔴 [_getActivityDetails] Error resolving type: $e');
          resolvedType = typeId; // Fallback to ID
        }
      }

      // Handle observation-specific fields
      List<String> skillObserved = [];
      if (widget.activityType == 'observation') {
        print(
          '🟣 [_getActivityDetails] Processing observation-specific fields',
        );

        // Handle skill_observed array
        if (detail['skill_observed'] != null) {
          if (detail['skill_observed'] is List) {
            skillObserved = (detail['skill_observed'] as List)
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList();
            print('🟣 [_getActivityDetails] skill_observed: $skillObserved');
          } else if (detail['skill_observed'] is String) {
            final skillStr = detail['skill_observed'] as String;
            skillObserved = [skillStr.trim()];
            print(
              '🟣 [_getActivityDetails] skill_observed (string): $skillObserved',
            );
          }
        }

        // Create observationFields map (similar to accidentFields and incidentFields)
        final observationFields = <String, List<String>>{};

        // Add Category
        if (resolvedType != null && resolvedType.isNotEmpty) {
          observationFields['Category'] = [resolvedType];
        }

        // Add Development Area (skill_observed)
        if (skillObserved.isNotEmpty) {
          observationFields['Development Area'] = skillObserved;
        }

        print('🟣 [_getActivityDetails] observationFields: $observationFields');

        final result = {
          'type':
              resolvedType ??
              (typeField != null ? detail[typeField]?.toString() : null),
          'quantity': quantityField != null
              ? detail[quantityField]?.toString()
              : null,
          'subType': subTypeField != null
              ? detail[subTypeField]?.toString()
              : null,
          'description': detail['description']?.toString(),
          'tags':
              tags, // Keep tags empty for observation - we use observationFields instead
          'photo': photoId,
          'startAtTime': hasTimeFields ? detail['start_at']?.toString() : null,
          'endAtTime': hasTimeFields ? detail['end_at']?.toString() : null,
          'observationFields': observationFields,
        };

        print(
          '🟣 [_getActivityDetails] Returning result with observationFields: ${result['observationFields']}',
        );
        return result;
      }

      final result = {
        'type':
            resolvedType ??
            (typeField != null ? detail[typeField]?.toString() : null),
        'quantity': quantityField != null
            ? detail[quantityField]?.toString()
            : null,
        'subType': subTypeField != null
            ? detail[subTypeField]?.toString()
            : null,
        'description': detail['description']?.toString(),
        'tags': tags,
        'photo': photoId,
        'startAtTime': hasTimeFields ? detail['start_at']?.toString() : null,
        'endAtTime': hasTimeFields ? detail['end_at']?.toString() : null,
      };

      print(
        '🟣 [_getActivityDetails] Returning result: type=${result['type']}, tags=${result['tags']}, description=${result['description']}',
      );
      return result;
    } catch (e, stackTrace) {
      print('🔴 [_getActivityDetails] Error: $e');
      print('🔴 [_getActivityDetails] StackTrace: $stackTrace');
      return null;
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadActivitiesForDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              children: [
                BackTitleWidget(
                  title:
                      'History-${widget.activityType[0].toUpperCase()}${widget.activityType.substring(1)}',
                  onTap: () => Navigator.pop(context),
                ),
                _ProfileSection(
                  childName: widget.childName,
                  childPhoto: widget.childPhoto,
                  classId: widget.classId,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFFFF).withValues(alpha: .4),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -4),
                          blurRadius: 16,
                          color: const Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DayStripWidget(
                          // وقتی از history باز می‌شود، فقط تاریخ اولیه را ست می‌کنیم
                          // اما readOnly=false می‌ماند تا کاربر بتواند روزهای دیگر را هم انتخاب کند.
                          initialDate:
                              widget.fromHistory ? _selectedDate : null,
                          readOnly: false,
                          onDateSelected: _onDateSelected,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xffFFFFFF),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                            child: _isLoading
                                ? const Center(
                                    child: CupertinoActivityIndicator(
                                      radius: 12,
                                    ),
                                  )
                                : _activities.isEmpty
                                ? Center(
                                    child: Text(
                                      'No activities found for this date',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _activities.length,
                                    itemBuilder: (context, index) {
                                      final activity = _activities[index];
                                      return _ActivityDetailSection(
                                        activity: activity,
                                        activityType: widget.activityType,
                                        typeOptions: _typeOptions,
                                        quantityOptions: _quantityOptions,
                                        subTypeOptions: _subTypeOptions,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDetailItem {
  final String activityId;
  final String startAt;
  final String? type;
  final String? quantity;
  final String? description;
  final List<String> tags;
  final String? photo;
  final String? subType;
  final String? startAtTime;
  final String? endAtTime;
  final Map<String, List<String>>?
  accidentFields; // For accident-specific fields
  /// Staff involved with name and photoId for accident detail (from contact_id)
  final List<Map<String, String?>>? accidentStaffInvolved;
  final Map<String, List<String>>?
  incidentFields; // For incident-specific fields
  final Map<String, List<String>>?
  observationFields; // For observation-specific fields

  _ActivityDetailItem({
    required this.activityId,
    required this.startAt,
    this.type,
    this.quantity,
    this.description,
    required this.tags,
    this.photo,
    this.subType,
    this.startAtTime,
    this.endAtTime,
    this.accidentFields,
    this.accidentStaffInvolved,
    this.incidentFields,
    this.observationFields,
  });
}

class _ProfileSection extends StatelessWidget {
  final String childName;
  final String? childPhoto;
  final String? classId;

  const _ProfileSection({
    required this.childName,
    this.childPhoto,
    this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        String? className;
        if (classId != null && homeState.classRooms != null) {
          try {
            final classRoom = homeState.classRooms!.firstWhere(
              (room) => room.id == classId,
            );
            className = classRoom.roomName;
          } catch (e) {
            className = null;
          }
        }

        return Row(
          children: [
            Container(
              height: 68,
              width: 68,
              margin: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: childPhoto != null && childPhoto!.isNotEmpty
                  ? ChildAvatarWidget(photoId: childPhoto, size: 68)
                  : Assets.images.image.image(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGray,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      width: 2,
                      color: AppColors.backgroundBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: AppColors.shadowPurple.withValues(alpha: .5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Assets.images.leftSlotItems.svg(),
                      const SizedBox(width: 8),
                      Text(
                        className ?? 'Not available',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
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
        );
      },
    );
  }
}

class _ActivityDetailSection extends StatelessWidget {
  final _ActivityDetailItem activity;
  final String activityType;
  final List<String> typeOptions;
  final List<String> quantityOptions;
  final List<String> subTypeOptions;

  const _ActivityDetailSection({
    required this.activity,
    required this.activityType,
    required this.typeOptions,
    required this.quantityOptions,
    required this.subTypeOptions,
  });

  String _getTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final dateTimeUtc = DateTime.parse(dateTimeStr);
      final dateTimeLocal = dateTimeUtc.toLocal();
      return DateFormat('hh:mm').format(dateTimeLocal);
    } catch (e) {
      return '';
    }
  }

  String _getAmPm(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'AM';
    try {
      final dateTimeUtc = DateTime.parse(dateTimeStr);
      final dateTimeLocal = dateTimeUtc.toLocal();
      return DateFormat('a').format(dateTimeLocal).toUpperCase();
    } catch (e) {
      return 'AM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffBAB9C0).withValues(alpha: .32),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type selector (read-only)
          if (activity.type != null && typeOptions.isNotEmpty) ...[
            _ReadOnlyTypeSelector(
              title: 'Type',
              selectedValue: activity.type!,
              options: typeOptions,
            ),
            const SizedBox(height: 16),
          ],
          // Sub-Type selector (read-only)
          if (activity.subType != null && subTypeOptions.isNotEmpty) ...[
            _ReadOnlyTypeSelector(
              title: 'Sub-Type',
              selectedValue: activity.subType!,
              options: subTypeOptions,
            ),
            const SizedBox(height: 16),
          ],
          // Quantity selector (read-only)
          if (activity.quantity != null && quantityOptions.isNotEmpty) ...[
            _ReadOnlyTypeSelector(
              title: 'Quantity',
              selectedValue: activity.quantity!,
              options: quantityOptions,
            ),
            const SizedBox(height: 16),
          ],
          // Accident-specific fields (same order and style as Accident form)
          if (activityType == 'accident') ...[
            Builder(
              builder: (context) {
                if (activity.accidentFields == null) {
                  return const SizedBox.shrink();
                }
                const accidentFieldOrder = [
                  'Nature of Injury',
                  'Injured Body Part',
                  'Location',
                  'First Aid Provided',
                  "Child's Reaction",
                  'Staff Involved',
                  'Date Notified',
                  'Medical Follow-Up required',
                  'Incident Reported to Authority',
                  'Parent Notified',
                  'How to Notify',
                ];
                final children = <Widget>[];
                const booleanKeys = {
                  'Medical Follow-Up required',
                  'Incident Reported to Authority',
                  'Parent Notified',
                };
                for (final key in accidentFieldOrder) {
                  final values = activity.accidentFields![key];
                  if (values != null && values.isNotEmpty) {
                    if (booleanKeys.contains(key)) {
                      children.add(
                        _ReadOnlySwitchRow(
                          title: key,
                          value: values.first,
                        ),
                      );
                    } else if (key == 'Date Notified') {
                      children.add(
                        _ReadOnlyFullWidthValueRow(
                          title: key,
                          value: values.first,
                        ),
                      );
                    } else if (key == 'Staff Involved' &&
                        activity.accidentStaffInvolved != null &&
                        activity.accidentStaffInvolved!.isNotEmpty) {
                      children.add(
                        _ReadOnlyStaffInvolved(
                          staffList: activity.accidentStaffInvolved!,
                        ),
                      );
                    } else {
                      children.add(
                        _ReadOnlyMultiSelectTypeSelector(
                          title: key,
                          selectedValues: values,
                        ),
                      );
                    }
                  }
                }
                // Description (form label: Description)
                children.add(
                  _ReadOnlyNoteWidget(
                    title: 'Description',
                    text: (activity.description != null &&
                            activity.description!.isNotEmpty)
                        ? activity.description!
                        : '—',
                  ),
                );
                children.add(const SizedBox(height: 16));
                // Attach Photo (form label: Attach Photo)
                children.add(
                  const Text(
                    'Attach Photo',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
                children.add(const SizedBox(height: 12));
                if (activity.photo != null && activity.photo!.isNotEmpty) {
                  children.add(_ReadOnlyPhotoWidget(photoId: activity.photo!));
                } else {
                  children.add(
                    Container(
                      height: 124,
                      width: 124,
                      decoration: BoxDecoration(
                        color: const Color(0xffF0E7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '—',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                children.add(const SizedBox(height: 16));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                );
              },
            ),
          ],
          // Incident-specific fields (displayed with separate titles)
          if (activityType == 'incident') ...[
            Builder(
              builder: (context) {
                if (activity.incidentFields != null &&
                    activity.incidentFields!.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: activity.incidentFields!.entries.map((entry) {
                      if (entry.value.isEmpty) return const SizedBox.shrink();
                      return _ReadOnlyMultiSelectTypeSelector(
                        title: entry.key,
                        selectedValues: entry.value,
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          // Observation-specific fields (displayed with separate titles)
          if (activityType == 'observation') ...[
            Builder(
              builder: (context) {
                if (activity.observationFields != null &&
                    activity.observationFields!.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: activity.observationFields!.entries.map((entry) {
                      if (entry.value.isEmpty) return const SizedBox.shrink();
                      return _ReadOnlyMultiSelectTypeSelector(
                        title: entry.key,
                        selectedValues: entry.value,
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          // Tags (read-only) - only for non-accident, non-incident, and non-observation activities
          if (activityType != 'accident' &&
              activityType != 'incident' &&
              activityType != 'observation' &&
              activity.tags.isNotEmpty) ...[
            const Text(
              'Tag',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activity.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Description (read-only) — skipped for accident (shown inside accident block)
          if (activityType != 'accident' &&
              activity.description != null &&
              activity.description!.isNotEmpty) ...[
            _ReadOnlyNoteWidget(
              title: 'Description',
              text: activity.description!,
            ),
            const SizedBox(height: 16),
          ],
          // Photo (read-only) — skipped for accident (shown inside accident block)
          ...() {
            if (activityType == 'accident') return <Widget>[];
            if (activity.photo != null && activity.photo!.isNotEmpty) {
              return [
                const Text(
                  'Photo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _ReadOnlyPhotoWidget(photoId: activity.photo!),
                const SizedBox(height: 16),
              ];
            }
            return <Widget>[];
          }(),
          // Time range for play/sleep
          if (activity.startAtTime != null || activity.endAtTime != null) ...[
            Row(
              children: [
                if (activity.startAtTime != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Time',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getTime(activity.startAtTime)} ${_getAmPm(activity.startAtTime)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (activity.startAtTime != null && activity.endAtTime != null)
                  const SizedBox(width: 24),
                if (activity.endAtTime != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Time',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getTime(activity.endAtTime)} ${_getAmPm(activity.endAtTime)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadOnlyTypeSelector extends StatelessWidget {
  final String title;
  final String selectedValue;
  final List<String> options;

  const _ReadOnlyTypeSelector({
    required this.title,
    required this.selectedValue,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return Container(
              width: 100,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                option,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.backgroundLight
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ReadOnlyMultiSelectTypeSelector extends StatelessWidget {
  final String title;
  final List<String> selectedValues;

  const _ReadOnlyMultiSelectTypeSelector({
    required this.title,
    required this.selectedValues,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: selectedValues.map((value) {
            // Check if value starts with "Date:" for special styling (wider container)
            final isDateValue = value.startsWith('Date:');
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: isDateValue ? null : 100,
                constraints: isDateValue
                    ? const BoxConstraints(minWidth: 100)
                    : null,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary, // Always selected (read-only)
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.backgroundLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Read-only row matching Accident form switch row: title left, value (Yes/No/—) right.
class _ReadOnlySwitchRow extends StatelessWidget {
  final String title;
  final String value;

  const _ReadOnlySwitchRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Value row for Date Notified: box only as wide as the date text so it fits without truncation.
class _ReadOnlyFullWidthValueRow extends StatelessWidget {
  final String title;
  final String value;

  const _ReadOnlyFullWidthValueRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.backgroundLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Read-only Staff Involved: horizontal list of avatar + name (like Accident form).
class _ReadOnlyStaffInvolved extends StatelessWidget {
  final List<Map<String, String?>> staffList;

  const _ReadOnlyStaffInvolved({required this.staffList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Staff Involved',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              final name = staff['name'] ?? '—';
              final photoId = staff['photoId'];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StaffAvatarWidget(photoId: photoId, size: 72),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ReadOnlyNoteWidget extends StatelessWidget {
  final String title;
  final String text;

  const _ReadOnlyNoteWidget({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              color: AppColors.backgroundLighter,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  color: AppColors.shadowLight.withValues(alpha: .05),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyPhotoWidget extends StatelessWidget {
  final String photoId;

  const _ReadOnlyPhotoWidget({required this.photoId});

  @override
  Widget build(BuildContext context) {
    final photoUrl = PhotoUtils.getPhotoUrl(photoId);

    if (photoUrl.isEmpty) {
      return Container(
        height: 124,
        width: 124,
        decoration: BoxDecoration(
          color: const Color(0xffF0E7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image, color: Color(0xff7B2AF3)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        httpHeaders: PhotoUtils.getImageHeaders(),
        width: 124,
        height: 124,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 124,
          height: 124,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 124,
          height: 124,
          color: Colors.grey.shade300,
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}
