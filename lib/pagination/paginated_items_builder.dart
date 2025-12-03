import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'models/paginated_items_builder_config.dart';
import 'models/paginated_items_response.dart';

/// enum used to check how the list items are to be rendered on the screen.
/// Whether in a list view or a grid view.
enum ItemsDisplayType {
  /// Render the items in a list view
  list,

  /// Render the items in a grid view
  grid,
}

/// Handles rendering the items on the screen. Can have [PaginationItemsStateHandler]
/// as parent if state is not handled externally.
class PaginatedItemsBuilder<T> extends StatefulWidget {
  const PaginatedItemsBuilder({
    super.key,
    required this.fetchPageData,
    required this.response,
    required this.itemBuilder,
    this.itemsDisplayType = ItemsDisplayType.list,
    this.shrinkWrap = false,
    this.paginate = true,
    this.showRefreshIcon = true,
    this.neverScrollablePhysicsOnShrinkWrap = true,
    this.loader = const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
    this.loaderItemsCount = 6,
    this.scrollController,
    this.padding,
    this.emptyText,
    this.maxLength,
    this.separatorWidget,
    this.listItemsGap,
    this.reverse = false,
    this.withRefreshIndicator = true,
    this.gridCrossAxisCount,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.gridChildAspectRatio,
    this.gridDelegate,
    this.scrollDirection = Axis.vertical,
    this.scrollPhysics,
    bool? scrollPrimary,
  }) : scrollPrimary = scrollPrimary ?? scrollController == null && identical(scrollDirection, Axis.vertical);

  /// This is the controller function that should handle fetching the list
  /// and updating in the state.
  ///
  /// The boolean in the callback is the reset flag. If that is true, that means
  /// either the user wants to refresh the list with pull-down refresh, or no items
  /// were found, and user clicked the refresh icon.
  ///
  /// If state is handled using [PaginationItemsStateHandler],
  /// then the builder in it provides this argument and should be passed directly.
  final Future<void> Function(bool reset) fetchPageData;

  /// Callback function which requires a widget that is rendered for each item.
  /// Provides context, index of the item in the list and the item itself.
  final Widget Function(BuildContext, int, T) itemBuilder;

  /// The response object whose contents are displayed.
  final PaginatedItemsResponse<T>? response;

  /// Pass in a custom scroll controller if needed.
  final ScrollController? scrollController;

  /// Scroll direction of the list/grid view
  final Axis scrollDirection;

  /// {@template flutter.widgets.scroll_view.reverse}
  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  /// {@endtemplate}
  final bool reverse;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Defaults to false
  final bool shrinkWrap;

  /// {@template flutter.widgets.scroll_view.physics}
  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions. Furthermore, if [primary] is
  /// false, then the user cannot scroll if there is insufficient content to
  /// scroll, while if [primary] is true, they can always attempt to scroll.
  ///
  /// To force the scroll view to always be scrollable even if there is
  /// insufficient content, as if [primary] was true but without necessarily
  /// setting it to true, provide an [AlwaysScrollableScrollPhysics] physics
  /// object, as in:
  ///
  /// ```dart
  ///   physics: const AlwaysScrollableScrollPhysics(),
  /// ```
  ///
  /// To force the scroll view to use the default platform conventions and not
  /// be scrollable if there is insufficient content, regardless of the value of
  /// [primary], provide an explicit [ScrollPhysics] object, as in:
  ///
  /// ```dart
  ///   physics: const ScrollPhysics(),
  /// ```
  ///
  /// The physics can be changed dynamically (by providing a new object in a
  /// subsequent build), but new physics will only take effect if the _class_ of
  /// the provided object changes. Merely constructing a new instance with a
  /// different configuration is insufficient to cause the physics to be
  /// reapplied. (This is because the final object used is generated
  /// dynamically, which can be relatively expensive, and it would be
  /// inefficient to speculatively create this object each frame to see if the
  /// physics should be updated.)
  /// {@endtemplate}
  ///
  /// If an explicit [ScrollBehavior] is provided to [scrollBehavior], the
  /// [ScrollPhysics] provided by that behavior will take precedence after
  /// [physics].
  final ScrollPhysics? scrollPhysics;

