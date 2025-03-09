import 'package:startate/get_state_manager/get_state_manager.dart';

import 'tfs_state.dart';

abstract class TFSBaseController<S extends TFSState> extends GetxController {
  late S state;

  TFSBaseController(this.state);
}
