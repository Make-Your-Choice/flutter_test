import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_state_provider.g.dart';

@Riverpod()
class ConnectionState extends _$ConnectionState {
  bool connectionState = true;

  @override
  FutureOr<bool> build() {
    return connectionState;
  }

  Future<void> fetchNewState(bool newState) async {
    connectionState = newState;
    ref.invalidateSelf();
    await future;
  }
}