import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:colabhealth/core/core.dart';
import 'package:colabhealth/widgets/src/app_bottom_sheet.dart';
import 'package:colabhealth/widgets/src/app_button.dart';

class CupertinoTimePickerSheet extends StatefulWidget {
  const CupertinoTimePickerSheet({
    super.key,
    required this.initial,
    this.title = 'Select time',
  });

  final TimeOfDay initial;
  final String title;

  static Future<TimeOfDay?> show(TimeOfDay initial, {String title = 'Select time'}) {
    return AppBottomSheet.show<TimeOfDay>(
      child: CupertinoTimePickerSheet(initial: initial, title: title),
    );
  }

  @override
  State<CupertinoTimePickerSheet> createState() => _CupertinoTimePickerSheetState();
}

class _CupertinoTimePickerSheetState extends State<CupertinoTimePickerSheet> {
  late TimeOfDay _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final now = DateTime.now();
    final initialDateTime =
        DateTime(now.year, now.month, now.day, widget.initial.hour, widget.initial.minute);

    return AppBottomSheet(
      title: widget.title,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle:
                      AppTextStyles.semiBold20.copyWith(color: colors.textPrimary),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialDateTime,
                use24hFormat: false,
                onDateTimeChanged: (dt) {
                  _selected = TimeOfDay(hour: dt.hour, minute: dt.minute);
                },
              ),
            ),
          ),
          AppSpacing.h20,
          AppButton(
            title: 'Set time',
            onPressed: () => Get.back<TimeOfDay>(result: _selected),
          ),
        ],
      ),
    );
  }
}
