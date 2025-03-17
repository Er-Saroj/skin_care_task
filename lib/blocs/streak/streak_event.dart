import 'package:equatable/equatable.dart';
import '../../models/daily_routine.dart';
import '../../models/streak_data.dart';

abstract class StreakEvent extends Equatable {
  const StreakEvent();

  @override
  List<Object?> get props => [];
}

class LoadStreak extends StreakEvent {}

class UpdateStreakWithRoutine extends StreakEvent {
  final DailyRoutine routine;

  const UpdateStreakWithRoutine(this.routine);

  @override
  List<Object> get props => [routine];
}

class SetTargetStreak extends StreakEvent {
  final int target;

  const SetTargetStreak(this.target);

  @override
  List<Object> get props => [target];
}

class StreakUpdated extends StreakEvent {
  final StreakData streakData;

  const StreakUpdated(this.streakData);

  @override
  List<Object> get props => [streakData];
}

