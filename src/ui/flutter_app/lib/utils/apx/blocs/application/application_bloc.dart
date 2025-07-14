import 'package:flutter_bloc/flutter_bloc.dart';

import 'actions/application_begin_register_event_action.dart';
import 'events.dart';
import 'services/application_service.dart';
import 'services/online_application_service.dart';
import 'state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  late final ApplicationService _applicationService;
  ApplicationBloc() : super(const ApplicationInitialState()) {



    _applicationService = OnlineApplicationService();


    on<ApplicationBeginRegisterEvent>(
      (event, emit) =>
          ApplicationBeginRegisterEventAction(applicationService: _applicationService).invoke(currentState: state, event: event, stateEmitter: emit),
    );
  }
}
