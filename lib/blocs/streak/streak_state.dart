import 'package:equatable/equatable.dart';
import '../../models/streak_data.dart';

abstract class StreakState extends Equatable {
  const StreakState();
  
  @override
  List<Object?> get props => [];
}

class StreakInitial extends StreakState {}

class StreakLoading extends StreakState {}

class StreakLoaded extends StreakState {
  final StreakData streakData;
  final String selectedPeriod;
  
  const StreakLoaded(this.streakData, {this.selectedPeriod = '1M'});
  
  @override
  List<Object> get props => [streakData, selectedPeriod];
  
  StreakLoaded copyWith({
    StreakData? streakData,
    String? selectedPeriod,
  }) {
    return StreakLoaded(
      streakData ?? this.streakData,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

class StreakError extends StreakState {
  final String message;
  
  const StreakError(this.message);
  
  @override
  List<Object> get props => [message];
}

