import 'routine_step.dart';

class DailyRoutine {
  final String id;
  final DateTime date;
  final List<RoutineStep> steps;
  final bool isCompleted;

  DailyRoutine({
    required this.id,
    required this.date,
    required this.steps,
    this.isCompleted = false,
  });

  factory DailyRoutine.create() {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    
    return DailyRoutine(
      id: id,
      date: DateTime(now.year, now.month, now.day),
      steps: [
        RoutineStep.fromType(StepType.cleanser),
        RoutineStep.fromType(StepType.toner),
        RoutineStep.fromType(StepType.moisturizer),
        RoutineStep.fromType(StepType.sunscreen),
        RoutineStep.fromType(StepType.lipBalm),
      ],
    );
  }

  bool get allStepsCompleted => 
      steps.every((step) => step.isCompleted);

  DailyRoutine copyWith({
    String? id,
    DateTime? date,
    List<RoutineStep>? steps,
    bool? isCompleted,
  }) {
    return DailyRoutine(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  DailyRoutine updateStep(int index, RoutineStep updatedStep) {
    final newSteps = List<RoutineStep>.from(steps);
    newSteps[index] = updatedStep;
    
    return copyWith(
      steps: newSteps,
      isCompleted: newSteps.every((step) => step.isCompleted),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'steps': steps.map((step) => step.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory DailyRoutine.fromMap(Map<String, dynamic> map) {
    return DailyRoutine(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      steps: List<RoutineStep>.from(
        (map['steps'] as List).map((step) => RoutineStep.fromMap(step)),
      ),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

