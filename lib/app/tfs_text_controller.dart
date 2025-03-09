import 'package:flutter/material.dart';
import 'package:startate/startate.dart';

class TFSTextController<V> {
  final RxnString dataRx = RxnString();
  String? get data => dataRx.value;
  set data(String? value) => dataRx.value = value;

  final Rx<TextEditingController> _controller = TextEditingController().obs;
  TextEditingController get controller => _controller.value;
  set controller(TextEditingController value) => _controller.value = value;

  void setData(String? value) {
    data = value;
    controller.text = value ?? '';
  }

  TFSTextController();
}