  /// {@template flutter.widgets.scroll_view.primary}
  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// When this is true, the scroll view is scrollable even if it does not have
  /// sufficient content to actually scroll. Otherwise, by default the user can
  /// only scroll the view if it has sufficient content. See [physics].
  ///
  /// Also when true, the scroll view is used for default [ScrollAction]s. If a
  /// ScrollAction is not handled by an otherwise focused part of the application,
  /// the ScrollAction will be evaluated using this scroll view, for example,
  /// when executing [Shortcuts] key events like page up and down.
  ///
  /// On iOS, this also identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  /// {@endtemplate}
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? scrollPrimary;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// Useful when the [PaginatedItemsBuilder] is a child of another scrollable,
  /// then the physics should be [NeverScrollableScrollPhysics] as it conflicts.
  /// Hence, if true, it overrides the [shrinkWrap] property as [shrinkWrap]
  /// should be true if the [PaginatedItemsBuilder] is inside another scrollable
  /// widget.
  final bool neverScrollablePhysicsOnShrinkWrap;

  /// The text to show if no items are present.
  final String? emptyText;

  /// If no items are there to display, shows a refresh icon to again call the
  /// API to update the results.
  final bool showRefreshIcon;

  /// RefreshIndicator is avaliable
  final bool withRefreshIndicator;

  /// Whether to paginate a specific list of items or not. Defaults to true.
  final bool paginate;

  /// Separator for items in a list view.
  final Widget? separatorWidget;

  /// Limits the item count no matter what the length of the content is in the
  /// [response.items].
  final int? maxLength;

  /// The number of loader widgets to render before the data is fetched for the
  /// first time.
  final int loaderItemsCount;

  /// Whether to display items in a list view or grid view.
  final ItemsDisplayType itemsDisplayType;

  /// The loader to render if mockItem not found from [PaginatedItemsBuilderConfig].
  final Widget loader;

  /// config
  static PaginatedItemsBuilderConfig? config;

  /// The gap between concurrent list items.
  /// Has no effect if [separatorWidget] is not null.
  final double? listItemsGap;

  // grid
  final int? gridCrossAxisCount;
  final double? gridMainAxisSpacing;
  final double? gridCrossAxisSpacing;
  final double? gridChildAspectRatio;

  /// A delegate that controls the layout of the children within the [GridView].
  ///
  /// The [GridView], [GridView.builder], and [GridView.custom] constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverGridDelegate? gridDelegate;

  @override
  State<PaginatedItemsBuilder<T>> createState() => _PaginatedItemsBuilderState<T>();
}

class _PaginatedItemsBuilderState<T> extends State<PaginatedItemsBuilder<T>> {
  ScrollController? _scrollController;

  bool _initialLoading = true;
  bool _loadingMoreData = false;

  final _loaderKey = UniqueKey();

  late bool showLoader;
  late ScrollController? itemsScrollController;
  late ScrollPhysics? scrollPhysics;
  late int itemCount;
  late T? mockItem;

  Future<void> fetchData({bool reset = false}) async {
    if (!mounted) return;
    if (!reset && (widget.response != null && !widget.response!.hasMoreData && !_loadingMoreData)) return;
    setState(() {
      if (_initialLoading) {
        _initialLoading = false;
      } else if (reset) {
        _initialLoading = true;
      } else {
        _loadingMoreData = true;
      }
    });

    try {
      await widget.fetchPageData(reset);
    } catch (_) {}

    if (_initialLoading) _initialLoading = false;
    if (_loadingMoreData) _loadingMoreData = false;
    try {
      setState(() {});
    } catch (_) {}
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (widget.response?.items != null) {
      if (widget.response!.items!.length <= index) return _loaderBuilder();
      final item = widget.response!.items![index];
      return widget.itemBuilder(context, index, item);
    } else {
      return _loaderBuilder();
    }
  }

