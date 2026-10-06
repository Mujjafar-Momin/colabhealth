import 'package:colabhealth/colabhealth.dart';

class AddSleepBottomSheet extends StatefulWidget {
  const AddSleepBottomSheet({super.key});

  @override
  State<AddSleepBottomSheet> createState() => _AddSleepBottomSheetState();
}

class _AddSleepBottomSheetState extends State<AddSleepBottomSheet> {
  TimeOfDay _start = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _end = const TimeOfDay(hour: 6, minute: 30);

  int _deep = 90;
  int _rem = 80;
  int _light = 200;
  int _awake = 20;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return AppBottomSheet(
      title: 'Log sleep',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _timeTile('Bedtime', _start, (t) => setState(() => _start = t), LucideIcons.moon)),
              AppSpacing.w12,
              Expanded(child: _timeTile('Wake up', _end, (t) => setState(() => _end = t), LucideIcons.sun)),
            ],
          ),
          AppSpacing.h20,
          Label('Stages (minutes)',
              style: AppTextStyles.medium14.copyWith(color: colors.textSecondary)),
          AppSpacing.h12,
          _stepper('Deep', _deep, colors.deep, (v) => setState(() => _deep = v)),
          _stepper('REM', _rem, colors.rem, (v) => setState(() => _rem = v)),
          _stepper('Light', _light, colors.light, (v) => setState(() => _light = v)),
          _stepper('Awake', _awake, colors.awake, (v) => setState(() => _awake = v)),
          AppSpacing.h20,
          AppButton(title: 'Save & set wake alarm', onPressed: _save),
        ],
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay time, ValueChanged<TimeOfDay> onPick, IconData icon) {
    final colors = AppColors.current;
    return GestureDetector(
      onTap: () async {
        final picked = await CupertinoTimePickerSheet.show(time, title: label);
        if (picked != null) onPick(picked);
      },
      child: AppCard(
        color: colors.secondarySurface,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: colors.primary),
              AppSpacing.w6,
              Label(label, style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)),
            ]),
            AppSpacing.h8,
            Label(time.format(context), style: AppTextStyles.bold18),
          ],
        ),
      ),
    );
  }

  Widget _stepper(String label, int value, Color accent, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          AppSpacing.w12,
          Expanded(child: Label(label, style: AppTextStyles.medium14)),
          _circleBtn(LucideIcons.minus, () => onChanged((value - 10).clamp(0, 1000))),
          SizedBox(
            width: 64,
            child: Center(child: Label('$value m', style: AppTextStyles.semiBold14)),
          ),
          _circleBtn(LucideIcons.plus, () => onChanged((value + 10).clamp(0, 1000))),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    final colors = AppColors.current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: colors.secondarySurface, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: colors.textPrimary),
      ),
    );
  }

  void _save() {
    final now = DateTime.now();

    var end = DateTime(now.year, now.month, now.day, _end.hour, _end.minute);
    var start = DateTime(now.year, now.month, now.day, _start.hour, _start.minute);
    if (!start.isBefore(end)) {
      start = start.subtract(const Duration(days: 1));
    }

    var cursor = start;
    List<SleepStageInterval> seq(int minutes) {
      final s = cursor;
      final e = cursor.add(Duration(minutes: minutes));
      cursor = e;
      return [SleepStageInterval(s, e)];
    }

    final deep = seq(_deep);
    final rem = seq(_rem);
    final light = seq(_light);
    final awakeStart = cursor;
    final awakeEnd = cursor.add(Duration(minutes: _awake));
    final awake = [AwakePeriod(awakeStart, awakeEnd)];

    final log = SleepModel(
      sleepStart: start,
      sleepEnd: end,
      deep: deep,
      rem: rem,
      light: light,
      awakePeriods: awake,
      source: 'manual',
    );

    Get.find<SleepController>().saveLog(log);
    Get.back();
  }
}
