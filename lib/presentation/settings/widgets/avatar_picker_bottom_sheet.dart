import 'package:colabhealth/colabhealth.dart';

class AvatarPickerBottomSheet extends StatelessWidget {
  const AvatarPickerBottomSheet({super.key, required this.selectedId, required this.onSelected});

  final String? selectedId;
  final ValueChanged<AvatarModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Choose your mask',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: AvatarModel.all.map((a) {
          final selected = a.id == selectedId;
          return GestureDetector(
            onTap: () {
              onSelected(a);
              Get.back();
            },
            child: AvatarView(avatar: a, size: 64, selected: selected),
          );
        }).toList(),
      ),
    );
  }
}
