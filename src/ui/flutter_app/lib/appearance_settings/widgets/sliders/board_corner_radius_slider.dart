




part of 'package:sanmill/appearance_settings/widgets/appearance_settings_page.dart';

class _BoardCornerRadiusSlider extends StatelessWidget {
  const _BoardCornerRadiusSlider();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('board_corner_radius_semantics'),
      label: S.of(context).boardCornerRadius,
      child: ValueListenableBuilder<Box<DisplaySettings>>(
        key: const Key('board_corner_radius_value_listenable_builder'),
        valueListenable: DB().listenDisplaySettings,
        builder: (BuildContext context, Box<DisplaySettings> box, _) {
          final DisplaySettings displaySettings = box.get(
            DB.displaySettingsKey,
            defaultValue: const DisplaySettings(),
          )!;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            key: const Key('board_corner_radius_sized_box'),
            height: 100,
            child: Slider(
              key: const Key('board_corner_radius_slider'),
              value: displaySettings.boardCornerRadius,
              max: 50.0,
              divisions: 50,
              label: displaySettings.boardCornerRadius.toStringAsFixed(1),
              onChanged: (double value) {
                logger.t("[config] BoardCornerRadius value: $value");
                DB().displaySettings =
                    displaySettings.copyWith(boardCornerRadius: value);
              },
            ),
          );
        },
      ),
    );
  }
}
