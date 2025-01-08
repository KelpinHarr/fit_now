import 'package:equatable/equatable.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();
  List<Object> get props => [];
}

class UpdateCheckbox extends WorkoutEvent {
  final int index;
  final bool value;
  final String videoUrl;
  final List<bool> allCheckboxStates;

  UpdateCheckbox({
    required this.index,
    required this.value,
    required this.videoUrl,
    required this.allCheckboxStates
  });
}

class ResetWorkout extends WorkoutEvent{}