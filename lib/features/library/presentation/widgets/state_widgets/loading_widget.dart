import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(color: context.colors.secondary),
      );
}
