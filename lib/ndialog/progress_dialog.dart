// PART OF NDIALOG PACKAGE
// Copyright (c) 2019 Mochamad Nizwar Syafuan

import 'package:flutter/material.dart';

import 'utils.dart';

abstract class _ProgressDialog {
  ///You can set title of dialog using this function,
  ///even the dialog already pop up
  void setTitle(Widget title);

  ///You can set loading widget of dialog using this function,
  ///even the dialog already pop up.
  ///Set it Null to change it as default CircularProgressIndicator or loadingWidget that already you set before
  void setLoadingWidget(Widget loadingWidget);

  ///You can set background / barrier color of dialog using this function,
  ///even the dialog already pop up.
  ///Set it Null to change it as default
  void setBackgroundColor(Color color);

  ///You can set message of dialog using this function,
  ///even the dialog already pop up
  void setMessage(Widget message);
}

///Simple progress dialog with blur background and popup animations, use DialogStyle to custom it
///inspired by ProgressDialog from Android Native, and it very simple to use
class ProgressDialog implements _ProgressDialog {
  ///The context
  final BuildContext context;

  ///Custom dialog style
  final DialogStyle? dialogStyle;

  ///The (optional) title of the progress dialog is displayed in a large font at the top of the dialog.
  final Widget? title;

  ///The (optional) message of the progress dialog is displayed in the center of the dialog in a lighter font.
  final Widget? message;

  //
  final Widget Function(Function onDismissed)? cancelButtonWidget;

  ///The (optional) default progress widget that are displayed before message of the dialog,
  ///it will replaced when you use setLoadingWidget, and it will restored if you `setLoadingWidget(null)`.
  final Widget? defaultLoadingWidget;

  ///Is your dialog dismissable?, because its warp by BlurDialogBackground,
  ///you have to declare here instead on showDialog
  final bool? dismissable;

  ///Action on dialog dismissing
  final Function? onDismiss;

  ///Blur on background
  final double? blur;

  ///Dialog Barrier background color
  final Color? backgroundColor;

  ///Dialog Transition Type
  final DialogTransitionType? dialogTransitionType;

  ///Dialog Transition Duration
  final Duration? transitionDuration;

  bool _show = false;

  // ignore: strict_raw_type
  Route? _route;

  bool get isShowed => _show;

  _ProgressDialogWidget? _progressDialogWidget;

  ProgressDialog(this.context,
      {this.dialogTransitionType,
      this.backgroundColor,
      this.defaultLoadingWidget,
      this.blur,
      this.cancelButtonWidget,
      this.dismissable,
      this.onDismiss,
      required this.title,
      required this.message,
      this.dialogStyle,
      this.transitionDuration}) {
    _initProgress();
  }

  @override
  void setTitle(Widget title) {
    _progressDialogWidget?.getDialogState().setTitle(title);
  }

  @override
  void setLoadingWidget(Widget? loadingWidget) {
    _progressDialogWidget?.getDialogState().setLoadingWidget(loadingWidget);
  }

  @override
  void setBackgroundColor(Color color) {
    _progressDialogWidget?.getDialogState().setBackgroundColor(color);
  }

  @override
  void setMessage(Widget message) {
    _progressDialogWidget?.getDialogState().setMessage(message);
  }

  Future<T?> mountDialog<T>(
    BuildContext context, {
    final bool? dismissable,
    final Widget? child,
    final DialogTransitionType? dialogTransitionType,
    final Color? barrierColor,
    final RouteSettings? routeSettings,
    final bool? useRootNavigator,
    final bool? useSafeArea,
  }) {
    Duration defaultDuration = const Duration(seconds: 1);
    switch (dialogTransitionType ?? DialogTransitionType.NONE) {
      case DialogTransitionType.Bubble:
        defaultDuration = const Duration(milliseconds: 500);
        break;
      case DialogTransitionType.LeftToRight:
        defaultDuration = const Duration(milliseconds: 230);
        break;
      case DialogTransitionType.RightToLeft:
        defaultDuration = const Duration(milliseconds: 230);
        break;
      case DialogTransitionType.TopToBottom:
        defaultDuration = const Duration(milliseconds: 300);
        break;
      case DialogTransitionType.BottomToTop:
        defaultDuration = const Duration(milliseconds: 300);
        break;
      case DialogTransitionType.Shrink:
        defaultDuration = const Duration(milliseconds: 200);
        break;
      default:
        defaultDuration = Duration.zero;
    }
    _route = _showGeneralDialog<T>(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => (useSafeArea ?? false)
          ? SafeArea(child: child ?? const SizedBox.shrink())
          : (child ?? const SizedBox.shrink()),
      barrierColor: barrierColor ?? generalBarrierColor,
      barrierDismissible: dismissable ?? true,
      barrierLabel: '',
      transitionDuration: transitionDuration ?? defaultDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) => _animationWidget(animation, child),
    );
    return Navigator.of(context, rootNavigator: useRootNavigator ?? false).push<T>(_route as Route<T>);
  }

  Route<T> _showGeneralDialog<T extends Object?>({
    required BuildContext context,
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = false,
    String? barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    assert(!barrierDismissible || barrierLabel != null);
    return RawDialogRoute<T>(
      pageBuilder: pageBuilder,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      settings: routeSettings,
      anchorPoint: anchorPoint,
    );
  }

  ///Show progress dialog
  Future<T?> show<T>() async {
    if (!_show) {
      _show = true;
      if (_progressDialogWidget == null) _initProgress();
      // await showDialog(context: context, barrierDismissible: dismissable ?? true, builder: (context) => _progressDialogWidget, barrierColor: Color(0x00ffffff));
      _show = true;

      return await mountDialog(
        context,
        dismissable: dismissable,
        barrierColor: backgroundColor ?? generalBarrierColor,
        child: _progressDialogWidget,
        dialogTransitionType: dialogTransitionType,
      );
    } else {
      return null;
    }
  }

  Widget _animationWidget(Animation<double> animation, Widget child) {
    switch (dialogTransitionType ?? DialogTransitionType.NONE) {
      case DialogTransitionType.Bubble:
        return DialogTransition.bubble(animation, child);
      case DialogTransitionType.LeftToRight:
        return DialogTransition.transitionFromLeft(animation, child);
      case DialogTransitionType.RightToLeft:
        return DialogTransition.transitionFromRight(animation, child);
      case DialogTransitionType.TopToBottom:
        return DialogTransition.transitionFromTop(animation, child);
      case DialogTransitionType.BottomToTop:
        return DialogTransition.transitionFromBottom(animation, child);
      case DialogTransitionType.Shrink:
        return DialogTransition.shrink(animation, child);
      default:
    }
    return child;
  }

  ///Dissmiss progress dialog
  void dismiss() {
    if (_show && _route != null) {
      _show = false;
      Navigator.of(context).removeRoute(_route!);
      _route = null;
    }
  }

  void _initProgress() {
    _progressDialogWidget = _ProgressDialogWidget(
      backgroundColor: backgroundColor,
      dialogStyle: dialogStyle ?? DialogStyle(),
      cancelButton: cancelButtonWidget,
      title: title,
      dismissable: dismissable,
      onDismiss: onDismiss,
      message: message,
      blur: blur ?? 0,
      loadingWidget: defaultLoadingWidget,
    );
  }
}

