import 'package:flutter/material.dart';
import 'package:startate/startate.dart';

import 'tfs_base_controller.dart';
import 'tfs_state.dart';

abstract class TFSAutoBinderView<C extends TFSBaseController, S extends TFSState> extends GetView<C> {
  TFSAutoBinderView({super.key, Binding? binding}) {
    binding?.dependencies();
  }

  S get state => controller.state as S;
}

abstract class TFSFullView extends StatefulWidget {
  TFSFullView({super.key, Binding? binding}) {
    binding?.dependencies();
  }
}

abstract class TFSFullViewState<L extends StatefulWidget, T extends TFSBaseController, S extends TFSState>
    extends State<L> with RestorationMixin {
  final String? tag = null;

  T get controller => Get.find<T>(tag: tag);

  S get state => controller.state as S;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    state.restoreState(this, oldBucket, initialRestore);
  }

  @override
  void dispose() {
    super.dispose();
    state.dispose();
  }

  @override
  Widget build(BuildContext context);
}
