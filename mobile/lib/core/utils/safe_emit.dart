import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Drops emits that arrive after the cubit was closed.
///
/// A screen can be popped while its request is still in flight — likelier
/// now that a cold server may take a while to answer. The response then
/// lands on a closed cubit and `emit` throws "Cannot emit new states after
/// calling close". Nothing is listening any more, so ignoring it is correct.
mixin SafeEmit<S> on BlocBase<S> {
  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }
}
