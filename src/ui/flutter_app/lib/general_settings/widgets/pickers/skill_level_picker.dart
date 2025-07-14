




part of 'package:sanmill/general_settings/widgets/general_settings_page.dart';

class _SkillLevelPicker extends StatefulWidget {
  const _SkillLevelPicker();

  @override
  State<_SkillLevelPicker> createState() => _SkillLevelPickerState();
}

class _SkillLevelPickerState extends State<_SkillLevelPicker> {
  late FixedExtentScrollController _controller;
  late int _level;

  @override
  void initState() {
    super.initState();

    _level = DB().generalSettings.skillLevel;
    _controller = FixedExtentScrollController(initialItem: _level - 1);
  }

  @override
  void dispose() {

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final Color? backgroundColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Colors.grey[900] // Dark mode background color
            : Colors.white;

    final Color textColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Colors.white // Text color in dark mode
            : Colors.black;

    return AlertDialog(
      key: const Key('skill_level_picker_alert_dialog'),
      backgroundColor: backgroundColor,

      title: Text(
        S.of(context).skillLevel,
        key: const Key('skill_level_picker_title'),
        style: AppTheme.dialogTitleTextStyle,
      ),
      content: ConstrainedBox(
        key: const Key('skill_level_picker_constrained_box'),
        constraints: const BoxConstraints(maxHeight: 150),
        child: CupertinoPicker(
          key: const Key('skill_level_picker_cupertino_picker'),
          backgroundColor: backgroundColor,

          scrollController: _controller,
          itemExtent: 44,
          children: List<Widget>.generate(
            Constants.highestSkillLevel,
            (int level) => Center(
              child: Text(
                '${level + 1}',
                key: Key(
                    'skill_level_picker_cupertino_picker_item_${level + 1}'),
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          onSelectedItemChanged: (int value) {
            _level = value + 1;
          },
        ),
      ),
      actions: <Widget>[
        if (EnvironmentConfig.test == false)
          TextButton(
            key: const Key('skill_level_picker_cancel_button'),
            child: Text(
              S.of(context).cancel,
              key: const Key('skill_level_picker_cancel_button_text'),
              style: TextStyle(
                fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (!kIsWeb &&
                  (Platform.isWindows ||
                      Platform.isLinux ||
                      Platform.isMacOS)) {
                rootScaffoldMessengerKey.currentState!.showSnackBarClear(
                    S.of(context).youCanUseMouseWheelInPicker);
              }
            },
          ),
        TextButton(
          key: const Key('skill_level_picker_confirm_button'),
          child: Text(
            S.of(context).confirm,
            key: const Key('skill_level_picker_confirm_button_text'),
            style: TextStyle(
              fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize),
            ),
          ),
          onPressed: () {
            DB().generalSettings =
                DB().generalSettings.copyWith(skillLevel: _level);
            if (DB().generalSettings.skillLevel > 15 &&
                DB().generalSettings.moveTime < 10) {
              rootScaffoldMessengerKey.currentState!.showSnackBarClear(
                  S.of(context).noteActualDifficultyLevelMayBeLimited);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