class _ProgressDialogWidget extends StatefulWidget {
  final DialogStyle? dialogStyle;
  final Widget? title, message;
  final Widget Function(Function onDismissed)? cancelButton;
  final Widget? loadingWidget;
  final Function? onDismiss;
  final bool? dismissable;
  final double? blur;
  final Color? backgroundColor;
  final _ProgressDialogWidgetState _dialogWidgetState = _ProgressDialogWidgetState();

  _ProgressDialogWidget({
    required this.dialogStyle,
    this.title,
    this.message,
    this.cancelButton,
    this.dismissable,
    this.onDismiss,
    this.loadingWidget,
    this.blur,
    this.backgroundColor,
  });

  @override
  _ProgressDialogWidgetState createState() {
    // if (_dialogWidgetState == null) {
    //   _dialogWidgetState = _ProgressDialogWidgetState();
    // }
    return _dialogWidgetState;
  }

  _ProgressDialogWidgetState getDialogState() {
    // if (_dialogWidgetState == null) {
    //   _dialogWidgetState = _ProgressDialogWidgetState();
    // }
    return _dialogWidgetState;
  }
}

class _ProgressDialogWidgetState extends State<_ProgressDialogWidget> implements _ProgressDialog {
  Widget? _title, _message, _loading;
  Color? _backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DialogThemeData dialogTheme = DialogTheme.of(context);

    Widget? title = _title ?? widget.title;
    Widget message = _message ?? (widget.message ?? SizedBox.shrink());
    Color backgroundColor = _backgroundColor ?? (widget.backgroundColor ?? generalBarrierColor);
    Widget loading = (_loading ?? widget.loadingWidget) ??
        Container(
          padding: EdgeInsets.all(10.0),
          height: 50.0,
          width: 50.0,
          child: CircularProgressIndicator(),
        );

    EdgeInsets? msgPadding = title == null
        ? EdgeInsets.all(15.0)
        : widget.dialogStyle?.contentPadding ?? EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0);

    return NAlertDialog(
        title: title,
        dismissable: widget.dismissable ?? true,
        blur: widget.blur,
        backgroundColor: backgroundColor,
        onDismiss: () {
          if (widget.onDismiss != null) {
            widget.onDismiss?.call();
          }
        },
        dialogStyle: widget.dialogStyle?.copyWith(
          contentPadding: msgPadding,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                loading,
                SizedBox(width: 10),
                Expanded(
                  child: DefaultTextStyle(
                    style: (widget.dialogStyle?.contentTextStyle ?? dialogTheme.contentTextStyle) ??
                        (theme.textTheme.titleMedium ?? TextStyle()),
                    child: Semantics(child: message),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (widget.cancelButton != null) widget.cancelButton!.call(widget.onDismiss ?? () {}),
        ]);
  }

  @override
  void setTitle(Widget title) async {
    _title = title;
    if (mounted) setState(() {});
  }

  @override
  void setMessage(Widget message) async {
    _message = message;
    if (mounted) setState(() {});
  }

  @override
  void setLoadingWidget(Widget? loading) async {
    _loading = loading;
    if (mounted) setState(() {});
  }

  @override
  void setBackgroundColor(Color color) async {
    _backgroundColor = color;
    if (mounted) setState(() {});
  }
}
