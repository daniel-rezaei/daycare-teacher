import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global, persistent source of truth for staff attendance session state
/// This store survives navigation, app background/foreground, and widget rebuilds
class AttendanceSessionStore extends ChangeNotifier {
  static const String _keyActiveSessionId = 'attendance_session_id';
  static const String _keyTimeInAt = 'attendance_time_in_at';
  static const String _keyAccumulatedTotal = 'attendance_accumulated_total';
  static const String _keyIsClockedIn = 'attendance_is_clocked_in';
  static const String _keyStaffId = 'attendance_staff_id';

  static AttendanceSessionStore? _instance;
  static AttendanceSessionStore get instance {
    _instance ??= AttendanceSessionStore._();
    return _instance!;
  }

  AttendanceSessionStore._() {
    _initialize();
  }

  // In-memory state
  String? _activeSessionId;
  DateTime? _timeInAt;
  Duration _accumulatedTotal = Duration.zero;
  bool _isClockedIn = false;
  String? _staffId;

  // Getters
  String? get activeSessionId => _activeSessionId;
  DateTime? get timeInAt => _timeInAt;
  Duration get accumulatedTotal => _accumulatedTotal;
  bool get isClockedIn => _isClockedIn;
  String? get staffId => _staffId;

  /// Initialize store from persistent storage
  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _activeSessionId = prefs.getString(_keyActiveSessionId);
      _staffId = prefs.getString(_keyStaffId);
      
      final timeInAtString = prefs.getString(_keyTimeInAt);
      if (timeInAtString != null) {
        _timeInAt = DateTime.parse(timeInAtString);
      }
      
      final accumulatedSeconds = prefs.getInt(_keyAccumulatedTotal) ?? 0;
      _accumulatedTotal = Duration(seconds: accumulatedSeconds);
      
      _isClockedIn = prefs.getBool(_keyIsClockedIn) ?? false;
      
      debugPrint(
        '[ATTENDANCE_STORE] Initialized from storage: '
        'isClockedIn=$_isClockedIn, '
        'sessionId=$_activeSessionId, '
        'timeInAt=$_timeInAt, '
        'accumulatedTotal=${_accumulatedTotal.inMinutes}min',
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('[ATTENDANCE_STORE] Error initializing: $e');
    }
  }

  /// Rehydrate from persistent storage (call on app resume, navigation, etc.)
  Future<void> rehydrate() async {
    await _initialize();
  }

  /// Start a new Time-In session
  Future<void> startTimeIn({
    required String sessionId,
    required DateTime timeInAt,
    required String staffId,
  }) async {
    try {
      _activeSessionId = sessionId;
      _timeInAt = timeInAt;
      _staffId = staffId;
      _isClockedIn = true;
      // Don't reset accumulatedTotal - it should persist across sessions

      await _persistToStorage();
      
      debugPrint(
        '[ATTENDANCE_STORE] Time-In started: '
        'sessionId=$sessionId, '
        'timeInAt=$timeInAt, '
        'accumulatedTotal=${_accumulatedTotal.inMinutes}min',
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('[ATTENDANCE_STORE] Error starting Time-In: $e');
    }
  }

  /// End Time-In session (Time-Out)
  Future<void> endTimeIn({
    required Duration sessionDuration,
  }) async {
    try {
      if (_timeInAt != null) {
        // Add current session duration to accumulated total
        _accumulatedTotal = _accumulatedTotal + sessionDuration;
      }
      
      _activeSessionId = null;
      _timeInAt = null;
      _isClockedIn = false;

      await _persistToStorage();
      
      debugPrint(
        '[ATTENDANCE_STORE] Time-Out completed: '
        'sessionDuration=${sessionDuration.inMinutes}min, '
        'newAccumulatedTotal=${_accumulatedTotal.inMinutes}min',
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('[ATTENDANCE_STORE] Error ending Time-In: $e');
    }
  }

  /// Update accumulated total (for timer accumulation across multiple sessions)
  Future<void> updateAccumulatedTotal(Duration total) async {
    try {
      _accumulatedTotal = total;
      await _persistToStorage();
      
      debugPrint(
        '[ATTENDANCE_STORE] Accumulated total updated: '
        '${_accumulatedTotal.inMinutes}min',
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('[ATTENDANCE_STORE] Error updating accumulated total: $e');
    }
  }

  /// Clear all state (for logout, etc.)
  Future<void> clear() async {
    try {
      _activeSessionId = null;
      _timeInAt = null;
      _accumulatedTotal = Duration.zero;
      _isClockedIn = false;
      _staffId = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyActiveSessionId);
      await prefs.remove(_keyTimeInAt);
      await prefs.remove(_keyAccumulatedTotal);
      await prefs.remove(_keyIsClockedIn);
      await prefs.remove(_keyStaffId);
      
      debugPrint('[ATTENDANCE_STORE] State cleared');
      
      notifyListeners();
    } catch (e) {
      debugPrint('[ATTENDANCE_STORE] Error clearing state: $e');
    }
  }

  /// Persist current state to SharedPreferences
  Future<void> _persistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_activeSessionId != null) {
        await prefs.setString(_keyActiveSessionId, _activeSessionId!);
      } else {
        await prefs.remove(_keyActiveSessionId);
      }
      
      if (_timeInAt != null) {
        await prefs.setString(_keyTimeInAt, _timeInAt!.toIso8601String());
      } else {
        await prefs.remove(_keyTimeInAt);
      }
      
      await prefs.setInt(_keyAccumulatedTotal, _accumulatedTotal.inSeconds);
      await prefs.setBool(_keyIsClockedIn, _isClockedIn);
      
      if (_staffId != null) {
        await prefs.setString(_keyStaffId, _staffId!);
      } else {
        await prefs.remove(_keyStaffId);
      }
    } catch (e) {
      debugPrint('[ATTENDANCE_STORE] Error persisting to storage: $e');
    }
  }

  /// Calculate current elapsed time for active session
  Duration getCurrentElapsed() {
    if (!_isClockedIn || _timeInAt == null) {
      return _accumulatedTotal;
    }
    
    final currentSessionElapsed = DateTime.now().difference(_timeInAt!);
    return _accumulatedTotal + currentSessionElapsed;
  }

  /// Sync with API data (call after fetching from API)
  Future<void> syncFromApi({
    String? sessionId,
    DateTime? timeInAt,
    Duration? accumulatedTotal,
    bool? isClockedIn,
    String? staffId,
  }) async {
    try {
      bool changed = false;
      
      if (sessionId != null && sessionId != _activeSessionId) {
        _activeSessionId = sessionId;
        changed = true;
      }
      
      if (timeInAt != null && timeInAt != _timeInAt) {
        _timeInAt = timeInAt;
        changed = true;
      }
      
      if (accumulatedTotal != null && accumulatedTotal != _accumulatedTotal) {
        _accumulatedTotal = accumulatedTotal;
        changed = true;
      }
      
      if (isClockedIn != null && isClockedIn != _isClockedIn) {
        _isClockedIn = isClockedIn;
        changed = true;
      }
      
      if (staffId != null && staffId != _staffId) {
        _staffId = staffId;
        changed = true;
      }
      
      if (changed) {
        await _persistToStorage();
        
        debugPrint(
          '[ATTENDANCE_STORE] Synced from API: '
          'isClockedIn=$_isClockedIn, '
          'sessionId=$_activeSessionId, '
          'timeInAt=$_timeInAt',
        );
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ATTENDANCE_STORE] Error syncing from API: $e');
    }
  }
}

