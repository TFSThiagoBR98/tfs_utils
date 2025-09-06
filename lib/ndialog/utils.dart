// PART OF NDIALOG PACKAGE
// Copyright (c) 2019 Mochamad Nizwar Syafuan

import 'dart:ui';

import 'package:flutter/material.dart';

Color get generalBarrierColor => Colors.black.withValues(alpha: .5);

enum DialogTransitionType { Shrink, Bubble, LeftToRight, RightToLeft, TopToBottom, BottomToTop, NONE }

/// A class to customize the style of dialogs.
class DialogStyle {
  /// Divider on title.
  final bool titleDivider;

  /// Set circular border radius for your dialog.
  final BorderRadius? borderRadius;

  /// Set semantics label for the title.
  final String semanticsLabel;

  /// Set padding for the title.
  final EdgeInsets titlePadding;

  /// Set padding for the content.
  final EdgeInsets? contentPadding;

  /// Set text style for the title.
  final TextStyle? titleTextStyle;

  /// Set text style for the content.
  final TextStyle? contentTextStyle;

  /// Elevation for the dialog.
  final double elevation;

  /// Background color of the dialog.
  final Color? backgroundColor;

  /// Shape for the dialog, ignored if you set [borderRadius].
  final ShapeBorder? shape;

  DialogStyle({
    this.titleDivider = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.semanticsLabel = "",
    this.titlePadding = const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
    this.contentPadding = const EdgeInsets.only(right: 15.0, left: 15.0, top: 0.0, bottom: 15.0),
    this.titleTextStyle,
    this.contentTextStyle,
    this.elevation = 24,
    this.backgroundColor,
    this.shape,
  });

  DialogStyle copyWith({
    bool? titleDivider,
    BorderRadius? borderRadius,
    String? semanticsLabel,
    EdgeInsets? titlePadding,
    EdgeInsets? contentPadding,
    TextStyle? titleTextStyle,
    TextStyle? contentTextStyle,
    double? elevation,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    return DialogStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleDivider: titleDivider ?? this.titleDivider,
      borderRadius: borderRadius ?? this.borderRadius,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
      titlePadding: titlePadding ?? this.titlePadding,
      contentPadding: contentPadding ?? this.contentPadding,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      contentTextStyle: contentTextStyle ?? this.contentTextStyle,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
    );
  }
}

class DialogTransition {
  static Widget transitionFromLeft(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero).animate(animation),
      child: child,
    );
  }

  static Widget transitionFromRight(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation),
      child: child,
    );
  }

  static Widget transitionFromTop(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero).animate(animation),
      child: child,
    );
  }

  static Widget transitionFromBottom(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero).animate(animation),
      child: child,
    );
  }

  static Widget bubble(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: Tween<double>(begin: 0, end: 1).animate(animation), curve: Curves.elasticOut),
      alignment: Alignment.center,
      child: child,
    );
  }

  static Widget shrink(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(animation),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// A simple dialog with a blur background and popup animations. Use [DialogStyle] to customize it.
class NAlertDialog extends DialogBackground {
  /// Dialog style
  final DialogStyle? dialogStyle;

  /// The (optional) title of the dialog is displayed in a large font at the top of the dialog.
  final Widget? title;

  /// The (optional) content of the dialog is displayed in the center of the dialog in a lighter font.
  final Widget? content;

  /// The (optional) set of actions that are displayed at the bottom of the dialog.
  final List<Widget>? actions;

  /// Creates a background filter that applies a Gaussian blur. Default is 0.
  @override
  final double? blur;

  /// Indicates if the dialog is dismissable.
  @override
  final bool? dismissable;

  /// The barrier color of the dialog.
  final Color? backgroundColor;

  /// Action to be performed before the dialog is dismissed.
  @override
  final Function? onDismiss;

  const NAlertDialog({
    Key? key,
    this.backgroundColor,
    this.dialogStyle,
    this.title,
    this.content,
    this.actions,
    this.blur,
    this.dismissable,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogBackground(
      dialog: NDialog(dialogStyle: dialogStyle, actions: actions, content: content, title: title),
      dismissable: dismissable,
      blur: blur,
      onDismiss: onDismiss,
      barrierColor: backgroundColor,
      key: key,
    );
  }
}

/// A widget that provides a blur background for dialogs. You can use this class to create custom dialog backgrounds with blur effects.
class DialogBackground extends StatelessWidget {
  /// Widget of the dialog. You can use [NDialog], [Dialog], [AlertDialog], or create your own custom dialog.
  final Widget? dialog;

  /// Indicates if the dialog is dismissable.
  final bool? dismissable;

  /// Action to be performed before the dialog is dismissed.
  final Function? onDismiss;

  /// Creates a background filter that applies a Gaussian blur. Default is 0.
  final double? blur;

  /// The barrier color of the dialog.
  final Color? barrierColor;

  const DialogBackground({Key? key, this.dialog, this.dismissable, this.blur, this.onDismiss, this.barrierColor})
      : super(key: key);

  /// Show the dialog directly.
  Route<T> show<T>(BuildContext context,
          {DialogTransitionType? transitionType, bool? dismissable, Duration? transitionDuration}) =>
      DialogUtils(
        child: this,
        dialogTransitionType: transitionType,
        dismissable: dismissable,
        barrierColor: barrierColor ?? generalBarrierColor,
        transitionDuration: transitionDuration,
      ).show(context);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Colors.transparent,
      child: PopScope(
        canPop: dismissable ?? true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            onDismiss?.call();
            return;
          }
        },
        child: Stack(
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                if (dismissable ?? true) {
                  onDismiss?.call();
                  Navigator.pop(context);
                }
              },
              child: (blur ?? 0) < 1
                  ? SizedBox.shrink()
                  : TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.1, end: blur ?? 0),
                      duration: Duration(milliseconds: 300),
                      builder: (context, double? val, Widget? child) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: val ?? 0,
                            sigmaY: val ?? 0,
                          ),
                          child: Container(color: Colors.transparent),
                        );
                      },
                    ),
            ),
            dialog ?? SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

