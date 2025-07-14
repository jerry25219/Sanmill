




import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class CustomSpacer extends StatelessWidget {
  const CustomSpacer({super.key});

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: AppTheme.sizedBoxHeight);
}
