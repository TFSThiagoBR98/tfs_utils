import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'func_utils.dart';

Future<void> initFlutterApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('settings');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
}

final appRouteKey = GlobalKey<NavigatorState>(debugLabel: 'Key Created by default');
BuildContext? get appContext => Get.context!;

final NumberFormat lformatMoney = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
);

final NumberFormat lformatDouble = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: '',
);

String stringDecimalToMoney(String decimalValue) {
  return decimal2money(Decimal.tryParse(decimalValue) ?? Decimal.zero);
}

Decimal money2decimal(String value) {
  return Decimal.parse(lformatMoney.parse(value).toStringAsFixed(8));
}

String decimal2money(Decimal value) {
  return lformatMoney.format(DecimalIntl(value));
}

Decimal string2decimal(String value) {
  return Decimal.parse(lformatDouble.parse(value).toStringAsFixed(8));
}

String decimal2string(Decimal value) {
  return lformatDouble.format(DecimalIntl(value));
}

void runWhenContextAvaliable(ContextCallback callback) {
  Timer.periodic(const Duration(seconds: 1), (Timer t) async {
    if (appContext != null) {
      callback(appContext!);
      t.cancel();
    }
  });
}
