import 'package:flutter/material.dart';

import 'tfs_auto_binder_view.dart';

abstract class TFSState {
  TFSState() {
    init();
  }

  void init();

  void resetState();

  void restoreState(TFSFullViewState stateWidget, RestorationBucket? oldBucket, bool initialRestore);

  void dispose();
}
