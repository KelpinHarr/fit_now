import 'package:equatable/equatable.dart';

abstract class WorkoutState extends Equatable {
  final List<bool> checkboxStates;
  final int remainingReps;
  final bool isCompleted;

  WorkoutState({
    required this.checkboxStates,
    this.remainingReps = 3,
    this.isCompleted = false,
  });

  @override
  List<Object> get props => [checkboxStates, remainingReps, isCompleted];
}

class ConcreteWorkoutState extends WorkoutState {
  ConcreteWorkoutState({
    required List<bool> checkboxStates,
    int remainingReps = 3,
    bool isCompleted = false,
  }) : super(
          checkboxStates: checkboxStates,
          remainingReps: remainingReps,
          isCompleted: isCompleted,
        );

  ConcreteWorkoutState copyWith({
    List<bool>? checkboxStates,
    int? remainingReps,
    bool? isCompleted,
  }) {
    return ConcreteWorkoutState(
      checkboxStates: checkboxStates ?? this.checkboxStates,
      remainingReps: remainingReps ?? this.remainingReps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}