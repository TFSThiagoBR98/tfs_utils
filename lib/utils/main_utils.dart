import 'dart:async';

import 'package:any_logger/any_logger.dart';
import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart' as logging;

Future<void> initFlutterApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('settings');
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen((record) {
    Level level;
    switch (record.level) {
      case logging.Level.SHOUT:
        level = Level.FATAL;
        break;
      case logging.Level.SEVERE:
        level = Level.ERROR;
        break;
      case logging.Level.WARNING:
        level = Level.WARN;
        break;
      case logging.Level.CONFIG:
      case logging.Level.INFO:
      case logging.Level.FINE:
        level = Level.INFO;
        break;
      case logging.Level.FINER:
        level = Level.DEBUG;
        break;
      default:
        level = Level.TRACE;
    }
    LoggerFactory.getRootLogger().log(level, record.message, null, record.error, record.stackTrace);
  });
}

final appRouteKey = GlobalKey<NavigatorState>(debugLabel: 'Key Created by default');

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

int decimalToInt(Decimal value) {
  return value.shift(2).toBigInt().toInt();
}

Decimal intToDecimal(int value) {
  return Decimal.fromBigInt(BigInt.from(value)).shift(-2);
}

Decimal money2decimal(String value) {
  return Decimal.parse(lformatMoney.parse(value).toStringAsFixed(8));
}

String decimal2money(Decimal value) {
  return DecimalFormatter(lformatMoney).format(value);
}

Decimal string2decimal(String value) {
  return Decimal.parse(lformatDouble.parse(value).toStringAsFixed(8));
}

String decimal2string(Decimal value) {
  return DecimalFormatter(lformatDouble).format(value);
}

Future<XFile?> selectImagePicker(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  return showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: const Text(
                        'Abrir na câmera',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () async {
                        picker.pickImage(source: ImageSource.camera).then((file) => Navigator.of(context).pop(file));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: const Text(
                        'Escolher na Galeria',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () {
                        picker.pickImage(source: ImageSource.gallery).then((file) => Navigator.of(context).pop(file));
                      },
                    ),
                  ),
                ]),
              );
            },
          ),
        );
      });
}