  Widget _loaderBuilder() {
    Widget buildLoader() => mockItem != null
        ? Shimmer.fromColors(
            highlightColor: PaginatedItemsBuilder.config!.shimmerConfig.highlightColor,
            baseColor: PaginatedItemsBuilder.config!.shimmerConfig.baseColor,
            period: PaginatedItemsBuilder.config!.shimmerConfig.period,
            child: IgnorePointer(
              child: widget.itemBuilder(context, 0, mockItem as T),
            ),
          )
        : widget.loader;

    return widget.paginate
        ? VisibilityDetector(
            key: _loaderKey,
            onVisibilityChanged: (_) => fetchData(),
            child: buildLoader(),
          )
        : buildLoader();
  }

  Widget _emptyWidget([String? text]) {
    final itemName = T.toString().toLowerCase().replaceAll('lean', '');
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              text ?? PaginatedItemsBuilder.config!.noItemsTextGetter(itemName),
              style: PaginatedItemsBuilder.config!.noItemsTextStyle,
              overflow: TextOverflow.clip,
            ),
          ),
          if (widget.showRefreshIcon)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => fetchData(reset: true),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _scrollController = widget.scrollController ?? (widget.scrollPrimary == true ? null : ScrollController());

    mockItem = PaginatedItemsBuilder.config?.mockItemGetter<T>();

    if (widget.response?.items == null) fetchData();
    // if (widget.paginate) {
    // _scrollController.addListener(() {
    //   final pos = _scrollController.position;
    //   if (pos.maxScrollExtent == pos.pixels) fetchData();
    // });
    // }

    PaginatedItemsBuilder.config ??= PaginatedItemsBuilderConfig.defaultConfig();

    super.initState();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showLoader = (widget.paginate && (widget.response?.hasMoreData ?? false));
    itemsScrollController = widget.scrollController == null ? _scrollController : null;
    scrollPhysics = widget.scrollPhysics ??
        (widget.scrollPrimary == true ||
                (widget.scrollPrimary == null &&
                    widget.scrollController == null &&
                    identical(widget.scrollDirection, Axis.vertical))
            ? const AlwaysScrollableScrollPhysics()
            : null);

    if (widget.shrinkWrap && widget.neverScrollablePhysicsOnShrinkWrap && widget.scrollPhysics == null) {
      scrollPhysics = const NeverScrollableScrollPhysics();
    }

    (() {
      final itemsLen = (widget.response?.items?.length ?? widget.loaderItemsCount) + (showLoader ? 1 : 0);
      itemCount = widget.maxLength == null ? itemsLen : min(itemsLen, widget.maxLength!);
    })();

    if (widget.response?.items?.isEmpty ?? false) {
      return _emptyWidget(widget.emptyText);
    } else if (widget.response?.items == null && mockItem == null) {
      return _loaderBuilder();
    } else if (widget.shrinkWrap || !widget.withRefreshIndicator) {
      return _buildItems();
    } else {
      return RefreshIndicator(
        displacement: 10,
        onRefresh: () async => await fetchData(reset: true),
        child: _buildItems(),
      );
    }
  }

  Widget _buildItems() => widget.itemsDisplayType == ItemsDisplayType.list ? _buildListView() : _buildGridView();

  ListView _buildListView() {
    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics: scrollPhysics,
      controller: itemsScrollController,
      primary: widget.scrollPrimary,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      itemBuilder: _itemBuilder,
      padding: widget.padding,
      separatorBuilder: (_, __) =>
          widget.separatorWidget ??
          SizedBox(
            width: widget.listItemsGap,
            height: widget.listItemsGap,
          ),
      itemCount: itemCount,
    );
  }

  GridView _buildGridView() {
    return GridView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: scrollPhysics,
      controller: itemsScrollController,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      itemBuilder: _itemBuilder,
      gridDelegate: widget.gridDelegate ??
          SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: widget.gridChildAspectRatio ?? 1,
            crossAxisCount: widget.gridCrossAxisCount ?? 2,
            mainAxisSpacing: widget.gridMainAxisSpacing ?? 15,
            crossAxisSpacing: widget.gridCrossAxisSpacing ?? 15,
          ),
      padding: widget.padding,
      itemCount: itemCount,
    );
  }
}
