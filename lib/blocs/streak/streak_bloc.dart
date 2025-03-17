// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaipur/repositories/routine_repo.dart';
import 'package:jaipur/repositories/streak_repo.dart';
import 'streak_event.dart';
import 'streak_state.dart';

class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final StreakRepository streakRepository;
  final RoutineRepository routineRepository;
  
  StreakBloc({
    required this.streakRepository,
    required this.routineRepository,
  }) : super(StreakInitial()) {
    on<LoadStreak>(_onLoadStreak);
    on<UpdateStreakWithRoutine>(_onUpdateStreakWithRoutine);
    on<SetTargetStreak>(_onSetTargetStreak);
    on<StreakUpdated>(_onStreakUpdated);
  }
  
  Future<void> _onLoadStreak(LoadStreak event, Emitter<StreakState> emit) async {
    emit(StreakLoading());
    try {
      final streakData = await streakRepository.getStreakData();
      emit(StreakLoaded(streakData));
    } catch (e) {
      emit(StreakError('Failed to load streak data: $e'));
    }
  }
  
  Future<void> _onUpdateStreakWithRoutine(UpdateStreakWithRoutine event, Emitter<StreakState> emit) async {
    if (state is StreakLoaded) {
      final currentState = state as StreakLoaded;
      try {
        final updatedStreakData = await streakRepository.updateStreakWithRoutine(
          currentState.streakData, 
          event.routine
        );
        emit(currentState.copyWith(streakData: updatedStreakData));
      } catch (e) {
        emit(StreakError('Failed to update streak: $e'));
      }
    }
  }
  
  Future<void> _onSetTargetStreak(SetTargetStreak event, Emitter<StreakState> emit) async {
    if (state is StreakLoaded) {
      final currentState = state as StreakLoaded;
      try {
        final updatedStreakData = await streakRepository.setTargetStreak(
          currentState.streakData, 
          event.target
        );
        emit(currentState.copyWith(streakData: updatedStreakData));
      } catch (e) {
        emit(StreakError('Failed to set target streak: $e'));
      }
    }
  }
  
  void _onStreakUpdated(StreakUpdated event, Emitter<StreakState> emit) {
    if (state is StreakLoaded) {
      final currentState = state as StreakLoaded;
      emit(currentState.copyWith(streakData: event.streakData));
    }
  }
  
  void updateSelectedPeriod(String period) {
    if (state is StreakLoaded) {
      final currentState = state as StreakLoaded;
      emit(currentState.copyWith(selectedPeriod: period));
    }
  }
}

