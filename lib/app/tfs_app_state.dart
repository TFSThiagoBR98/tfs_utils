import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:startate/get_rx/src/rx_types/rx_types.dart';

import 'tfs_auto_binder_view.dart';
import 'tfs_state.dart';

abstract class TFSAppState extends TFSState {
  TFSAppState(this.appRouter) : super() {
    init();
  }

  @override
  void init() {
    themeBrightness = _themeBrightnessSetting;
    _themeBrightness.value.listen((value) {
      _themeBrightnessSetting = value;
    });
  }

  final RootStackRouter appRouter;

  Brightness get _themeBrightnessSetting {
    final settings = Hive.box<dynamic>('settings');
    return Brightness.values.byName(settings.get('themeBrightness', defaultValue: Brightness.light.name) as String);
  }

  set _themeBrightnessSetting(Brightness value) {
    final settings = Hive.box<dynamic>('settings');
    settings.put('themeBrightness', value.name);
  }

  final RestorableRx<Brightness> _themeBrightness = Brightness.light.robs;
  Brightness get themeBrightness => _themeBrightness.value.value;
  set themeBrightness(Brightness value) => _themeBrightness.value.value = value;

  @override
  @mustCallSuper
  void restoreState(TFSFullViewState stateWidget, RestorationBucket? oldBucket, bool initialRestore) {
    stateWidget.registerRestore(_themeBrightness, 'settings.themeBrightness');
  }

  @override
  void dispose() {
    _themeBrightness.dispose();
  }
}
