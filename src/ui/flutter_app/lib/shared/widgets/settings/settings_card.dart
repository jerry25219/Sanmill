




part of 'settings.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.children,
    required this.title,
  });

  final Widget title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.titleLarge!.apply(
      color: Colors.black,//AppTheme.settingsHeaderTextColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DefaultTextStyle(
          key: const Key('settings_card_title'),
          style: textStyle,
          textAlign: TextAlign.start,
          child: title,
        ),
        Card(
          key: const Key('settings_card_card'),
          color: Colors.grey[50], //AppTheme.settingsCardColor,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < children.length; i++)
                  i == children.length - 1
                      ? children[i]
                      : Column(
                          children: <Widget>[
                            children[i],
                            const Divider(
                              color: AppTheme.listItemDividerColor,
                            )
                          ],
                        ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
