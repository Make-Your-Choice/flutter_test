import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_state_provider.g.dart';

@Riverpod()
class ConnectionState extends _$ConnectionState {
  bool _connectionState = true;

  @override
  FutureOr<bool> build() {
    return _connectionState;
  }

  Future<void> fetchNewState(bool newState) async {
    _connectionState = newState;
    ref.invalidateSelf();
    await future;
  }
}