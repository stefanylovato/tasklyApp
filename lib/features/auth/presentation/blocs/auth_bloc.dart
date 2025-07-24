import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_interfaces/auth_interfaces_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ILogin _login;
  final IRegister _register;
  final ILogout _logout;
  final IPersistLogin _persistLogin;

  AuthBloc({
    required ILogin login,
    required IRegister register,
    required ILogout logout,
    required IPersistLogin persistLogin,
  }) : _login = login,
       _register = register,
       _logout = logout,
       _persistLogin = persistLogin,
       super(AuthInitial()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _login(event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _register(event.name, event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await _logout();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthCheckStatusEvent>((event, emit) {
      emit(AuthLoading());
      _persistLogin().listen((user) {
        add(AuthStatusChangedEvent(user));
      });
    });

    on<AuthStatusChangedEvent>((event, emit) {
      if (event.user != null) {
        emit(AuthAuthenticated(event.user!));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
}
