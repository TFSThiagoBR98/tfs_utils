import 'package:flutter/material.dart';

import '../tfs_utils.dart';

/// Do not have a controller for a list of items? Or do not want to create one just because of
/// one time use, use [PaginationItemsStateHandler], it handles the state internally and
/// wraps above a [PaginatedItemsBuilder].
///
/// The [itemsBuilder] provides the required arguments needed by the [PaginatedItemsBuilder].
class PaginationItemsStateHandler<T> extends StatefulWidget {
  /// Pass in a function that calls the API and returns a [PaginatedItemsResponse].
  final Future<PaginatedItemsResponse<T>?> Function(String? paginationKey)
      pageFetchData;

  /// Callback method that usually should return a [PaginatedItemsBuilder] and
  /// pass the [response] and [fetchPageData] params to the builder.
  final Widget Function(
    PaginatedItemsResponse<T>? response,
    Future<void> Function(bool) fetchPageData,
  ) itemsBuilder;

  const PaginationItemsStateHandler({
    super.key,
    required this.pageFetchData,
    required this.itemsBuilder,
  });

  @override
  State<PaginationItemsStateHandler<T>> createState() =>
      _PaginationItemsStateHandlerState<T>();
}

class _PaginationItemsStateHandlerState<T>
    extends State<PaginationItemsStateHandler<T>> {
  PaginatedItemsResponse<T>? itemsResponse;

  Future<void> _update(bool reset) async {
    if (reset) {
      itemsResponse = null;
      markNeedsBuild();
    }

    try {
      final res =
          await widget.pageFetchData(itemsResponse?.paginationKey as String?);
      if (itemsResponse == null) {
        itemsResponse = res;
      } else {
        itemsResponse!.update(res!);
      }
    } catch (_) {}

    try {
      markNeedsBuild();
    } catch (_) {}
  }

  @override
  void initState() {
    _update(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.itemsBuilder(itemsResponse, _update);
  }

  @override
  // ignore: override_on_non_overriding_member
  void markNeedsBuild() {
    // ignore: undefined_super_method
    super.markNeedsBuild();
  }
}
