import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaipur/repositories/routine_repo.dart';
import 'routine_event.dart';
import 'routine_state.dart';

class RoutineBloc extends Bloc<RoutineEvent, RoutineState> {
  final RoutineRepository routineRepository;
  
  RoutineBloc({required this.routineRepository}) : super(RoutineInitial()) {
    on<LoadRoutine>(_onLoadRoutine);
    on<ToggleStepCompletion>(_onToggleStepCompletion);
    on<UpdateStepProduct>(_onUpdateStepProduct);
    on<UploadStepPhoto>(_onUploadStepPhoto);
    on<RoutineUpdated>(_onRoutineUpdated);
  }
  
  Future<void> _onLoadRoutine(LoadRoutine event, Emitter<RoutineState> emit) async {
    // Only show loading state if we're not already loaded
    if (state is! RoutineLoaded) {
      emit(RoutineLoading());
    }
    
    try {
      final routine = await routineRepository.getTodayRoutine();
      emit(RoutineLoaded(routine));
    } catch (e) {
      emit(RoutineError('Failed to load routine: $e'));
    }
  }
  
  Future<void> _onToggleStepCompletion(ToggleStepCompletion event, Emitter<RoutineState> emit) async {
    if (state is RoutineLoaded) {
      final currentState = state as RoutineLoaded;
      
      // Optimistic update for better UX
      final step = currentState.routine.steps[event.stepIndex];
      final optimisticStep = step.copyWith(
        isCompleted: !step.isCompleted,
        timestamp: DateTime.now(),
      );
      
      final optimisticRoutine = currentState.routine.updateStep(
        event.stepIndex, 
        optimisticStep
      );
      
      emit(RoutineLoaded(optimisticRoutine));
      
      try {
        final updatedRoutine = await routineRepository.toggleStepCompletion(
          currentState.routine, 
          event.stepIndex
        );
        emit(RoutineLoaded(updatedRoutine));
        add(RoutineUpdated(updatedRoutine));
      } catch (e) {
        // Revert to original state on error
        emit(RoutineLoaded(currentState.routine));
        emit(RoutineError('Failed to toggle step completion: $e'));
      }
    }
  }
  
  Future<void> _onUpdateStepProduct(UpdateStepProduct event, Emitter<RoutineState> emit) async {
    if (state is RoutineLoaded) {
      final currentState = state as RoutineLoaded;
      
      // Optimistic update
      final step = currentState.routine.steps[event.stepIndex];
      final optimisticStep = step.copyWith(productName: event.productName);
      
      final optimisticRoutine = currentState.routine.updateStep(
        event.stepIndex, 
        optimisticStep
      );
      
      emit(RoutineLoaded(optimisticRoutine));
      
      try {
        final updatedRoutine = await routineRepository.updateStepProduct(
          currentState.routine, 
          event.stepIndex, 
          event.productName
        );
        emit(RoutineLoaded(updatedRoutine));
      } catch (e) {
        // Revert to original state on error
        emit(RoutineLoaded(currentState.routine));
        emit(RoutineError('Failed to update product: $e'));
      }
    }
  }
  
  Future<void> _onUploadStepPhoto(UploadStepPhoto event, Emitter<RoutineState> emit) async {
    if (state is RoutineLoaded) {
      final currentState = state as RoutineLoaded;
      
      // Show loading state but keep the current routine visible
      emit(RoutineLoading());
      
      try {
        final updatedRoutine = await routineRepository.uploadStepPhoto(
          currentState.routine, 
          event.stepIndex, 
          event.photoFile
        );
        emit(RoutineLoaded(updatedRoutine));
        add(RoutineUpdated(updatedRoutine));
      } catch (e) {
        // Revert to original state on error
        emit(RoutineLoaded(currentState.routine));
        emit(RoutineError('Failed to upload photo: $e'));
      }
    }
  }
  
  void _onRoutineUpdated(RoutineUpdated event, Emitter<RoutineState> emit) {
    // This event is used to notify other blocs about routine updates
    // No state change needed here
  }
}

