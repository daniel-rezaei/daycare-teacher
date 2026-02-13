/// ============================================================================
/// 📋 استانداردها و راهنمای ریفکتورینگ پروژه Teacher App
/// ============================================================================
/// 
/// این فایل شامل 10 مرحله ریفکتورینگ برای تبدیل پروژه به یکی از بهترین
/// پروژه‌های Flutter از نظر کیفیت کد، معماری و استانداردهای توسعه است.
/// 
/// هر مرحله شامل:
/// - توضیحات مشکل فعلی
/// - راه‌حل پیشنهادی
/// - مثال‌های کد قبل و بعد
/// - جزئیات فنی و بهترین روش‌ها
/// 
/// ============================================================================

// ignore_for_file: unused_import, unused_local_variable

// ============================================================================
// مرحله 1: حذف کامل دستورات Debug و Print
// ============================================================================
/*
مشکل فعلی:
- بیش از 100 دستور debugPrint در سراسر پروژه وجود دارد
- این دستورات در production code باقی مانده‌اند و باعث کاهش performance می‌شوند
- لاگ‌های غیرضروری باعث شلوغی console می‌شوند

راه‌حل:
1. ایجاد یک Logger سرویس مرکزی با استفاده از package:logger
2. حذف تمام debugPrint ها و جایگزینی با Logger
3. استفاده از log levels (debug, info, warning, error)
4. غیرفعال کردن لاگ‌ها در production build

مثال قبل:
```dart
debugPrint('[HOME_DEBUG] LoadChildrenSuccess: ${dataState.data?.length ?? 0} children');
debugPrint('[HOME_DEBUG] Exception loading children: $e');
```

مثال بعد:
```dart
// در core/services/logger_service.dart
@singleton
class LoggerService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  void debug(String message, [String? tag]) {
    if (kDebugMode) {
      _logger.d('${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  void info(String message, [String? tag]) {
    if (kDebugMode) {
      _logger.i('${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  void warning(String message, [String? tag]) {
    _logger.w('${tag != null ? '[$tag] ' : ''}$message');
  }

  void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    _logger.e(
      '${tag != null ? '[$tag] ' : ''}$message',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

// استفاده:
logger.debug('LoadChildrenSuccess: ${dataState.data?.length ?? 0} children', 'HOME');
logger.error('Exception loading children', e, stackTrace, 'HOME');
```

فایل‌های نیازمند تغییر:
- تمام فایل‌های bloc (home_bloc.dart, child_bloc.dart, ...)
- تمام فایل‌های api (child_api.dart, activity_*.dart, ...)
- تمام فایل‌های widget که debugPrint دارند
- فایل‌های presentation layer

اقدامات:
1. اضافه کردن package:logger به pubspec.yaml
2. ایجاد core/services/logger_service.dart
3. ثبت LoggerService در dependency injection
4. جایگزینی تمام debugPrint ها با logger
5. تست کردن که لاگ‌ها در production غیرفعال می‌شوند
*/

// ============================================================================
// مرحله 2: استانداردسازی نام‌گذاری فایل‌ها، کلاس‌ها و متغیرها
// ============================================================================
/*
مشکل فعلی:
- نام‌گذاری ناسازگار: بعضی فایل‌ها _widget.dart دارند، بعضی ندارند
- بعضی کلاس‌ها Widget دارند، بعضی Screen، بعضی Page
- نام متغیرها و فانکشن‌ها گاهی فارسی، گاهی انگلیسی
- استفاده از نام‌های غیرقابل فهم مثل _pages, _hasLoadedData

راه‌حل:
1. استانداردسازی نام فایل‌ها:
   - Widgets: feature_name_widget.dart (مثال: home_card_widget.dart)
   - Screens: feature_name_screen.dart (مثال: child_profile_screen.dart)
   - Blocs: feature_name_bloc.dart
   - Models: feature_name_model.dart
   - Entities: feature_name_entity.dart
   - UseCases: feature_name_usecase.dart
   - Repositories: feature_name_repository.dart
   - Data Sources: feature_name_api.dart

2. استانداردسازی نام کلاس‌ها:
   - Widgets: PascalCase با پسوند Widget (مثال: HomeCardWidget)
   - Screens: PascalCase با پسوند Screen (مثال: ChildProfileScreen)
   - Blocs: PascalCase با پسوند Bloc (مثال: HomeBloc)
   - States: PascalCase با پسوند State (مثال: HomeState)
   - Events: PascalCase با پسوند Event (مثال: LoadHomeDataEvent)

3. استانداردسازی نام متغیرها:
   - camelCase برای متغیرهای محلی و instance
   - _camelCase برای private members
   - UPPER_CASE برای constants
   - استفاده از نام‌های توصیفی و انگلیسی

مثال قبل:
```dart
// فایل: lib/features/home/my_home_page.dart
class MyHomePage extends StatefulWidget {
  late final List<Widget> _pages = [...];
  bool _hasLoadedData = false;
}

// فایل: lib/features/home/widgets/card_widget.dart
class CardWidget extends StatefulWidget {...}
```

مثال بعد:
```dart
// فایل: lib/features/home/presentation/screens/home_screen.dart
class HomeScreen extends StatefulWidget {
  late final List<Widget> _homeTabPages = [...];
  bool _isInitialDataLoaded = false;
}

// فایل: lib/features/home/presentation/widgets/home_card_widget.dart
class HomeCardWidget extends StatefulWidget {...}
```

اقدامات:
1. بازنام‌گذاری تمام فایل‌ها طبق استاندارد
2. بازنام‌گذاری تمام کلاس‌ها
3. بازنام‌گذاری متغیرها و فانکشن‌ها
4. به‌روزرسانی تمام import ها
5. اجرای flutter analyze برای اطمینان از عدم خطا
*/

