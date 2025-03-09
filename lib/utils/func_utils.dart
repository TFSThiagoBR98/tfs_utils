import 'package:flutter/material.dart';

typedef ErrorCallback = bool Function(Exception e);
typedef ContextCallback = void Function(BuildContext context);
typedef FutureContextCallback = Future<void> Function(BuildContext context);
