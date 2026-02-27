import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// GET {{base_url}}/items/learning_category response item
class LearningCategoryItem {
  final String id;
  final String name;
  final String? description;
  LearningCategoryItem({
    required this.id,
    required this.name,
    this.description,
  });
}

/// GET {{base_url}}/items/age_group response item
class AgeGroupItem {
  final String id;
  final String name;
  final String? key;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  AgeGroupItem({
    required this.id,
    required this.name,
    this.key,
    this.minAgeMonths,
    this.maxAgeMonths,
  });
}

/// GET {{base_url}}/items/Class response item
class ClassItem {
  final String id;
  final String roomName;
  ClassItem({required this.id, required this.roomName});
}

/// Single Learning Plan from GET {{base_url}}/items/Learning_Plan
class LearningPlanItem {
  final String id;
  final String title;
  final String startDate;
  final String endDate;
  final String? categoryId;
  final String categoryName;
  final String? ageGroupId;
  final String ageBandName;
  final String? classId;
  final String roomName;
  final String? videoLink;
  final List<String> tags;
  final String? description;
  // Optional attached file information from `file` relation
  final String? fileId;
  final String? fileName;
  final String? fileUrl;

  LearningPlanItem({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.categoryId,
    this.categoryName = '',
    this.ageGroupId,
    this.ageBandName = '',
    this.classId,
    this.roomName = '',
    this.videoLink,
    this.tags = const [],
    this.description,
    this.fileId,
    this.fileName,
    this.fileUrl,
  });

  String get dateRangeDisplay => '$startDate - $endDate';

  static LearningPlanItem fromJson(Map<String, dynamic> m) {
    final cat = m['category_id'];
    final age = m['age_group_id'];
    final cls = m['class_id'];
    final file = m['file'];

    String catName = '';
    if (cat is Map<String, dynamic>) {
      catName = cat['name'] as String? ?? '';
    }

    String ageName = '';
    if (age is Map<String, dynamic>) {
      ageName = age['name'] as String? ?? '';
    }

    String room = '';
    if (cls is Map<String, dynamic>) {
      room = cls['room_name'] as String? ?? '';
    }

    String? fileId;
    String? fileName;
    String? fileUrl;
    if (file is Map<String, dynamic>) {
      fileId = file['id'] as String?;
      fileName = file['filename_download'] as String?;
      fileUrl = file['url'] as String?;
    }

    List<String> tagList = [];
    final t = m['tags'];
    if (t is List) {
      for (final e in t) {
        if (e != null) tagList.add(e.toString());
      }
    }

    return LearningPlanItem(
      id: m['id'] as String,
      title: m['title'] as String? ?? '',
      startDate: _formatDate(m['start_date']),
      endDate: _formatDate(m['end_date']),
      categoryId: m['category_id'] is String ? m['category_id'] as String? : (m['category_id'] as Map?)?['id'] as String?,
      categoryName: catName,
      ageGroupId: m['age_group_id'] is String ? m['age_group_id'] as String? : (m['age_group_id'] as Map?)?['id'] as String?,
      ageBandName: ageName,
      classId: m['class_id'] is String ? m['class_id'] as String? : (m['class_id'] as Map?)?['id'] as String?,
      roomName: room,
      videoLink: m['video_link'] as String?,
      tags: tagList,
      description: m['description'] as String?,
      fileId: fileId,
      fileName: fileName,
      fileUrl: fileUrl,
    );
  }

  static String _formatDate(dynamic v) {
    if (v == null) return '';
    if (v is String) {
      try {
        final d = DateTime.parse(v);
        return '${d.day} ${_monthName(d.month)} ${d.year}';
      } catch (_) {
        return v;
      }
    }
    return v.toString();
  }

  static String _monthName(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m - 1];
  }
}

@singleton
class LearningPlanApi {
  final Dio httpclient;
  LearningPlanApi(this.httpclient);

  /// GET {{base_url}}/items/learning_category
  Future<List<LearningCategoryItem>> getLearningCategories() async {
    final response = await httpclient.get('/items/learning_category');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return LearningCategoryItem(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        description: m['description'] as String?,
      );
    }).toList();
  }

  /// GET {{base_url}}/items/age_group
  Future<List<AgeGroupItem>> getAgeGroups() async {
    final response = await httpclient.get('/items/age_group');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return AgeGroupItem(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        key: m['key'] as String?,
        minAgeMonths: m['min_age_months'] as int?,
        maxAgeMonths: m['max_age_months'] as int?,
      );
    }).toList();
  }

  /// GET {{base_url}}/items/Class
  Future<List<ClassItem>> getClasses() async {
    final response = await httpclient.get('/items/Class');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return ClassItem(
        id: m['id'] as String,
        roomName: m['room_name'] as String? ?? '',
      );
    }).toList();
  }

  /// Create a single Learning Plan record (no parent activity table).
  /// POST {{base_url}}/items/Learning_Plan
  /// [category] is the learning_category id (UUID).
  Future<Response> createLearningPlan({
    required String title,
    required String category,
    required String startDate,
    required String endDate,
    String? ageGroupId,
    String? classId,
    String? videoLink,
    List<String>? tags,
    String? description,
    String? fileId,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'category_id': category,
      'start_date': startDate,
      'end_date': endDate,
      'age_group_id': ageGroupId,
      'class_id': classId,
      'video_link': videoLink,
      'tags': tags ?? [],
      'description': description,
      if (fileId != null && fileId.isNotEmpty) 'file': fileId,
    };
    final response = await httpclient.post('/items/Learning_Plan', data: data);
    return response;
  }

  /// Returns true if the class has at least one Learning Plan (for history screen).
  Future<bool> hasHistory(String classId) async {
    try {
      final response = await httpclient.get(
        '/items/Learning_Plan',
        queryParameters: {
          'filter[class_id][_eq]': classId,
          'limit': 1,
        },
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.isNotEmpty;
    } catch (e, st) {
      // Debug log for diagnosing Learning_Plan history errors
      // Please copy this from console if you report a bug.
      // ignore: avoid_print
      print('[LearningPlanApi.hasHistory] ERROR for classId=$classId -> $e\n$st');
      return false;
    }
  }

  /// GET Learning Plans for a class (with category, age_group, class names expanded).
  Future<List<LearningPlanItem>> getLearningPlans(String classId) async {
    final response = await httpclient.get(
      '/items/Learning_Plan',
      queryParameters: {
        'filter[class_id][_eq]': classId,
        'fields':
            'id,title,start_date,end_date,category_id,category_id.name,age_group_id,age_group_id.name,class_id,class_id.room_name,video_link,tags,description,file,file.id,file.filename_download',
        'sort': '-start_date',
      },
    );
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => LearningPlanItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET a single Learning Plan by id (for detail screen).
  Future<LearningPlanItem?> getLearningPlanById(String id) async {
    try {
      final response = await httpclient.get(
        '/items/Learning_Plan/$id',
        queryParameters: {
          'fields':
              'id,title,start_date,end_date,category_id,category_id.name,age_group_id,age_group_id.name,class_id,class_id.room_name,video_link,tags,description,file,file.id,file.filename_download',
        },
      );
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return LearningPlanItem.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
