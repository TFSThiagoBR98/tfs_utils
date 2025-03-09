import 'package:flutter/material.dart';
import 'package:startate/startate.dart';

import '../pagination/models/paginated_items_response.dart';
import '../pagination/paginated_items_builder.dart';
import '../pagination/sliver_paginated_builder.dart';

class SelectListPaginate<T> extends StatefulWidget {
  const SelectListPaginate(
      {super.key,
      required this.onRefresh,
      required this.fetchPageData,
      required this.response,
      required this.itemBuilder,
      this.title,
      this.floatingActionButton,
      this.gridCrossAxisCount,
      this.gridMainAxisSpacing,
      this.gridCrossAxisSpacing,
      this.gridChildAspectRatio,
      this.restorationId,
      this.itemsDisplayType = ItemsDisplayType.list,
      this.onItemTap});

  final RefreshCallback onRefresh;
  final String? title;
  final Future<void> Function(bool reset) fetchPageData;
  final Rxn<PaginatedItemsResponse<T>> response;
  final ItemsDisplayType itemsDisplayType;
  final Widget? floatingActionButton;
  final VoidCallback? onItemTap;
  final int? gridCrossAxisCount;
  final double? gridMainAxisSpacing;
  final double? gridCrossAxisSpacing;
  final double? gridChildAspectRatio;
  final String? restorationId;
  final Widget Function(BuildContext, int, T) itemBuilder;

  @override
  State<SelectListPaginate<T>> createState() => _SelectListPaginateState<T>();
}

class _SelectListPaginateState<T> extends State<SelectListPaginate<T>> with RestorationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Selecione item para lista'),
        centerTitle: true,
      ),
      floatingActionButton: widget.floatingActionButton,
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child:
            Obx(() => CustomScrollView(restorationId: restorationId != null ? '$restorationId.scroll' : null, slivers: [
                  SliverPaginatedItemsBuilder<T>(
                    gridChildAspectRatio: widget.gridChildAspectRatio ?? 1,
                    gridCrossAxisCount: widget.gridCrossAxisCount ?? 2,
                    gridMainAxisSpacing: widget.gridMainAxisSpacing ?? 15,
                    gridCrossAxisSpacing: widget.gridCrossAxisSpacing ?? 15,
                    fetchPageData: widget.fetchPageData,
                    loaderItemsCount: 10,
                    restorationId: restorationId != null ? '$restorationId.paginator' : null,
                    emptyText: 'Não há o que selecionar.\nCadastre novo item para continuar.',
                    response: widget.response.value,
                    itemBuilder: (context, index, item) => GestureDetector(
                      onTap: widget.onItemTap ??
                          () {
                            Navigator.pop(context, item);
                          },
                      child: widget.itemBuilder(context, index, item),
                    ),
                  )
                ])),
      ),
    );
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {}
}