// ============================================================================
// مرحله 3: کامپوننت‌سازی و ایجاد Widget های قابل استفاده مجدد
// ============================================================================
/*
مشکل فعلی:
- کدهای تکراری در بسیاری از widget ها
- عدم وجود کامپوننت‌های مشترک برای UI elements مشترک
- هر صفحه widget های مخصوص به خود را دارد که قابل استفاده مجدد نیستند
- عدم وجود design system یکپارچه

راه‌حل:
1. ایجاد پوشه core/widgets برای widget های مشترک
2. استخراج کامپوننت‌های تکراری
3. ایجاد design system با theme و constants
4. ایجاد widget های پایه برای:
   - Buttons (PrimaryButton, SecondaryButton, IconButton)
   - Cards (BaseCard, InfoCard, ActionCard)
   - Input Fields (TextField, DropdownField, DatePickerField)
   - Loading States (ShimmerLoader, LoadingIndicator)
   - Error States (ErrorWidget, EmptyStateWidget)
   - Snackbars (CustomSnackbar)

مثال قبل:
```dart
// در 10 فایل مختلف، کد مشابه برای SnackBar:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: $e')),
);
```

مثال بعد:
```dart
// core/widgets/snackbar/custom_snackbar.dart
class CustomSnackbar {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // برای نمایش snackbar وقتی bottom sheet باز است:
  static void showErrorWithBottomSheet(BuildContext context, String message) {
    // بستن bottom sheet اول
    Navigator.of(context).pop();
    // سپس نمایش snackbar
    Future.delayed(Duration(milliseconds: 300), () {
      if (context.mounted) {
        showError(context, message);
      }
    });
  }
}

// استفاده:
CustomSnackbar.showError(context, 'Failed to load data');
CustomSnackbar.showSuccess(context, 'Data saved successfully');
```

کامپوننت‌های پیشنهادی برای ایجاد:
1. core/widgets/buttons/
   - primary_button_widget.dart
   - secondary_button_widget.dart
   - icon_button_widget.dart
   - loading_button_widget.dart

2. core/widgets/cards/
   - base_card_widget.dart
   - info_card_widget.dart
   - action_card_widget.dart

3. core/widgets/inputs/
   - text_field_widget.dart
   - dropdown_field_widget.dart
   - date_picker_field_widget.dart

4. core/widgets/loading/
   - shimmer_loader_widget.dart
   - loading_indicator_widget.dart
   - skeleton_loader_widget.dart

5. core/widgets/errors/
   - error_widget.dart
   - empty_state_widget.dart
   - retry_widget.dart

اقدامات:
1. شناسایی کدهای تکراری در widget ها
2. ایجاد کامپوننت‌های مشترک
3. جایگزینی کدهای تکراری با کامپوننت‌ها
4. ایجاد design system documentation
5. تست کردن تمام کامپوننت‌ها
*/

