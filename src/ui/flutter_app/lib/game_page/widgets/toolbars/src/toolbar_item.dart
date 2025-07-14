




part of '../game_toolbar.dart';



















































































class ToolbarItem extends ButtonStyleButton {



  const ToolbarItem({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    required Widget super.child,
    super.onHover,
    super.onFocusChange,
  });







  factory ToolbarItem.icon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    required Widget icon,
    required Widget label,
  }) = _ToolbarItemWithIcon;
































  static ButtonStyle styleFrom({
    Color? primary,
    Color? onSurface,
    Color? backgroundColor,
    Color? shadowColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    final WidgetStateProperty<Color?>? foregroundColor =
        (onSurface == null && primary == null)
            ? null
            : _ToolbarItemDefaultForeground(primary, onSurface);
    final WidgetStateProperty<Color?>? overlayColor =
        (primary == null) ? null : _ToolbarItemDefaultOverlay(primary);
    final WidgetStateProperty<MouseCursor>? mouseCursor =
        (enabledMouseCursor == null && disabledMouseCursor == null)
            ? null
            : _ToolbarItemDefaultMouseCursor(
                enabledMouseCursor!,
                disabledMouseCursor!,
              );

    return ButtonStyle(
      textStyle: ButtonStyleButton.allOrNull<TextStyle>(textStyle),
      backgroundColor: ButtonStyleButton.allOrNull<Color>(backgroundColor),
      foregroundColor: foregroundColor,
      overlayColor: overlayColor,
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      elevation: ButtonStyleButton.allOrNull<double>(elevation),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      fixedSize: ButtonStyleButton.allOrNull<Size>(fixedSize),
      maximumSize: ButtonStyleButton.allOrNull<Size>(maximumSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      mouseCursor: mouseCursor,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }




































































  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    const TextScaler scaler = TextScaler.noScaling;

    const double fontSize = 1.0;
    final double scaledFontSize = scaler.scale(fontSize);
    final double scaleFactor = scaledFontSize / fontSize;

    final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
      const EdgeInsets.all(8),
      const EdgeInsets.symmetric(horizontal: 8),
      const EdgeInsets.symmetric(horizontal: 4),
      scaleFactor,
    );

    return styleFrom(
      primary: colorScheme.primary,
      onSurface: colorScheme.onSurface,
      backgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: scaledPadding,
      minimumSize: const Size(64, 36),
      maximumSize: Size.infinite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }



  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return ToolbarItemTheme.of(context).style;
  }
}

@immutable
class _ToolbarItemDefaultForeground extends WidgetStateProperty<Color?> {
  _ToolbarItemDefaultForeground(this.primary, this.onSurface);

  final Color? primary;
  final Color? onSurface;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return onSurface?.withValues(alpha: 0.38);
    }
    return primary;
  }

  @override
  String toString() {
    return '{disabled: ${onSurface?.withValues(alpha: 0.38)}, otherwise: $primary}';
  }
}

@immutable
class _ToolbarItemDefaultOverlay extends WidgetStateProperty<Color?> {
  _ToolbarItemDefaultOverlay(this.primary);

  final Color primary;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.hovered)) {
      return primary.withValues(alpha: 0.04);
    }
    if (states.contains(WidgetState.focused) ||
        states.contains(WidgetState.pressed)) {
      return primary.withValues(alpha: 0.12);
    }
    return null;
  }

  @override
  String toString() {
    return '{hovered: ${primary.withValues(alpha: 0.04)}, focused,pressed: ${primary.withValues(alpha: 0.12)}, otherwise: null}';
  }
}

@immutable
class _ToolbarItemDefaultMouseCursor extends WidgetStateProperty<MouseCursor>
    with Diagnosticable {
  _ToolbarItemDefaultMouseCursor(this.enabledCursor, this.disabledCursor);

  final MouseCursor enabledCursor;
  final MouseCursor disabledCursor;

  @override
  MouseCursor resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return disabledCursor;
    }
    return enabledCursor;
  }
}

class _ToolbarItemWithIcon extends ToolbarItem {
  _ToolbarItemWithIcon({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.style,
    super.focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    required Widget icon,
    required Widget label,
  }) : super(
          autofocus: autofocus ?? false,
          clipBehavior: clipBehavior ?? Clip.none,
          child: _ToolbarItemChild(
            icon: icon,
            label: label,
            key: const Key('toolbar_item_child'),
          ),
        );

  static const TextScaler scaler = TextScaler.noScaling;

  static const double fontSize = 1.0;
  final double scaleFactor = scaler.scale(fontSize) / fontSize;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
      const EdgeInsets.all(8),
      const EdgeInsets.symmetric(horizontal: 4),
      const EdgeInsets.symmetric(horizontal: 4),
      scaleFactor,
    );
    return super.defaultStyleOf(context).copyWith(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(scaledPadding),
        );
  }
}

class _ToolbarItemChild extends StatelessWidget {
  const _ToolbarItemChild({
    required this.label,
    required this.icon,
    super.key,
  });

  final Widget label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('toolbar_item_child_column'),

      children: <Widget>[icon, label],
    );
  }
}
