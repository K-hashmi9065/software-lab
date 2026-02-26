import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class BusinessHoursState {
  /// The day currently being viewed/edited. Null = nothing selected.
  /// Only ONE day is focused at a time.
  final String? focusedDay;

  /// Persisted time-slot selections per day.
  /// Key = day label ('M','T','W','Th','F','S','Su')
  /// Value = set of selected slot strings for that day.
  final Map<String, Set<String>> dayTimeSlots;

  const BusinessHoursState({this.focusedDay, this.dayTimeSlots = const {}});

  BusinessHoursState copyWith({
    String? focusedDay,
    bool clearFocus = false,
    Map<String, Set<String>>? dayTimeSlots,
  }) {
    return BusinessHoursState(
      focusedDay: clearFocus ? null : (focusedDay ?? this.focusedDay),
      dayTimeSlots: dayTimeSlots ?? this.dayTimeSlots,
    );
  }

  /// Returns saved time slots for [day], or empty set if none saved.
  Set<String> slotsFor(String day) => dayTimeSlots[day] ?? {};
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class BusinessHoursNotifier extends StateNotifier<BusinessHoursState> {
  BusinessHoursNotifier() : super(const BusinessHoursState());

  /// Tap a day chip:
  /// - If that day is already focused → unfocus (hide time slots).
  /// - If another day (or none) is focused → switch focus to this day
  ///   and show its previously saved time slots.
  void tapDay(String day) {
    if (state.focusedDay == day) {
      // Tapping focused day again → unfocus
      state = state.copyWith(clearFocus: true);
    } else {
      // Switch focus (previous day's slots are already saved in dayTimeSlots)
      state = state.copyWith(focusedDay: day);
    }
  }

  /// Toggle a time slot for the currently focused day.
  /// Slots are saved persistently in [dayTimeSlots].
  void toggleSlot(String slot) {
    final focused = state.focusedDay;
    if (focused == null) return;

    final current = Set<String>.from(state.slotsFor(focused));
    if (current.contains(slot)) {
      current.remove(slot);
    } else {
      current.add(slot);
    }

    final updated = Map<String, Set<String>>.from(state.dayTimeSlots);
    updated[focused] = current;

    state = state.copyWith(dayTimeSlots: updated);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final businessHoursProvider =
    StateNotifierProvider<BusinessHoursNotifier, BusinessHoursState>(
      (ref) => BusinessHoursNotifier(),
    );
