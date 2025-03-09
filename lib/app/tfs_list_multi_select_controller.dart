import 'package:flutter/material.dart';
import 'package:startate/startate.dart';

import '../pagination/models/paginated_items_response.dart';
import '../widgets/select_list_paginate.dart';
import 'tfs_list_item.dart';

class TFSListMultiSelectController<T> {
  TFSListMultiSelectController(
      {this.checkIcon = const Icon(Icons.check_box),
      this.uncheckIcon = const Icon(Icons.check_box_outline_blank),
      this.titleTextStyle = const TextStyle(
        fontSize: 18,
      ),
      required this.fetchPageData,
      required this.response,
      Map<String, TFSListItem<T>>? value}) {
    selectEntries.addAll(value ?? {});
  }

  final Future<void> Function({bool reset, bool showLoaderOnReset}) fetchPageData;

  final Rx<TextEditingController> _itemController = TextEditingController().obs;
  TextEditingController get itemController => _itemController.value;
  set itemController(TextEditingController value) => _itemController.value = value;

  final RxMap<String, TFSListItem<T>> _initialMap = <String, TFSListItem<T>>{}.obs;
  Map<String, TFSListItem<T>> get initialMap => _initialMap;
  set initialMap(Map<String, TFSListItem<T>> value) => _initialMap.assignAll(value);

  final RxMap<String, TFSListItem<T>> _selectEntries = <String, TFSListItem<T>>{}.obs;
  Map<String, TFSListItem<T>> get selectEntries => _selectEntries;
  set selectEntries(Map<String, TFSListItem<T>> value) => _selectEntries.assignAll(value);

  final Rxn<PaginatedItemsResponse<MapEntry<String, TFSListItem<T>>>> response;

  final TextStyle? titleTextStyle;

  final Widget? checkIcon;
  final Widget? uncheckIcon;

  void resetFields() {
    selectEntries.clear();
    itemController.text = '';
  }

  bool isSelected(MapEntry<String, TFSListItem<T>> item) {
    return selectEntries.containsKey(item.key);
  }

  String mountSelectList() {
    return selectEntries.values.map((e) => e).join(', ');
  }

  void selectItem(MapEntry<String, TFSListItem<T>> item) {
    selectEntries.addEntries([item]);
    itemController.text = mountSelectList();
  }

  void deselectItem(MapEntry<String, TFSListItem<T>> item) {
    selectEntries.remove(item.key);
    itemController.text = mountSelectList();
  }

  Map<String, TFSListItem<T>> getMapAdded() {
    Map<String, TFSListItem<T>> diff = {};
    for (final item in selectEntries.keys) {
      if (!initialMap.containsKey(item)) {
        diff[item] = selectEntries[item]!;
      }
    }
    return diff;
  }

  Map<String, TFSListItem<T>> getMapRemoved() {
    Map<String, TFSListItem<T>> diff = {};
    for (final item in initialMap.keys) {
      if (!selectEntries.containsKey(item)) {
        diff[item] = initialMap[item]!;
      }
    }
    return diff;
  }

  void showList(BuildContext context) {
    Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (context) => SelectListPaginate<MapEntry<String, TFSListItem<T>>>(
                onRefresh: () async => fetchPageData(reset: true, showLoaderOnReset: true),
                fetchPageData: (reset) => fetchPageData(reset: reset, showLoaderOnReset: reset),
                response: response,
                onItemTap: () {},
                title: 'Selecione um ou mais itens',
                floatingActionButton: FloatingActionButton.extended(
                  label: const Text('Salvar'),
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    Navigator.of(context).pop(selectEntries);
                  },
                ),
                itemBuilder: (context, index, item) {
                  return Obx(
                    () => ListTile(
                      leading: isSelected(item) ? checkIcon : uncheckIcon,
                      title: Text(
                        item.value.label,
                        style: titleTextStyle,
                      ),
                      onTap: () {
                        if (isSelected(item)) {
                          deselectItem(item);
                        } else {
                          selectItem(item);
                        }
                      },
                    ),
                  );
                })));
  }
}
