import 'package:equatable/equatable.dart';
import '../../models/daily_routine.dart';

abstract class RoutineState extends Equatable {
  const RoutineState();
  
  @override
  List<Object?> get props => [];
}

class RoutineInitial extends RoutineState {}

class RoutineLoading extends RoutineState {}

class RoutineLoaded extends RoutineState {
  final DailyRoutine routine;
  
  const RoutineLoaded(this.routine);
  
  @override
  List<Object> get props => [routine];
}

class RoutineError extends RoutineState {
  final String message;
  
  const RoutineError(this.message);
  
  @override
  List<Object> get props => [message];
}

