import 'package:bujuan/features/auth/auth_state_store.dart';

class StartupSessionResolver {
  const StartupSessionResolver({
    AuthStateStore authStateStore = const AuthStateStore(),
  }) : _authStateStore = authStateStore;

  final AuthStateStore _authStateStore;

  bool get shouldOpenHome => _authStateStore.hasCachedSession;
}
