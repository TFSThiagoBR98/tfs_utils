import 'package:flutter/material.dart';
import 'package:startate/startate.dart';

import 'tfs_text_controller.dart';

class TFSItemListController {
  final RxList<Map<String, String>> _items = <Map<String, String>>[].obs;
  List<Map<String, String>> get items => _items;
  set items(List<Map<String, String>> value) => _items.assignAll(value);

  final formKey = GlobalKey<FormState>();
  final TFSTextController<String> itemName = TFSTextController<String>();
  final TFSTextController<String> itemNumber = TFSTextController<String>();

  Map<String, String> addItem(String name, String item) {
    var valor = {
      'name': name,
      'item': item,
    };
    items.add(valor);
    return valor;
  }

  void resetFields() {
    itemName.setData('');
    itemNumber.setData('');
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void setData(List<Map<String, String>>? list) {
    items.addAll(list ?? []);
  }

  TFSItemListController();
}
