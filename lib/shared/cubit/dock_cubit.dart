import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DockCubit extends Cubit<bool> {
  DockCubit() : super(true);

  void show() {
    if (!state) emit(true);
  }

  void hide() {
    if (state) emit(false);
  }

  void handleScroll(ScrollDirection direction) {
    switch (direction) {
      case ScrollDirection.forward:
        show();
        break;
      case ScrollDirection.reverse:
        hide();
        break;
      case ScrollDirection.idle:
        break;
    }
  }
}