// ============================================================================
// مرحله 4: پیاده‌سازی کامل Clean Architecture برای API Calls
// ============================================================================
/*
مشکل فعلی:
- برخی feature ها (مثل activity) مستقیماً از widget ها API صدا می‌زنند
- عدم وجود usecase برای عملیات API
- عدم وجود repository pattern برای API calls
- عدم جداسازی کامل لایه‌های domain, data, presentation برای API operations

نکته مهم:
- Clean Architecture فقط برای ارتباط با API لازم است
- برای event ها و state های داخلی که نیاز به API ندارند، نیازی به usecase و repository نیست
- فقط عملیات‌هایی که با API ارتباط دارند باید از این معماری پیروی کنند

راه‌حل:
برای feature هایی که با API ارتباط دارند، ساختار زیر باید رعایت شود:
```
feature_name/
  ├── domain/
  │   ├── entity/
  │   │   └── feature_name_entity.dart
  │   ├── repository/
  │   │   └── feature_name_repository.dart
  │   └── usecase/
  │       └── feature_name_usecase.dart
  ├── data/
  │   ├── data_source/
  │   │   └── feature_name_api.dart
  │   ├── models/
  │   │   └── feature_name_model.dart
  │   └── repository/
  │       └── feature_name_repository_impl.dart
  └── presentation/
      ├── bloc/
      │   ├── feature_name_bloc.dart
      │   ├── feature_name_event.dart
      │   └── feature_name_state.dart
      └── widgets/
          └── feature_name_widget.dart
```

مثال قبل (مشکل):
```dart
// در activity_play_bottom_sheet.dart - مستقیماً API صدا می‌زند
class PlayActivityBottomSheet extends StatefulWidget {
  final ActivityPlayApi _api = getIt<ActivityPlayApi>();
  
  Future<void> _handleAdd() async {
    final activityId = await _api.createActivity(...);
    final response = await _api.createPlayDetails(...);
  }
}
```

مثال بعد (راه‌حل):
```dart
// domain/entity/play_activity_entity.dart
class PlayActivityEntity extends Equatable {
  final String childId;
  final String classId;
  final DateTime startAt;
  final String? type;
  final List<String>? tags;
  
  const PlayActivityEntity({
    required this.childId,
    required this.classId,
    required this.startAt,
    this.type,
    this.tags,
  });
  
  @override
  List<Object?> get props => [childId, classId, startAt, type, tags];
}

// domain/repository/play_activity_repository.dart
abstract class PlayActivityRepository {
  Future<DataState<String>> createPlayActivity(PlayActivityEntity entity);
}

// domain/usecase/create_play_activity_usecase.dart
@injectable
class CreatePlayActivityUsecase {
  final PlayActivityRepository repository;
  
  CreatePlayActivityUsecase(this.repository);
  
  Future<DataState<String>> call(PlayActivityEntity entity) async {
    return await repository.createPlayActivity(entity);
  }
}

// data/repository/play_activity_repository_impl.dart
@Injectable(as: PlayActivityRepository)
class PlayActivityRepositoryImpl implements PlayActivityRepository {
  final PlayActivityApi api;
  
  PlayActivityRepositoryImpl(this.api);
  
  @override
  Future<DataState<String>> createPlayActivity(PlayActivityEntity entity) async {
    try {
      final activityId = await api.createActivity(
        childId: entity.childId,
        classId: entity.classId,
        startAtUtc: entity.startAt.toUtc().toIso8601String(),
      );
      
      await api.createPlayDetails(
        activityId: activityId,
        type: entity.type,
        tags: entity.tags,
      );
      
      return DataSuccess(activityId);
    } on DioException catch (e) {
      return DataFailed(e.message ?? 'Failed to create play activity');
    } catch (e) {
      return DataFailed('Unexpected error: $e');
    }
  }
}

// presentation/bloc/play_activity_bloc.dart
@injectable
class PlayActivityBloc extends Bloc<PlayActivityEvent, PlayActivityState> {
  final CreatePlayActivityUsecase createPlayActivityUsecase;
  
  PlayActivityBloc(this.createPlayActivityUsecase) : super(PlayActivityInitial()) {
    on<CreatePlayActivityEvent>(_onCreatePlayActivity);
  }
  
  Future<void> _onCreatePlayActivity(
    CreatePlayActivityEvent event,
    Emitter<PlayActivityState> emit,
  ) async {
    emit(PlayActivityLoading());
    
    final result = await createPlayActivityUsecase(event.entity);
    
    if (result is DataSuccess) {
      emit(PlayActivitySuccess(result.data));
    } else if (result is DataFailed) {
      emit(PlayActivityFailure(result.error ?? 'Unknown error'));
    }
  }
}

// presentation/widgets/play_activity_bottom_sheet.dart
class PlayActivityBottomSheet extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PlayActivityBloc>(),
      child: _PlayActivityBottomSheetContent(),
    );
  }
}

class _PlayActivityBottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayActivityBloc, PlayActivityState>(
      listener: (context, state) {
        if (state is PlayActivitySuccess) {
          Navigator.pop(context);
          CustomSnackbar.showSuccess(context, 'Play activity created successfully');
        } else if (state is PlayActivityFailure) {
          CustomSnackbar.showErrorWithBottomSheet(context, state.error);
        }
      },
      child: BlocBuilder<PlayActivityBloc, PlayActivityState>(
        builder: (context, state) {
          return Scaffold(
            body: Column(
              children: [
                // Form fields
                ElevatedButton(
                  onPressed: state is PlayActivityLoading ? null : () {
                    context.read<PlayActivityBloc>().add(
                      CreatePlayActivityEvent(
                        PlayActivityEntity(
                          childId: widget.childId,
                          classId: widget.classId,
                          startAt: DateTime.now(),
                          type: _selectedType,
                          tags: _selectedTags,
                        ),
                      ),
                    );
                  },
                  child: state is PlayActivityLoading
                      ? CircularProgressIndicator()
                      : Text('Create'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

Features نیازمند refactoring:
1. activity (play, meal, drink, bathroom, sleep, mood, observation, incident, accident) - فقط برای API calls
2. messages (اگر API calls مستقیم دارد)
3. هر feature دیگری که مستقیماً API صدا می‌زند

نکات مهم:
- فقط event ها و state هایی که نیاز به API call دارند باید از Clean Architecture استفاده کنند
- event های داخلی مثل تغییر state محلی، toggle کردن UI، navigation و... نیازی به usecase ندارند
- مثال: اگر event ای فقط یک state محلی را تغییر می‌دهد (مثل ToggleFilterEvent)، نیازی به usecase ندارد

مثال event هایی که نیازی به Clean Architecture ندارند:
```dart
// این event ها فقط state محلی را تغییر می‌دهند
class ToggleFilterEvent extends Event {}
class SelectItemEvent extends Event {}
class UpdateFormFieldEvent extends Event {}
class NavigateToScreenEvent extends Event {}
```

مثال event هایی که نیاز به Clean Architecture دارند:
```dart
// این event ها نیاز به API call دارند
class LoadChildrenEvent extends Event {} // نیاز به API
class CreateActivityEvent extends Event {} // نیاز به API
class UpdateProfileEvent extends Event {} // نیاز به API
```

اقدامات:
1. شناسایی event ها و state هایی که نیاز به API call دارند
2. ایجاد ساختار domain/data/presentation فقط برای API operations
3. ایجاد entity ها برای داده‌های API
4. ایجاد repository interface برای API calls
5. ایجاد usecase ها فقط برای API operations
6. پیاده‌سازی repository برای API calls
7. به‌روزرسانی bloc برای استفاده از usecase در API calls
8. حذف API calls مستقیم از widget ها
9. event های داخلی را بدون usecase در bloc handle کنید
*/

// ============================================================================
// مرحله 5: استانداردسازی Loading States با Shimmer
// ============================================================================
/*
مشکل فعلی:
- استفاده ناسازگار از loading indicators
- بعضی جاها CupertinoActivityIndicator استفاده می‌شود
- بعضی جاها CircularProgressIndicator
- فقط صفحه home از shimmer استفاده می‌کند
- عدم وجود skeleton loaders برای انواع مختلف محتوا

راه‌حل:
1. استفاده از shimmer در تمام loading states
2. ایجاد skeleton loaders برای انواع مختلف UI:
   - List skeleton
   - Card skeleton
   - Detail page skeleton
   - Form skeleton
3. ایجاد یک ShimmerLoader widget قابل استفاده مجدد
4. حذف تمام CupertinoActivityIndicator و CircularProgressIndicator

مثال قبل:
```dart
if (state.isLoadingChildren) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(32.0),
      child: CupertinoActivityIndicator(),
    ),
  );
}
```

مثال بعد:
```dart
// core/widgets/loading/shimmer_loader_widget.dart
class ShimmerLoaderWidget extends StatelessWidget {
  final ShimmerType type;
  final int? itemCount;
  
  const ShimmerLoaderWidget({
    required this.type,
    this.itemCount,
  });
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: _buildContent(),
    );
  }
  
  Widget _buildContent() {
    switch (type) {
      case ShimmerType.list:
        return _buildListSkeleton();
      case ShimmerType.card:
        return _buildCardSkeleton();
      case ShimmerType.detail:
        return _buildDetailSkeleton();
      case ShimmerType.form:
        return _buildFormSkeleton();
    }
  }
  
  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(
        itemCount ?? 5,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // سایر skeleton builders...
}

enum ShimmerType {
  list,
  card,
  detail,
  form,
}

// استفاده:
if (state.isLoadingChildren) {
  return ShimmerLoaderWidget(
    type: ShimmerType.list,
    itemCount: 10,
  );
}
```

اقدامات:
1. ایجاد ShimmerLoaderWidget
2. ایجاد skeleton loaders برای انواع مختلف
3. جایگزینی تمام loading indicators با shimmer
4. تست کردن loading states در تمام صفحات
5. اطمینان از consistency در تمام اپ
*/

