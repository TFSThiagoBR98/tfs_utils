import 'package:flutter/material.dart';

import '../utils/func_utils.dart';
import 'tfs_app_state.dart';
import 'tfs_base_controller.dart';

abstract class TFSAppController<S extends TFSAppState> extends TFSBaseController<S> {
  TFSAppController(super.state);

  Future<void> runWhenContextAvaliable(FutureContextCallback callback) async {
    await Future.doWhile(() async {
      if (state.appRouter.navigatorKey.currentContext != null) {
        await callback(state.appRouter.navigatorKey.currentContext!);
        return false;
      } else {
        Future<void>.delayed(Duration(seconds: 1));
        return true;
      }
    });
  }

  Future<void> toggleBrightness() async {
    state.themeBrightness = state.themeBrightness == Brightness.dark ? Brightness.light : Brightness.dark;
  }
}
