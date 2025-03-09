import 'package:flutter/material.dart' hide Builder;
import 'package:startate/startate.dart';
import 'package:intl/intl.dart';

enum TFSDateTimeControllerDisplayFormat { date, time, datetime }

class TFSDateTimeController {
  late final Rxn<DateTime> dataRx;
  DateTime? get data => dataRx.value;
  set data(DateTime? value) => dataRx.value = value;

  final Rx<TextEditingController> _controller = TextEditingController().obs;
  TextEditingController get controller => _controller.value;
  set controller(TextEditingController value) => _controller.value = value;

  final TFSDateTimeControllerDisplayFormat format;

  final String displayDateFormat = 'dd/MM/yyyy';
  final String displayTimeFormat = 'HH:mm:ss';

  final String internalDateFormat = 'yyyy-MM-dd';
  final String internalTimeFormat = 'HH:mm:ss';

  String get displayFormat {
    if (format == TFSDateTimeControllerDisplayFormat.date) {
      return displayDateFormat;
    } else if (format == TFSDateTimeControllerDisplayFormat.time) {
      return displayTimeFormat;
    } else {
      return '$displayDateFormat $displayTimeFormat';
    }
  }

  String get internalFormat {
    if (format == TFSDateTimeControllerDisplayFormat.date) {
      return internalDateFormat;
    } else if (format == TFSDateTimeControllerDisplayFormat.time) {
      return internalTimeFormat;
    } else {
      return '$internalDateFormat $internalTimeFormat';
    }
  }

  String? toInternalFormat() {
    if (data == null) return null;
    try {
      return DateFormat(internalFormat).format(data!);
    } on FormatException {
      return null;
    }
  }

  void setData(String value) {
    try {
      data = DateFormat(internalFormat).parse(value);
      controller.text = DateFormat(displayFormat).format(data!);
    } on FormatException {
      data = null;
      controller.text = '';
    }
  }

  Future<DateTime?> selectDatePeriod(BuildContext context) async {
    var range = await showDatePicker(
      initialDate: data ?? DateTime(2019),
      firstDate: DateTime(1900),
      useRootNavigator: true,
      initialEntryMode: DatePickerEntryMode.calendar,
      textDirection: null,
      lastDate: DateTime.now().add(const Duration(days: 1)),
      context: context,
    );

    if (range != null) {
      if (data != null) {
        data = DateTime(range.year, range.month, range.day, data!.hour, data!.minute);
      } else {
        data = DateTime(range.year, range.month, range.day, 0, 0);
      }
    }

    return data;
  }

  Future<DateTime?> selectTimePeriod(BuildContext context) async {
    var range = await showTimePicker(
      initialTime: data != null ? TimeOfDay.fromDateTime(data!) : const TimeOfDay(hour: 00, minute: 00),
      useRootNavigator: true,
      initialEntryMode: TimePickerEntryMode.input,
      // ignore: use_build_context_synchronously
      context: context,
    );

    if (range != null) {
      if (data != null) {
        data = DateTime(data!.year, data!.month, data!.day, range.hour, range.minute);
      } else {
        data = DateTime(2019, 1, 1, range.hour, range.minute);
      }
    }

    return data;
  }

  void updateTimeController() {
    if (data == null) {
      controller.text = '';
      return;
    }

    controller.text = DateFormat(displayFormat).format(data!);
  }

  Future<DateTime?> selectPeriod(BuildContext context) async {
    if (format == TFSDateTimeControllerDisplayFormat.date || format == TFSDateTimeControllerDisplayFormat.datetime) {
      data = await selectDatePeriod(context);
    }

    if (format == TFSDateTimeControllerDisplayFormat.time || format == TFSDateTimeControllerDisplayFormat.datetime) {
      // ignore: use_build_context_synchronously
      data = await selectTimePeriod(context);
    }

    updateTimeController();
    return data;
  }

  TFSDateTimeController(this.format) {
    dataRx = Rxn<DateTime>();
  }
}
