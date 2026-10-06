import 'package:colabhealth/colabhealth.dart';
import 'package:intl/intl.dart';

class CalendarBottomSheet extends StatefulWidget {
  const CalendarBottomSheet({super.key, required this.selected, required this.onSelected});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _month = DateTime(widget.selected.year, widget.selected.month);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(DateFormat('MMMM yyyy').format(_month), style: AppTextStyles.semiBold18),
              Row(
                children: [
                  _navBtn(LucideIcons.chevronLeft, () {
                    setState(() => _month = DateTime(_month.year, _month.month - 1));
                  }),
                  AppSpacing.w8,
                  _navBtn(LucideIcons.chevronRight, () {
                    setState(() => _month = DateTime(_month.year, _month.month + 1));
                  }),
                ],
              ),
            ],
          ),
          AppSpacing.h16,
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
                      child: Center(
                        child: Label(d,
                            style: AppTextStyles.medium12
                                .copyWith(color: colors.textSecondary)),
                      ),
                    ))
                .toList(),
          ),
          AppSpacing.h8,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: firstWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (_, i) {
              if (i < firstWeekday) return const SizedBox.shrink();
              final day = i - firstWeekday + 1;
              final date = DateTime(_month.year, _month.month, day);
              final isSelected = date.isSameDay(_selected);
              return GestureDetector(
                onTap: () => setState(() => _selected = date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.primary : Colors.transparent,
                  ),
                  child: Label(
                    '$day',
                    style: AppTextStyles.medium14.copyWith(
                      color: isSelected ? Colors.white : colors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
          AppSpacing.h20,
          AppButton(
            title: 'Select',
            onPressed: () {
              widget.onSelected(_selected);
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    final colors = AppColors.current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: colors.secondarySurface, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: colors.textPrimary),
      ),
    );
  }
}
