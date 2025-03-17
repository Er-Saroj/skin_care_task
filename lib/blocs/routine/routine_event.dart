import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../models/daily_routine.dart';

abstract class RoutineEvent extends Equatable {
  const RoutineEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoutine extends RoutineEvent {}

class ToggleStepCompletion extends RoutineEvent {
  final int stepIndex;

  const ToggleStepCompletion(this.stepIndex);

  @override
  List<Object> get props => [stepIndex];
}

class UpdateStepProduct extends RoutineEvent {
  final int stepIndex;
  final String productName;

  const UpdateStepProduct(this.stepIndex, this.productName);

  @override
  List<Object> get props => [stepIndex, productName];
}

class UploadStepPhoto extends RoutineEvent {
  final int stepIndex;
  final File photoFile;

  const UploadStepPhoto(this.stepIndex, this.photoFile);

  @override
  List<Object> get props => [stepIndex, photoFile];
}

class RoutineUpdated extends RoutineEvent {
  final DailyRoutine routine;

  const RoutineUpdated(this.routine);

  @override
  List<Object> get props => [routine];
}