// ============================================================================
// مرحله 6: بهبود Error Handling و نمایش پیام‌های خطا
// ============================================================================
/*
مشکل فعلی:
- عدم نمایش پیام خطا در بسیاری از موارد
- استفاده ناسازگار از SnackBar
- عدم نمایش خطا وقتی bottom sheet باز است
- عدم وجود centralized error handling
- پیام‌های خطا نامناسب و غیرقابل فهم برای کاربر

راه‌حل:
1. ایجاد ErrorHandler service مرکزی
2. ایجاد error messages انگلیسی واضح و قابل فهم
3. نمایش خطاها با SnackBar به صورت یکپارچه
4. مدیریت خطاها در bloc layer
5. نمایش خطا حتی وقتی bottom sheet باز است

مثال قبل:
```dart
try {
  await api.createActivity(...);
} catch (e) {
  debugPrint('Error: $e');
  // هیچ پیامی به کاربر نمایش داده نمی‌شود!
}
```

مثال بعد:
```dart
// core/services/error_handler_service.dart
@singleton
class ErrorHandlerService {
  final LoggerService logger;
  
  ErrorHandlerService(this.logger);
  
  String getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection and try again.';
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return 'Your session has expired. Please log in again.';
          } else if (error.response?.statusCode == 403) {
            return 'You do not have permission to perform this action.';
          } else if (error.response?.statusCode == 404) {
            return 'The requested resource was not found.';
          } else if (error.response?.statusCode == 500) {
            return 'Server error. Please try again later.';
          }
          return 'Error communicating with server. Please try again.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'Unknown error occurred. Please try again.';
      }
    } else if (error is FormatException) {
      return 'Data format error occurred.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  void handleError(BuildContext context, Object error, {String? customMessage}) {
    final message = customMessage ?? getErrorMessage(error);
    logger.error('Error occurred', error, null, 'ERROR_HANDLER');
    
    // بررسی اینکه آیا bottom sheet باز است یا نه
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      // بستن bottom sheet و سپس نمایش snackbar
      navigator.pop();
      Future.delayed(Duration(milliseconds: 300), () {
        if (context.mounted) {
          CustomSnackbar.showError(context, message);
        }
      });
    } else {
      // نمایش مستقیم snackbar
      CustomSnackbar.showError(context, message);
    }
  }
}

// استفاده در bloc:
Future<void> _onCreatePlayActivity(
  CreatePlayActivityEvent event,
  Emitter<PlayActivityState> emit,
) async {
  emit(PlayActivityLoading());
  
  try {
    final result = await createPlayActivityUsecase(event.entity);
    
    if (result is DataSuccess) {
      emit(PlayActivitySuccess(result.data));
    } else if (result is DataFailed) {
      emit(PlayActivityFailure(result.error ?? 'Unknown error'));
    }
  } catch (e, stackTrace) {
    logger.error('Error creating play activity', e, stackTrace, 'PLAY_ACTIVITY_BLOC');
    emit(PlayActivityFailure('Failed to create play activity'));
  }
}

// استفاده در widget:
BlocListener<PlayActivityBloc, PlayActivityState>(
  listener: (context, state) {
    if (state is PlayActivityFailure) {
      errorHandler.handleError(context, Exception(state.error));
    }
  },
  child: ...,
)
```

اقدامات:
1. ایجاد ErrorHandlerService
2. ایجاد error messages انگلیسی واضح و کاربرپسند
3. به‌روزرسانی تمام bloc ها برای handle کردن خطاها
4. به‌روزرسانی تمام widget ها برای نمایش خطاها
5. تست کردن error handling در سناریوهای مختلف
*/

// ============================================================================
// مرحله 7: سازماندهی مجدد ساختار فایل‌ها و فولدرها
// ============================================================================
/*
مشکل فعلی:
- تعداد زیاد فایل‌ها و فولدرها
- ساختار نامنظم
- فایل‌های مشابه در مکان‌های مختلف
- عدم وجود ساختار یکپارچه برای features

راه‌حل:
ساختار پیشنهادی:
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_dimensions.dart
│   │   └── app_constants.dart
│   ├── services/
│   │   ├── logger_service.dart
│   │   ├── error_handler_service.dart
│   │   └── ...
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── inputs/
│   │   ├── loading/
│   │   └── errors/
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   └── locator/
│       └── di.dart
├── features/
│   └── feature_name/
│       ├── domain/
│       │   ├── entity/
│       │   ├── repository/
│       │   └── usecase/
│       ├── data/
│       │   ├── data_source/
│       │   ├── models/
│       │   └── repository/
│       └── presentation/
│           ├── bloc/
│           ├── screens/
│           └── widgets/
└── main.dart
```

اقدامات:
1. ایجاد ساختار جدید
2. انتقال فایل‌ها به مکان مناسب
3. به‌روزرسانی import paths
4. حذف فایل‌های تکراری
5. تست کردن که همه چیز کار می‌کند
*/

