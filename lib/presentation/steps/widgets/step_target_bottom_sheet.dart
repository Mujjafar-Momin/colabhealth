import 'package:colabhealth/colabhealth.dart';

class StepTargetBottomSheet extends StatefulWidget {
  const StepTargetBottomSheet({super.key});

  @override
  State<StepTargetBottomSheet> createState() => _StepTargetBottomSheetState();
}

class _StepTargetBottomSheetState extends State<StepTargetBottomSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = Get.find<StepsController>().target.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return AppBottomSheet(
      title: 'Daily step target',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Label('${_value.round().grouped} steps', style: AppTextStyles.bold32.copyWith(color: colors.primary)),
          AppSpacing.h8,
          Slider(
            value: _value,
            min: 2000,
            max: 20000,
            divisions: 36,
            activeColor: colors.primary,
            label: _value.round().grouped,
            onChanged: (v) => setState(() => _value = v),
          ),
          AppSpacing.h12,
          AppButton(
            title: 'Save target',
            onPressed: () {
              Get.find<StepsController>().setTarget(_value.round());
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
