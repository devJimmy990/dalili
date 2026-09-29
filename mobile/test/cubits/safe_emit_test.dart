import 'package:dalili/core/utils/safe_emit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _CounterCubit extends Cubit<int> with SafeEmit<int> {
  _CounterCubit() : super(0);

  void set(int value) => emit(value);
}

void main() {
  test('emit after close is ignored instead of throwing', () async {
    final cubit = _CounterCubit();
    await cubit.close();

    expect(() => cubit.set(1), returnsNormally);
    expect(cubit.state, 0);
  });

  test('emit before close still works', () {
    final cubit = _CounterCubit()..set(5);
    expect(cubit.state, 5);
  });
}
