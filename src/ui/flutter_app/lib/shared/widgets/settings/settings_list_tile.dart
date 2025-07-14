




part of 'settings.dart';

enum _SettingsTileType { standard, color, switchTile }


class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.titleString,
    required VoidCallback onTap,
    this.subtitleString,
    this.trailingString,
  })  : _type = _SettingsTileType.standard,
        _switchValue = null,
        _switchCallback = null,
        _colorCallback = null,
        _standardCallback = onTap,
        _colorValue = null;

  const SettingsListTile.color({
    super.key,
    required this.titleString,
    required Color value,
    required ValueChanged<Color> onChanged,
    this.subtitleString,
  })  : _type = _SettingsTileType.color,
        _switchValue = null,
        _colorValue = value,
        _switchCallback = null,
        _colorCallback = onChanged,
        _standardCallback = null,
        trailingString = null;

  const SettingsListTile.switchTile({
    super.key,
    required this.titleString,
    required bool value,
    required ValueChanged<bool> onChanged,
    this.subtitleString,
  })  : _type = _SettingsTileType.switchTile,
        _switchValue = value,
        _colorValue = null,
        _switchCallback = onChanged,
        _colorCallback = null,
        _standardCallback = null,
        trailingString = null;

  final String titleString;
  final String? subtitleString;
  final String? trailingString;

  final _SettingsTileType _type;
  final bool? _switchValue;
  final Color? _colorValue;
  final ValueChanged<bool>? _switchCallback;
  final ValueChanged<Color>? _colorCallback;
  final VoidCallback? _standardCallback;

  Widget get title => Text(
        titleString,
        style: AppTheme.listTileTitleStyle.copyWith(color: Colors.black87,fontSize: 18),
      );

  Widget? get subTitle => subtitleString != null
      ? Text(subtitleString!, style: AppTheme.listTileSubtitleStyle.copyWith(color: Colors.black54))
      : null;

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _SettingsTileType.switchTile:
        return SwitchListTile(
          value: _switchValue!,
          onChanged: _switchCallback,
          title: title,
          subtitle: subTitle,
        );
      case _SettingsTileType.standard:
        Widget trailing;
        if (trailingString != null) {

          trailing = IntrinsicWidth(
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                trailingString!,
                style: AppTheme.listTileSubtitleStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        } else {
          trailing = const Icon(
            FluentIcons.chevron_right_24_regular,
            color: AppTheme.listTileSubtitleColor,
          );
        }

        return ListTile(
          title: title,
          subtitle: subTitle,
          trailing: trailing,
          onTap: _standardCallback,
        );

      case _SettingsTileType.color:
        return ListTile(
          title: title,
          subtitle: subTitle,
          trailing: Text(
            _colorValue!.toHexString(),
            style: TextStyle(backgroundColor: _colorValue),
          ),
          onTap: () => showDialog(
            context: context,
            barrierDismissible: EnvironmentConfig.test == true,
            builder: (_) => _ColorPickerAlert(
              title: titleString,
              value: _colorValue,
              onChanged: _colorCallback!,
            ),
          ),
        );
    }
  }
}

class _ColorPickerAlert extends StatefulWidget {
  const _ColorPickerAlert({
    required this.value,
    required this.title,
    required this.onChanged,
  });

  final Color value;
  final String title;
  final ValueChanged<Color> onChanged;

  @override
  _ColorPickerAlertState createState() => _ColorPickerAlertState();
}

class _ColorPickerAlertState extends State<_ColorPickerAlert> {
  late Color pickedColor;

  void _changeColor(Color color) => setState(() => pickedColor = color);

  @override
  void initState() {
    pickedColor = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('color_picker_alert_dialog'),
      title: DB().displaySettings.fontScale == 1.0
          ? Text(
              S.of(context).pick(widget.title),
              style: AppTheme.dialogTitleTextStyle.copyWith(color: Colors.black),
            )
          : null,
      content: SingleChildScrollView(
        child: SizedBox(
          child: SlidePicker(
            key: const Key('color_picker_slide_picker'),
            pickerColor: pickedColor,
            labelTypes: DB().displaySettings.fontScale == 1.0
                ? const <ColorLabelType>[
                    ColorLabelType.hex,
                    ColorLabelType.rgb,
                    ColorLabelType.hsv,
                    ColorLabelType.hsl
                  ]
                : const <ColorLabelType>[],
            onColorChanged: _changeColor,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('color_picker_confirm_button'),
          child: Text(
            S.of(context).confirm,
            style: TextStyle(
                fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize),color: Colors.black),
          ),
          onPressed: () {
            logger.t("[config] pickerColor.value: $pickedColor");
            widget.onChanged(pickedColor);
            Navigator.pop(context);
          },
        ),
        TextButton(
          key: const Key('color_picker_cancel_button'),
          child: Text(
            S.of(context).cancel,
            style: TextStyle(
                fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize),color: Colors.black54),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
