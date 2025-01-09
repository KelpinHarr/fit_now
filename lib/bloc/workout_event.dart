import 'package:equatable/equatable.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();
  List<Object> get props => [];
}

class UpdateCheckbox extends WorkoutEvent {
  final int index;
  final bool value;
  final String videoUrl;
  final String email;
  final List<bool> allCheckboxStates;

  UpdateCheckbox({
    required this.index,
    required this.value,
    required this.videoUrl,
    required this.email,
    required this.allCheckboxStates
  });

  @override
  List<Object> get props => [index, value, videoUrl, email, allCheckboxStates];
}

class LoadSavedCheckboxStates extends WorkoutEvent {
  final List<bool> states;
  final String videoUrl;

  const LoadSavedCheckboxStates({
    required this.states,
    required this.videoUrl
  });

  @override
  List<Object> get props => [states, videoUrl];
}

class ResetWorkout extends WorkoutEvent{}