import 'package:flutter/material.dart' hide Builder;
import 'package:intl/intl.dart';
import 'package:startate/startate.dart';

import 'tfs_datetime_controller.dart';

class TFSSplitedDateTimeController {
  late final Rxn<DateTime> dataRx;
  DateTime? get data => dataRx.value;
  set data(DateTime? value) => dataRx.value = value;

  final Rx<TextEditingController> _dateController = TextEditingController().obs;
  TextEditingController get dateController => _dateController.value;
  set dateController(TextEditingController value) => _dateController.value = value;

  final Rx<TextEditingController> _timeController = TextEditingController().obs;
  TextEditingController get timeController => _timeController.value;
  set timeController(TextEditingController value) => _timeController.value = value;

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
    return toFormat(internalFormat);
  }

  String? toDisplayFormat() {
    return toFormat(displayFormat);
  }

  String? toFormat(String format) {
    if (data == null) return null;
    try {
      return DateFormat(format).format(data!);
    } on FormatException {
      return null;
    }
  }

  void setDataFromDateTime(DateTime time) {
    try {
      data = time;
      dateController.text = DateFormat(displayDateFormat).format(data!);
      timeController.text = DateFormat(displayTimeFormat).format(data!);
    } on FormatException {
      data = null;
      dateController.text = '';
      timeController.text = '';
    }
  }

  void setData(String value) {
    try {
      data = DateFormat(internalFormat).parse(value);
      dateController.text = DateFormat(displayDateFormat).format(data!);
      timeController.text = DateFormat(displayTimeFormat).format(data!);
    } on FormatException {
      data = null;
      dateController.text = '';
      timeController.text = '';
    }
  }

  Future<DateTime?> selectDatePeriod(BuildContext context) async {
    var range = await showDatePicker(
      initialDate: data ?? DateTime.now(),
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

    updateTimeController();

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
        final now = DateTime.now();
        data = DateTime(now.year, now.month, now.day, range.hour, range.minute);
      }
    }

    updateTimeController();

    return data;
  }

  void updateTimeController() {
    if (data == null) {
      dateController.text = '';
      timeController.text = '';
      return;
    }

    dateController.text = DateFormat(displayDateFormat).format(data!);
    timeController.text = DateFormat(displayTimeFormat).format(data!);
  }

  TFSSplitedDateTimeController(this.format) {
    dataRx = Rxn<DateTime>();
  }
}