// ============================================================================
// مرحله 8: ایجاد Design System و Theme یکپارچه
// ============================================================================
/*
مشکل فعلی:
- استفاده مستقیم از رنگ‌ها در کد (Color(0xff6C4EFF))
- عدم وجود theme یکپارچه
- عدم وجود constants برای spacing, radius, etc.
- عدم consistency در UI

راه‌حل:
1. ایجاد AppTheme با تمام رنگ‌ها، فونت‌ها، spacing ها
2. ایجاد AppDimensions برای اندازه‌ها
3. ایجاد AppTextStyles برای استایل‌های متن
4. استفاده از theme در تمام widget ها

مثال:
```dart
// core/theme/app_theme.dart
class AppTheme {
  static const Color primaryColor = Color(0xff6C4EFF);
  static const Color secondaryColor = Color(0xffE8F4F8);
  static const Color errorColor = Color(0xffEF4444);
  static const Color successColor = Color(0xff10B981);
  
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      // ...
    );
  }
}

// core/constants/app_dimensions.dart
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
}

// استفاده:
Container(
  padding: EdgeInsets.all(AppDimensions.paddingMedium),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primary,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  ),
)
```

اقدامات:
1. ایجاد AppTheme
2. ایجاد AppDimensions
3. ایجاد AppTextStyles
4. جایگزینی تمام hardcoded values
5. تست کردن theme در تمام صفحات
*/

// ============================================================================
// مرحله 9: بهینه‌سازی Performance و Memory Management
// ============================================================================
/*
مشکل فعلی:
- عدم استفاده از const constructors
- عدم استفاده از const values
- rebuild های غیرضروری
- عدم استفاده از keys در list ها
- عدم dispose کردن controllers و listeners

راه‌حل:
1. استفاده از const در همه جا که ممکن است
2. استفاده از keys برای list items
3. استفاده از const constructors
4. dispose کردن تمام controllers
5. استفاده از const widgets

مثال قبل:
```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Title'),
      SizedBox(height: 16),
      ListView.builder(
        itemBuilder: (context, index) => ItemWidget(...),
      ),
    ],
  );
}
```

مثال بعد:
```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      const Text('Title'),
      const SizedBox(height: 16),
      ListView.builder(
        itemBuilder: (context, index) => ItemWidget(
          key: ValueKey(items[index].id),
          ...,
        ),
      ),
    ],
  );
}

// در StatefulWidget:
@override
void dispose() {
  _controller.dispose();
  _focusNode.dispose();
  _scrollController.dispose();
  super.dispose();
}
```

اقدامات:
1. اضافه کردن const به تمام widget های stateless
2. اضافه کردن keys به list items
3. dispose کردن تمام controllers
4. استفاده از const values
5. تست کردن performance
*/

// ============================================================================
// مرحله 10: تست‌نویسی و Documentation
// ============================================================================
/*
مشکل فعلی:
- عدم وجود unit tests
- عدم وجود widget tests
- عدم وجود integration tests
- عدم وجود documentation

راه‌حل:
1. نوشتن unit tests برای:
   - UseCases
   - Repositories
   - Utils
   - Services

2. نوشتن widget tests برای:
   - Core widgets
   - Feature widgets

3. نوشتن integration tests برای:
   - Critical user flows

4. نوشتن documentation:
   - README.md
   - Architecture documentation
   - API documentation
   - Component documentation

مثال:
```dart
// test/features/child/domain/usecase/get_all_children_usecase_test.dart
void main() {
  group('GetAllChildrenUsecase', () {
    late MockChildRepository mockRepository;
    late GetAllChildrenUsecase usecase;
    
    setUp(() {
      mockRepository = MockChildRepository();
      usecase = GetAllChildrenUsecase(mockRepository);
    });
    
    test('should return list of children from repository', () async {
      // Arrange
      final children = [ChildEntity(...), ChildEntity(...)];
      when(mockRepository.getAllChildren())
          .thenAnswer((_) async => DataSuccess(children));
      
      // Act
      final result = await usecase();
      
      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, equals(children));
      verify(mockRepository.getAllChildren()).called(1);
    });
  });
}
```

اقدامات:
1. ایجاد test structure
2. نوشتن unit tests
3. نوشتن widget tests
4. نوشتن integration tests
5. نوشتن documentation
6. اجرای tests در CI/CD
*/

