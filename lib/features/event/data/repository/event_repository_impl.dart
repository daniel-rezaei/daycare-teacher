import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/event/data/data_source/event_api.dart';
import 'package:teacher_app/features/event/data/models/event_model/event_model.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
import 'package:teacher_app/features/event/domain/repository/event_repository.dart';

@Singleton(as: EventRepository, env: [Env.prod])
class EventRepositoryImpl extends EventRepository {
  final EventApi eventApi;

  EventRepositoryImpl(this.eventApi);

  @override
  Future<DataState<List<EventEntity>>> getAllEvents() async {
    try {
      final Response response = await eventApi.getAllEvents();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<EventEntity> eventsEntity = list
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(eventsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataState<List<EventEntity>> _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DataFailed('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        return DataFailed('Server error: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return DataFailed('Request cancelled.');
      default:
        return DataFailed('Network error. Please check your connection.');
    }
  }
}

