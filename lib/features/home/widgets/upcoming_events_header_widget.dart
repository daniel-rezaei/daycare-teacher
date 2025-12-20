import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
import 'package:teacher_app/features/event/presentation/bloc/event_bloc.dart';
import 'package:teacher_app/features/home/widgets/upcoming_event_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class UpcomingEventsHeaderWidget extends StatefulWidget {
  const UpcomingEventsHeaderWidget({super.key});

  @override
  State<UpcomingEventsHeaderWidget> createState() =>
      _UpcomingEventsHeaderWidgetState();
}

class _UpcomingEventsHeaderWidgetState
    extends State<UpcomingEventsHeaderWidget> {
  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(const GetAllEventsEvent());
  }

  List<EventUiModel> _convertToUiModels(List<EventEntity> events) {
    final now = DateTime.now();
    
    // فیلتر رویدادهایی که start_at آن‌ها در آینده است و مرتب‌سازی بر اساس start_at
    final upcomingEvents = events
        .where((event) {
          if (event.startAt == null || event.startAt!.isEmpty) return false;
          try {
            final startDate = DateTime.parse(event.startAt!);
            return startDate.isAfter(now) || startDate.isAtSameMomentAs(now);
          } catch (e) {
            return false;
          }
        })
        .toList()
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(a.startAt ?? '');
          final dateB = DateTime.parse(b.startAt ?? '');
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

    // تبدیل به EventUiModel و گرفتن 3 تای اول
    return upcomingEvents
        .take(3)
        .map((event) {
          DateTime? date;
          try {
            if (event.startAt != null && event.startAt!.isNotEmpty) {
              date = DateTime.parse(event.startAt!);
            }
          } catch (e) {
            date = null;
          }

          return EventUiModel(
            id: event.id ?? 0,
            title: event.title,
            date: date,
          );
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff444349),
              ),
            ),
            const Spacer(),
            const Text(
              'More',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff444349),
              ),
            ),
            const SizedBox(width: 4),
            Assets.images.next.svg(),
          ],
        ),
        const SizedBox(height: 14),
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is GetAllEventsLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CupertinoActivityIndicator(),
                ),
              );
            }

            if (state is GetAllEventsSuccess) {
              final events = _convertToUiModels(state.events);
              
              if (events.isEmpty) {
                return const SizedBox.shrink();
              }

              return UpcomingEventsCardStackUI(events: events);
            }

            if (state is GetAllEventsFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      color: Color(0xff444349),
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
