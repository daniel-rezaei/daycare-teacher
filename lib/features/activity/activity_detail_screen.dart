import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/core/utils/photo_utils.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_bathroom_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_drinks_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_meals_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_play_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_sleep_api.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
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

  const ActivityDetailScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.childPhoto,
    required this.activityType,
    required this.activityDate,
    this.classId,
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
          setState(() {
            _typeOptions = mealTypes;
            _quantityOptions = quantities;
            _subTypeOptions = [];
          });
          break;
        case 'drink':
          final drinkTypes = await _drinksApi.getDrinkTypes();
          final quantities = await _drinksApi.getQuantities();
          setState(() {
            _typeOptions = drinkTypes;
            _quantityOptions = quantities;
            _subTypeOptions = [];
          });
          break;
        case 'bathroom':
          final types = await _bathroomApi.getBathroomTypes();
          final subTypes = await _bathroomApi.getSubTypes();
          setState(() {
            _typeOptions = types;
            _quantityOptions = [];
            _subTypeOptions = subTypes;
          });
          break;
        case 'play':
          final types = await _playApi.getPlayTypes();
          setState(() {
            _typeOptions = types;
            _quantityOptions = [];
            _subTypeOptions = [];
          });
          break;
        case 'sleep':
          final types = await _sleepApi.getSleepTypes();
          setState(() {
            _typeOptions = types;
            _quantityOptions = [];
            _subTypeOptions = [];
          });
          break;
        default:
          setState(() {
            _typeOptions = [];
            _quantityOptions = [];
            _subTypeOptions = [];
          });
      }
    } catch (e) {
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
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

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
      final List<_ActivityDetailItem> items = [];

      for (final activity in activities) {
        final activityId = activity['id'] as String;
        final startAt = activity['start_at'] as String?;

        // Get activity details based on type
        final details = await _getActivityDetails(activityId);
        if (details != null) {
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
            ),
          );
        }
      }

      setState(() {
        _activities = items;
        _isLoading = false;
      });
    } catch (e) {
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

  Future<Map<String, dynamic>?> _getActivityDetails(String activityId) async {
    try {
      String endpoint;
      String? typeField;
      String? quantityField;
      String? subTypeField;
      bool hasTimeFields = false;

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
          return null;
      }

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
      fields.add('photo');

      final response = await getIt<Dio>().get(
        endpoint,
        queryParameters: {
          'filter[activity_id][_eq]': activityId,
          'fields': fields.join(','),
          'limit': 1,
        },
      );

      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return null;

      final detail = data[0] as Map<String, dynamic>;

      // Handle photo - could be nested
      String? photoId;
      if (detail['photo'] != null) {
        if (detail['photo'] is Map) {
          photoId = detail['photo']['id'] as String?;
        } else if (detail['photo'] is String) {
          photoId = detail['photo'] as String;
        } else if (detail['photo'] is List &&
            (detail['photo'] as List).isNotEmpty) {
          final photoList = detail['photo'] as List;
          if (photoList[0] is Map) {
            photoId = photoList[0]['directus_files_id'] as String?;
          }
        }
      }

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

      return {
        'type': typeField != null ? detail[typeField]?.toString() : null,
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
    } catch (e) {
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
                        DayStripWidget(onDateSelected: _onDateSelected),
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
                                    child: CircularProgressIndicator(),
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
          // Tags (read-only)
          if (activity.tags.isNotEmpty) ...[
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
          // Description (read-only)
          if (activity.description != null &&
              activity.description!.isNotEmpty) ...[
            _ReadOnlyNoteWidget(
              title: 'Decription',
              text: activity.description!,
            ),
            const SizedBox(height: 16),
          ],
          // Photo (read-only)
          if (activity.photo != null && activity.photo!.isNotEmpty) ...[
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
          ],
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