/// A customizable dialog widget.
class NDialog extends StatelessWidget {
  /// Dialog style
  final DialogStyle? dialogStyle;

  /// The (optional) title of the dialog is displayed in a large font at the top of the dialog.
  final Widget? title;

  /// The (optional) content of the dialog is displayed in the center of the dialog in a lighter font.
  final Widget? content;

  /// The (optional) set of actions that are displayed at the bottom of the dialog.
  final List<Widget>? actions;

  const NDialog({
    Key? key,
    this.dialogStyle,
    this.title,
    this.content,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogTheme = DialogTheme.of(context);
    final style = dialogStyle ?? DialogStyle();

    String? label = style.semanticsLabel;
    Widget dialogChild = IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: style.titlePadding,
              child: DefaultTextStyle(
                style: style.titleTextStyle ?? dialogTheme.titleTextStyle ?? theme.textTheme.titleLarge ?? TextStyle(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Semantics(namesRoute: true, label: label, child: title),
                    style.titleDivider ? Divider() : SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          if (content != null)
            Flexible(
              child: Padding(
                padding: style.contentPadding ?? EdgeInsets.all(8),
                child: DefaultTextStyle(
                  style: style.contentTextStyle ??
                      dialogTheme.contentTextStyle ??
                      theme.textTheme.titleMedium ??
                      TextStyle(),
                  child: Semantics(child: content),
                ),
              ),
            ),
          if (actions != null && actions!.isNotEmpty)
            Theme(
              data: theme.copyWith(
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)))),
              child: actions!.length <= 3
                  ? IntrinsicHeight(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: actions!.map((action) => Expanded(child: action)).toList(),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: actions!.map((action) => SizedBox(height: 50.0, child: action)).toList(),
                    ),
            ),
        ],
      ),
    );

    return Padding(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: style.elevation,
            color: style.backgroundColor ?? theme.dialogTheme.backgroundColor,
            shape: style.borderRadius != null
                ? RoundedRectangleBorder(borderRadius: style.borderRadius ?? BorderRadius.circular(5))
                : style.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            child: dialogChild,
          ),
        ),
      ),
    );
  }

  Route<T> show<T>(
    BuildContext context, {
    DialogTransitionType? transitionType,
    bool? dismissable,
    Duration? transitionDuration,
    Color? barrierColor,
  }) =>
      DialogUtils(
        child: this,
        dialogTransitionType: transitionType,
        dismissable: dismissable,
        barrierColor: barrierColor ?? generalBarrierColor,
        transitionDuration: transitionDuration,
      ).show(context);
}

class DialogUtils {
  final bool? dismissable;
  final Widget? child;
  final DialogTransitionType? dialogTransitionType;
  final Color? barrierColor;
  final RouteSettings? routeSettings;
  final bool? useRootNavigator;
  final bool? useSafeArea;

  ///Set it null to start the animation with default duration
  final Duration? transitionDuration;

  DialogUtils({
    this.useSafeArea,
    this.barrierColor,
    this.dismissable,
    this.child,
    this.dialogTransitionType,
    this.routeSettings,
    this.transitionDuration,
    this.useRootNavigator,
  });

  ///Show dialog directly
  Route<T> show<T>(BuildContext context) {
    Duration defaultDuration = Duration(seconds: 1);
    switch (dialogTransitionType ?? DialogTransitionType.NONE) {
      case DialogTransitionType.Bubble:
        defaultDuration = Duration(milliseconds: 500);
        break;
      case DialogTransitionType.LeftToRight:
        defaultDuration = Duration(milliseconds: 230);
        break;
      case DialogTransitionType.RightToLeft:
        defaultDuration = Duration(milliseconds: 230);
        break;
      case DialogTransitionType.TopToBottom:
        defaultDuration = Duration(milliseconds: 300);
        break;
      case DialogTransitionType.BottomToTop:
        defaultDuration = Duration(milliseconds: 300);
        break;
      case DialogTransitionType.Shrink:
        defaultDuration = Duration(milliseconds: 200);
        break;
      default:
        defaultDuration = Duration.zero;
    }
    return _showGeneralDialog<T>(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          (useSafeArea ?? false) ? SafeArea(child: child ?? SizedBox.shrink()) : (child ?? SizedBox.shrink()),
      barrierColor: barrierColor ?? generalBarrierColor,
      barrierDismissible: dismissable ?? true,
      barrierLabel: '',
      transitionDuration: transitionDuration ?? defaultDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) => _animationWidget(animation, child),
    );
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
}
