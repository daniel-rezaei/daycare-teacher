import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
import 'package:teacher_app/features/event/domain/usecase/event_usecase.dart';

part 'event_event.dart';
part 'event_state.dart';

@injectable
class EventBloc extends Bloc<EventEvent, EventState> {
  final EventUsecase eventUsecase;
  EventBloc(this.eventUsecase) : super(EventInitial()) {
    on<GetAllEventsEvent>(_getAllEventsEvent);
  }

  FutureOr<void> _getAllEventsEvent(
    GetAllEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(GetAllEventsLoading());

    DataState dataState = await eventUsecase.getAllEvents();

    if (dataState is DataSuccess) {
      emit(GetAllEventsSuccess(dataState.data));
    }

    if (dataState is DataFailed) {
      emit(GetAllEventsFailure(dataState.error!));
    }
  }
}

