import 'package:dalili/core/extensions/navigation.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/presentation/screens/department/department_books_screen.dart';
import 'package:flutter/material.dart';

class DepartmentTile extends StatelessWidget {
  const DepartmentTile({super.key, required this.department});

  final Department department;

  @override
  Widget build(BuildContext context) => ListTile(
    tileColor: context.appTheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
    ),
    leading: CircleAvatar(
      backgroundColor: context.appTheme.secondaryContainer,
      child: Icon(
        Icons.library_books,
        color: context.appTheme.onSecondaryContainer,
      ),
    ),
    title: Text(department.name, style: context.textStyles.bodyMedium),
    trailing: Icon(
      Icons.chevron_right,
      color: context.appTheme.onSurfaceVariant,
    ),
    onTap: () => context.push(DepartmentBooksScreen(department)),
  );
}
