import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlocAction<StateType, EventType> {
  const BlocAction();

  Future<void> invoke({
    required final StateType currentState,
    required final EventType event,
    required final Emitter<StateType> stateEmitter,
  });
}
