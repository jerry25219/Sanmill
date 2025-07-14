




part of 'settings.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView.separated(
        key: const Key('settings_list'),
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, int i) => children[i],
        separatorBuilder: (_, int i) =>
            const CustomSpacer(key: Key('custom_spacer')),
        itemCount: children.length,
      );
}
