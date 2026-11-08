import 'package:fantasy/shared/cubit/dock_cubit.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'scroll direction controls visibility without duplicate emissions',
    () async {
      final cubit = DockCubit();
      expect(cubit.state, isTrue);
      final emissions = cubit.stream.toList();

      cubit.handleScroll(ScrollDirection.reverse);
      cubit.handleScroll(ScrollDirection.reverse);
      cubit.handleScroll(ScrollDirection.idle);
      expect(cubit.state, isFalse);

      cubit.handleScroll(ScrollDirection.forward);
      cubit.handleScroll(ScrollDirection.forward);
      cubit.handleScroll(ScrollDirection.idle);
      expect(cubit.state, isTrue);

      cubit.hide();
      cubit.hide();
      cubit.show();
      cubit.show();

      await cubit.close();
      expect(await emissions, [false, true, false, true]);
    },
  );
}
