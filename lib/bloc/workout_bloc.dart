import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './workout_event.dart';
import './workout_state.dart';

class InitialWorkoutState extends WorkoutState {
  InitialWorkoutState({
    required List<bool> checkboxStates,
    int remainingReps = 3,
    bool isCompleted = false,
  }) : super(
    checkboxStates: checkboxStates,
    remainingReps: remainingReps,
    isCompleted: isCompleted,
  );
}

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final FirebaseFirestore _firestore;
  final String email;

  WorkoutBloc({required List<bool> initialCheckboxStates, required String email}) : _firestore = FirebaseFirestore.instance, email = email,
    super(InitialWorkoutState(checkboxStates: initialCheckboxStates)) {
      on<UpdateCheckbox>(_onUpdateCheckbox);
      on<ResetWorkout>(_onResetWorkout);
      on<LoadSavedCheckboxStates>(_onLoadSavedCheckboxStates);
      on<UpdateRemainingReps>(_onUpdateRemainingReps);
  }

  Future<void> _onUpdateCheckbox(UpdateCheckbox event, Emitter<WorkoutState> emit) async {
    final newCheckboxStates = List<bool>.from(state.checkboxStates);
    newCheckboxStates[event.index] = event.value;
    
    if (event.value) {
      try {
        final userDocs = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
            
        if (userDocs.docs.isNotEmpty) {
          final user = userDocs.docs.first;
          await _firestore.collection('users').doc(user.id).update({
            'watched_videos': FieldValue.arrayUnion([event.videoUrl])
          });
        }
      } catch (e) {
        print("Error updating Firestore: $e");
      }
    }

    bool allChecked = newCheckboxStates.every((state) => state == true);
    int newRemainingReps = state.remainingReps;
    bool isCompleted = state.isCompleted;

    if (allChecked) {
      newRemainingReps = state.remainingReps - 1;
      if (newRemainingReps <= 0) {
        isCompleted = true;
      }
      if (newRemainingReps > 0) {
        newCheckboxStates.fillRange(0, newCheckboxStates.length, false);
      }
    }

    emit(InitialWorkoutState(
      checkboxStates: newCheckboxStates,
      remainingReps: newRemainingReps,
      isCompleted: isCompleted,
    ));
  }

  void _onLoadSavedCheckboxStates(LoadSavedCheckboxStates event, Emitter<WorkoutState> emit) {
    emit(ConcreteWorkoutState(
      checkboxStates: event.states,
      remainingReps: state.remainingReps,
      isCompleted: state.isCompleted,
    ));
  }

  void _onUpdateRemainingReps(UpdateRemainingReps event, Emitter<WorkoutState> emit){
    emit(ConcreteWorkoutState(
      checkboxStates: state.checkboxStates,
      remainingReps: event.remainingReps,
      isCompleted: event.remainingReps <= 0
    ));
  }

  void _onResetWorkout(
    ResetWorkout event,
    Emitter<WorkoutState> emit,
  ) {
    final resetCheckboxStates = List<bool>.generate(
      state.checkboxStates.length,
      (index) => false,
    );

    emit(InitialWorkoutState(
      checkboxStates: resetCheckboxStates,
      remainingReps: 3,
      isCompleted: false,
    ));
  }
}