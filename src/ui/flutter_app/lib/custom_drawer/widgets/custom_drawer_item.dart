




part of '../../custom_drawer/custom_drawer.dart';

class CustomDrawerItem<T> extends StatelessWidget {
  const CustomDrawerItem({
    super.key,
    required this.currentSelectedValue,
    required this.onSelectionChanged,
    required this.itemValue,
    required this.itemTitle,
    required this.itemIcon,
    this.children,
    this.onTapOverride,
    this.trailingContent,
  });

  final T currentSelectedValue;
  final Function(T) onSelectionChanged;
  final T itemValue;
  final String itemTitle;
  final Icon itemIcon;
  final List<CustomDrawerItem<dynamic>>? children;
  final VoidCallback? onTapOverride;
  final Widget? trailingContent;

  bool get isSelected => currentSelectedValue == itemValue;
  bool get isParent => children != null && children!.isNotEmpty;

  @override
  Widget build(BuildContext context) {

    final Color color = isSelected
        ? DB().colorSettings.drawerTextColor
        : DB().colorSettings.drawerTextColor;

    final Icon listItemIcon = Icon(
      itemIcon.icon,
      color: color,
      key: const Key('custom_drawer_item_icon'),
    );

    final TextStyle titleStyle =
        Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 16.0,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            );

    final Size titleSize = getBoundingTextSize(
      context,
      itemTitle,
      titleStyle,
      maxLines: 1,
    );
    final bool isExpand =
        (MediaQuery.of(context).size.width * 0.75 * 0.9 - 46) > titleSize.width;

    final Row drawerItem = Row(
      key: const Key('custom_drawer_item_row'),
      children: <Widget>[
        const SizedBox(height: 46.0, width: 6.0),
        const Padding(
          key: Key('custom_drawer_item_padding_left'),
          padding: EdgeInsets.all(4.0),
        ),
        listItemIcon,
        const Padding(
          key: Key('custom_drawer_item_padding_right'),
          padding: EdgeInsets.all(4.0),
        ),
        Expanded(
          key: const Key('custom_drawer_item_expanded'),
          child: isExpand || !isSelected
              ? Text(
                  itemTitle,
                  key: const Key('custom_drawer_item_text'),
                  maxLines: 1,
                  style: titleStyle,
                )
              : SizedBox(
                  height: AppTheme.drawerItemHeight,
                  child: Marquee(
                    key: const Key('custom_drawer_item_marquee'),
                    text: itemTitle,
                    style: titleStyle,
                  ),
                ),
        ),
        if (trailingContent != null) ...<Widget>[
          const SizedBox(width: 4.0),
          trailingContent!,
        ],
      ],
    );

    return InkWell(
      key: const Key('custom_drawer_item_inkwell'),
      splashColor: AppTheme.drawerSplashColor,
      highlightColor: Colors.transparent,
      onTap: onTapOverride ?? () => onSelectionChanged(itemValue),
      child: drawerItem,
    );
  }
}
