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

  WorkoutBloc({
    required List<bool> initialCheckboxStates,
    required String email,
  })  : _firestore = FirebaseFirestore.instance,
        email = email,
        super(InitialWorkoutState(checkboxStates: initialCheckboxStates)) {
    on<UpdateCheckbox>(_onUpdateCheckbox);
    on<ResetWorkout>(_onResetWorkout);
  }

  Future<void> _onUpdateCheckbox(UpdateCheckbox event, Emitter<WorkoutState> emit) async {
    final newCheckboxStates = List<bool>.from(state.checkboxStates);
    newCheckboxStates[event.index] = event.value;
    
    // Mengecek apakah ini pertama kali checkbox dicentang
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

    // Logika untuk mengecek apakah semua checkbox sudah dicentang
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

  // Future<void> _onUpdateCheckbox(UpdateCheckbox event, Emitter<WorkoutState> emit) async {
  //   // print("Current state: ${state.checkboxStates}");
  //   final newCheckboxStates = List<bool>.from(state.checkboxStates);
  //   newCheckboxStates[event.index] = event.value;

  //   bool allChecked = newCheckboxStates.every((state) => state == true);
  //   // print("All checked: $allChecked");

  //   int newRemainingReps = state.remainingReps;
  //   bool isCompleted = state.isCompleted;

  //   if (allChecked) {
  //     // print("Reducing reps from: ${state.remainingReps}");
  //     newRemainingReps = state.remainingReps - 1;

  //     if (newRemainingReps <= 0) {
  //       isCompleted = true;
  //       final userDocs = await _firestore
  //           .collection('users')
  //           .where('email', isEqualTo: email)
  //           .get();
  //       if (userDocs.docs.isNotEmpty) {
  //         final user = userDocs.docs.first;
  //         await _firestore.collection('users').doc(user.id).update({
  //           'watched_videos': FieldValue.arrayUnion([event.videoUrl])
  //         });
  //       }
  //     }

  //     if (newRemainingReps > 0) {
  //       newCheckboxStates.fillRange(0, newCheckboxStates.length, false);
  //     }
  //   }

  //   emit(InitialWorkoutState(
  //     checkboxStates: newCheckboxStates,
  //     remainingReps: newRemainingReps,
  //     isCompleted: isCompleted,
  //   ));
  // }

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