import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:startate/startate.dart';

import '../utils/main_utils.dart';

class TFSMoneyPercentageController {
  late final Rxn<Decimal> dataRx;
  Decimal? get data => dataRx.value;
  set data(Decimal? value) => dataRx.value = value;

  final RxBool _isPercentage = false.obs;
  bool get isPercentage => _isPercentage.value;
  set isPercentage(bool value) => _isPercentage.value = value;

  final Rx<TextEditingController> _controller = TextEditingController().obs;
  TextEditingController get controller => _controller.value;
  set controller(TextEditingController value) => _controller.value = value;

  void setData(Decimal value, bool isPercent) {
    isPercentage = isPercent;
    controller.text =
        isPercentage ? decimal2string(value) : decimal2money(value);
    data = value;
  }

  TFSMoneyPercentageController({bool percentage = false}) {
    dataRx = Rxn<Decimal>();
    isPercentage = percentage;
  }
}