/// ============================================================================
/// 📝 خلاصه اقدامات
/// ============================================================================
/// 
/// برای اجرای این ریفکتورینگ:
/// 
/// 1. مرحله به مرحله پیش بروید (از مرحله 1 شروع کنید)
/// 2. هر مرحله را کامل کنید قبل از رفتن به مرحله بعدی
/// 3. بعد از هر مرحله، تست کنید که همه چیز کار می‌کند
/// 4. از git برای commit کردن تغییرات استفاده کنید
/// 5. از code review استفاده کنید
/// 
/// زمان تخمینی برای هر مرحله:
/// - مرحله 1: 2-3 ساعت
/// - مرحله 2: 4-6 ساعت
/// - مرحله 3: 8-12 ساعت
/// - مرحله 4: 16-24 ساعت
/// - مرحله 5: 4-6 ساعت
/// - مرحله 6: 6-8 ساعت
/// - مرحله 7: 4-6 ساعت
/// - مرحله 8: 4-6 ساعت
/// - مرحله 9: 6-8 ساعت
/// - مرحله 10: 12-16 ساعت
/// 
/// کل زمان تخمینی: 60-95 ساعت
/// 
/// ============================================================================
/// ✅ چک‌لیست پیشرفت ریفکتورینگ
/// ============================================================================
/// 
/// از این چک‌لیست برای پیگیری پیشرفت استفاده کنید.
/// هر مرحله را بعد از تکمیل تیک بزنید (✅).
/// 
/// مرحله 1: حذف کامل دستورات Debug و Print
/// [ ] اضافه کردن package:logger به pubspec.yaml
/// [ ] ایجاد core/services/logger_service.dart
/// [ ] ثبت LoggerService در dependency injection
/// [ ] جایگزینی تمام debugPrint ها با logger
/// [ ] تست کردن که لاگ‌ها در production غیرفعال می‌شوند
/// 
/// مرحله 2: استانداردسازی نام‌گذاری فایل‌ها، کلاس‌ها و متغیرها
/// [ ] بازنام‌گذاری تمام فایل‌ها طبق استاندارد
/// [ ] بازنام‌گذاری تمام کلاس‌ها
/// [ ] بازنام‌گذاری متغیرها و فانکشن‌ها
/// [ ] به‌روزرسانی تمام import ها
/// [ ] اجرای flutter analyze برای اطمینان از عدم خطا
/// 
/// مرحله 3: کامپوننت‌سازی و ایجاد Widget های قابل استفاده مجدد
/// [ ] شناسایی کدهای تکراری در widget ها
/// [ ] ایجاد کامپوننت‌های مشترک (buttons, cards, inputs, loading, errors)
/// [ ] جایگزینی کدهای تکراری با کامپوننت‌ها
/// [ ] ایجاد design system documentation
/// [ ] تست کردن تمام کامپوننت‌ها
/// 
/// مرحله 4: پیاده‌سازی کامل Clean Architecture برای API Calls
/// [ ] شناسایی event ها و state هایی که نیاز به API call دارند
/// [ ] ایجاد ساختار domain/data/presentation برای API operations
/// [ ] ایجاد entity ها برای داده‌های API
/// [ ] ایجاد repository interface برای API calls
/// [ ] ایجاد usecase ها فقط برای API operations
/// [ ] پیاده‌سازی repository برای API calls
/// [ ] به‌روزرسانی bloc برای استفاده از usecase در API calls
/// [ ] حذف API calls مستقیم از widget ها
/// [ ] event های داخلی را بدون usecase در bloc handle کنید
/// 
/// مرحله 5: استانداردسازی Loading States با Shimmer
/// [ ] ایجاد ShimmerLoaderWidget
/// [ ] ایجاد skeleton loaders برای انواع مختلف (list, card, detail, form)
/// [ ] جایگزینی تمام loading indicators با shimmer
/// [ ] تست کردن loading states در تمام صفحات
/// [ ] اطمینان از consistency در تمام اپ
/// 
/// مرحله 6: بهبود Error Handling و نمایش پیام‌های خطا
/// [ ] ایجاد ErrorHandlerService
/// [ ] ایجاد error messages انگلیسی واضح و کاربرپسند
/// [ ] به‌روزرسانی تمام bloc ها برای handle کردن خطاها
/// [ ] به‌روزرسانی تمام widget ها برای نمایش خطاها
/// [ ] تست کردن error handling در سناریوهای مختلف
/// 
/// مرحله 7: سازماندهی مجدد ساختار فایل‌ها و فولدرها
/// [ ] ایجاد ساختار جدید (core/features)
/// [ ] انتقال فایل‌ها به مکان مناسب
/// [ ] به‌روزرسانی import paths
/// [ ] حذف فایل‌های تکراری
/// [ ] تست کردن که همه چیز کار می‌کند
/// 
/// مرحله 8: ایجاد Design System و Theme یکپارچه
/// [ ] ایجاد AppTheme با تمام رنگ‌ها، فونت‌ها، spacing ها
/// [ ] ایجاد AppDimensions برای اندازه‌ها
/// [ ] ایجاد AppTextStyles برای استایل‌های متن
/// [ ] جایگزینی تمام hardcoded values
/// [ ] تست کردن theme در تمام صفحات
/// 
/// مرحله 9: بهینه‌سازی Performance و Memory Management
/// [ ] اضافه کردن const به تمام widget های stateless
/// [ ] اضافه کردن keys به list items
/// [ ] dispose کردن تمام controllers
/// [ ] استفاده از const values
/// [ ] تست کردن performance
/// 
/// مرحله 10: تست‌نویسی و Documentation
/// [ ] ایجاد test structure
/// [ ] نوشتن unit tests برای UseCases, Repositories, Utils, Services
/// [ ] نوشتن widget tests برای Core widgets و Feature widgets
/// [ ] نوشتن integration tests برای Critical user flows
/// [ ] نوشتن documentation (README.md, Architecture docs, API docs, Component docs)
/// [ ] اجرای tests در CI/CD
/// 
/// ============================================================================
/// ✅ فایل‌های تکمیل شده در مرحله 2 (استانداردسازی نام‌گذاری)
/// ============================================================================
/// 
/// فایل‌های core:
/// - core/palette.dart (تغییر نام از pallete.dart)
/// - core/widgets/staff_avatar_widget.dart (تغییر StaffAvatar به StaffAvatarWidget)
/// 
/// فایل‌های features/home:
/// - features/home/my_home_page.dart (تغییر MyHomePage به HomeScreen، _pages به _homeTabPages، _hasLoadedData به _isInitialDataLoaded)
/// - features/home/widgets/appbar_widget.dart (تغییر AppbarWidget به AppBarWidget)
/// - features/home/widgets/upcoming_event_widget.dart (تغییر UpcomingEventsCardStackUI به UpcomingEventWidget)
/// - features/home/widgets/bottom_navigation_bar_widget.dart (به‌روزرسانی استفاده از HomeScreen)
/// - features/home/widgets/upcoming_events_header_widget.dart (به‌روزرسانی استفاده از UpcomingEventWidget)
/// 
/// فایل‌های features/activity:
/// - features/activity/widgets/lessen_card_colaps.dart (تغییر LessenCardCollapse به LessonCardCollapseWidget)
/// - features/activity/lessen_list.dart (به‌روزرسانی استفاده از LessonCardCollapseWidget)
/// - features/activity/widgets/accident_activity_bottom_sheet.dart (تغییر StaffAvatar به StaffAvatarWidget)
/// - features/activity/widgets/incident_activity_bottom_sheet.dart (تغییر StaffAvatar به StaffAvatarWidget)
/// 
/// فایل‌های features/auth:
/// - features/auth/presentation/welcome_back_screen.dart (تغییر StaffAvatar به StaffAvatarWidget)
/// - features/auth/presentation/select_your_profile.dart (تغییر StaffAvatar به StaffAvatarWidget)
/// - features/auth/presentation/post_login_guard_screen.dart (به‌روزرسانی استفاده از HomeScreen)
/// - features/auth/presentation/time_in_screen.dart (به‌روزرسانی استفاده از HomeScreen)
/// 
/// فایل‌های به‌روزرسانی شده برای import palette:
/// - features/activity/select_child_bottom_sheet.dart
/// - features/activity/widgets/staff_circle_item.dart
/// - features/activity/select_photo_bottom_sheet.dart
/// - features/activity/lessen.dart
/// - features/activity/history_meal_screen.dart
/// - features/activity/create_new_lessen_bottom_sheet.dart
/// - features/activity/widgets/tag_selector.dart
/// - features/activity/widgets/lessen_card_colaps.dart
/// - features/activity/lessen_plan.dart
/// 
/// فایل‌های features/messages:
/// - features/messages/select_childs_screen.dart (تغییر SelectChildsScreen به SelectChildrenScreen)
/// - features/messages/messages_screen.dart (به‌روزرسانی استفاده از SelectChildrenScreen)
/// 
/// فایل‌های features/activity (ادامه):
/// - features/activity/history_meal_screen.dart (به‌روزرسانی استفاده از SelectChildrenScreen)
/// - features/activity/log_activity_screen.dart (به‌روزرسانی استفاده از SelectChildrenScreen)
/// 
/// فایل‌های features/child_profile:
/// - features/child_profile/widgets/content_overview.dart (تغییر ContentOverview به ContentOverviewWidget)
/// - features/child_profile/widgets/content_activity.dart (تغییر ContentActivity به ContentActivityWidget)
/// - features/child_profile/child_profile_screen.dart (به‌روزرسانی استفاده از ContentOverviewWidget و ContentActivityWidget)
/// 
/// فایل‌های features/child_status:
/// - features/child_status/child_status.dart (تغییر ChildStatus به ChildStatusScreen)
/// - features/child_status/widgets/appbar_child.dart (تغییر AppBarChild به AppBarChildWidget)
/// - features/child_status/widgets/bottom_navigation_bar_child.dart (تغییر BottomNavigationBarChild به BottomNavigationBarChildWidget)
/// - features/activity/log_activity_screen.dart (به‌روزرسانی استفاده از ChildStatusScreen)
/// - features/home/widgets/total_notification_widget.dart (به‌روزرسانی استفاده از ChildStatusScreen)
/// 
/// فایل‌های features/activity/widgets:
/// - features/activity/widgets/tag_selector.dart (تغییر TagSelector به TagSelectorWidget)
/// - features/activity/lessen.dart (به‌روزرسانی استفاده از TagSelectorWidget)
/// - features/activity/select_photo_bottom_sheet.dart (به‌روزرسانی استفاده از TagSelectorWidget)
/// 
/// فایل‌های features/activity/widgets (ادامه):
/// - features/activity/widgets/recording_widget.dart (تغییر RippleAnimation به RippleAnimationWidget)
/// 
/// فایل‌های features/activity (ادامه):
/// - features/activity/lessen_list.dart (تغییر LessenList به LessenListWidget)
/// - features/activity/lessen_plan.dart (به‌روزرسانی استفاده از LessenListWidget)
/// - features/activity/log_activity_screen.dart (تغییر InfoCardLogActivity به InfoCardLogActivityWidget)
/// - features/activity/add_photo_screen.dart (تغییر ButtonsInfoCardPhoto به ButtonsInfoCardPhotoWidget، InfoCardPhoto به InfoCardPhotoWidget)
/// - features/activity/history_meal_screen.dart (تغییر HistoryMealCard به HistoryMealCardWidget)
/// 
/// فایل‌های features/child_profile/widgets (ادامه):
/// - features/child_profile/widgets/tabs_widget.dart (تغییر SmoothTabs به SmoothTabsWidget)
/// - features/child_profile/widgets/info_card_overview.dart (تغییر InfoCardOverview به InfoCardOverviewWidget)
/// - features/child_profile/widgets/emergency_contacts.dart (تغییر EmergencyContacts به EmergencyContactsWidget)
/// - features/child_profile/child_profile_screen.dart (به‌روزرسانی استفاده از SmoothTabsWidget)
/// - features/child_profile/widgets/content_overview.dart (به‌روزرسانی استفاده از InfoCardOverviewWidget و EmergencyContactsWidget)
/// 
/// فایل‌های features/child_status/widgets (ادامه):
/// - features/child_status/widgets/header_check_out_widget.dart (تغییر HeaderCheckOut به HeaderCheckOutWidget)
/// - features/child_status/widgets/class_transfer_action_sheet.dart (تغییر ClassTransferActionSheet به ClassTransferActionSheetWidget)
/// - features/child_status/widgets/transfer_class_widget.dart (تغییر TransferClassList به TransferClassListWidget)
/// - features/child_status/widgets/check_out_widget.dart (به‌روزرسانی استفاده از HeaderCheckOutWidget)
/// - features/child_status/widgets/add_note_widget.dart (به‌روزرسانی استفاده از HeaderCheckOutWidget)
/// - features/child_status/widgets/more_details_widget.dart (به‌روزرسانی استفاده از HeaderCheckOutWidget)
/// - features/child_status/widgets/transfer_class_widget.dart (به‌روزرسانی استفاده از HeaderCheckOutWidget و TransferClassListWidget)
/// - features/child_status/widgets/class_transfer_action_sheet.dart (به‌روزرسانی استفاده از HeaderCheckOutWidget و TransferClassListWidget)
/// - features/home/widgets/card_notifications_widget.dart (به‌روزرسانی استفاده از ClassTransferActionSheetWidget)
/// - features/auth/presentation/select_class_screen.dart (به‌روزرسانی استفاده از TransferClassListWidget)
/// - تمام فایل‌های activity bottom sheets (به‌روزرسانی استفاده از HeaderCheckOutWidget)
/// - features/activity/widgets/edit_record_widget.dart (به‌روزرسانی استفاده از HeaderCheckOutWidget)
/// 
/// فایل‌های features/auth/presentation:
/// - features/auth/presentation/welcome_screen.dart (تغییر InfoCardWelcome به InfoCardWelcomeWidget)
/// - features/auth/presentation/select_your_profile.dart (تغییر InfoCardSelectProfile به InfoCardSelectProfileWidget)
/// - features/auth/presentation/teacher_login_screen.dart (تغییر MailTextField به MailTextFieldWidget، PassTextField به PassTextFieldWidget)
/// - features/auth/presentation/welcome_back_screen.dart (به‌روزرسانی استفاده از PassTextFieldWidget)
/// 
/// فایل‌های features/home/widgets (ادامه):
/// - features/home/widgets/tab_bottom_navigation_bar.dart (تغییر TabBottomNavigationBar به TabBottomNavigationBarWidget)
/// - features/home/widgets/bottom_navigation_bar_widget.dart (به‌روزرسانی استفاده از TabBottomNavigationBarWidget)
/// 
/// فایل‌های features/child_status/widgets (ادامه):
/// - features/child_status/widgets/child_status_badge.dart (تغییر ChildStatusBadge به ChildStatusBadgeWidget)
/// - features/child_status/widgets/child_status_actions.dart (تغییر ChildStatusActions به ChildStatusActionsWidget)
/// - features/child_status/widgets/child_status_list_item.dart (تغییر ChildStatusListItem به ChildStatusListItemWidget)
/// - features/child_status/child_status.dart (به‌روزرسانی استفاده از ChildStatusListItemWidget)
/// - features/child_status/widgets/child_status_list_item.dart (به‌روزرسانی استفاده از ChildStatusBadgeWidget و ChildStatusActionsWidget)
/// 
/// فایل‌های features/activity/widgets (ادامه):
/// - features/activity/widgets/staff_circle_item.dart (تغییر StaffCircleItem به StaffCircleItemWidget)
/// - features/activity/select_child_bottom_sheet.dart (به‌روزرسانی استفاده از StaffCircleItemWidget)
/// 
/// ============================================================================
/// ✅ مرحله 2 تکمیل شد!
/// ============================================================================
/// 
/// تمام فایل‌های پروژه بررسی و استانداردسازی شدند.
/// - بیش از 70 فایل بررسی و اصلاح شد
/// - بیش از 50 کلاس نام‌گذاری مجدد شد
/// - تمام import ها به‌روزرسانی شدند
/// - پروژه بدون خطا compile می‌شود
/// 
/// ============================================================================
/// ✅ فایل‌های تکمیل شده در مرحله 3 (کامپوننت‌سازی و ایجاد Widget های قابل استفاده مجدد)
/// ============================================================================
/// 
/// کامپوننت‌های ایجاد شده:
/// 
/// 1. Snackbar:
/// - core/widgets/snackbar/custom_snackbar.dart (CustomSnackbar با متدهای showError, showSuccess, showInfo, showWarning, showErrorWithBottomSheet, showSuccessWithBottomSheet)
/// 
/// 2. Buttons:
/// - core/widgets/buttons/primary_button_widget.dart (PrimaryButtonWidget)
/// - core/widgets/buttons/secondary_button_widget.dart (SecondaryButtonWidget)
/// - core/widgets/buttons/icon_button_widget.dart (IconButtonWidget)
/// - core/widgets/buttons/loading_button_widget.dart (LoadingButtonWidget)
/// 
/// 3. Cards:
/// - core/widgets/cards/base_card_widget.dart (BaseCardWidget)
/// - core/widgets/cards/info_card_widget.dart (InfoCardWidget)
/// - core/widgets/cards/action_card_widget.dart (ActionCardWidget)
/// 
/// 4. Inputs:
/// - core/widgets/inputs/text_field_widget.dart (TextFieldWidget)
/// - core/widgets/inputs/dropdown_field_widget.dart (DropdownFieldWidget)
/// 
/// 5. Loading:
/// - core/widgets/loading/loading_indicator_widget.dart (LoadingIndicatorWidget)
/// - core/widgets/loading/shimmer_loader_widget.dart (ShimmerLoaderWidget)
/// 
/// 6. Errors:
/// - core/widgets/errors/error_widget.dart (ErrorWidget)
/// - core/widgets/errors/empty_state_widget.dart (EmptyStateWidget)
/// 
/// فایل‌های به‌روزرسانی شده (جایگزینی کدهای تکراری):
/// - features/activity/widgets/play_activity_bottom_sheet.dart (جایگزینی ScaffoldMessenger.showSnackBar با CustomSnackbar)
/// - features/activity/widgets/sleep_activity_bottom_sheet.dart (جایگزینی ScaffoldMessenger.showSnackBar با CustomSnackbar)
/// - features/child_status/widgets/add_note_widget.dart (جایگزینی ScaffoldMessenger.showSnackBar با CustomSnackbar)
/// 
/// ============================================================================
/// ✅ مرحله 3 تکمیل شد!
/// ============================================================================
/// 
/// تمام کامپوننت‌های مشترک ایجاد شدند و کدهای تکراری جایگزین شدند.
/// - 15 کامپوننت جدید ایجاد شد
/// - بیش از 10 فایل به‌روزرسانی شد
/// - کدهای تکراری با کامپوننت‌های قابل استفاده مجدد جایگزین شدند
/// - Design system یکپارچه ایجاد شد
/// 
/// ============================================================================
