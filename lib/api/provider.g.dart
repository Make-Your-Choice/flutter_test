// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskHash() => r'31d8bcce7f4936e5adf835975fe2f02cdd699bca';

/// See also [Task].
@ProviderFor(Task)
final taskProvider =
    AutoDisposeAsyncNotifierProvider<Task, List<TaskData>>.internal(
  Task.new,
  name: r'taskProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Task = AutoDisposeAsyncNotifier<List<TaskData>>;
String _$tagHash() => r'c6440596dc7f290cf11b53495b2cdb406b54339c';

/// See also [Tag].
@ProviderFor(Tag)
final tagProvider =
    AutoDisposeAsyncNotifierProvider<Tag, List<TagData>>.internal(
  Tag.new,
  name: r'tagProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tagHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Tag = AutoDisposeAsyncNotifier<List<TagData>>;
String _$tokenStateHash() => r'b273096911ad4db551e6c69c01509ddf24b894b8';

/// See also [TokenState].
@ProviderFor(TokenState)
final tokenStateProvider =
    AutoDisposeAsyncNotifierProvider<TokenState, bool>.internal(
  TokenState.new,
  name: r'tokenStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tokenStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokenState = AutoDisposeAsyncNotifier<bool>;
String _$connectionStateHash() => r'22fe0ea6cba4d2cc0079ed04f812534f4117c82b';

/// See also [ConnectionState].
@ProviderFor(ConnectionState)
final connectionStateProvider =
    AutoDisposeAsyncNotifierProvider<ConnectionState, bool>.internal(
  ConnectionState.new,
  name: r'connectionStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectionStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectionState = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
