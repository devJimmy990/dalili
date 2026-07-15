import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/presentation/cubits/department/department_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/department/department_state.dart';
import 'package:dalili/features/library/presentation/screens/scanner/scanner_screen.dart';
import 'package:dalili/features/library/presentation/screens/search/search_screen.dart';
import 'package:dalili/features/library/presentation/widgets/department_tile.dart';
import 'package:dalili/features/library/presentation/widgets/search_bar_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/empty_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/error_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/shimmer_widget.dart';
import 'package:dalili/features/library/presentation/widgets/welcome_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DepartmentCubit>().loadDepartments();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.surface,
    floatingActionButton: FloatingActionButton(
      backgroundColor: context.colors.secondary,
      foregroundColor: Colors.white,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const ScannerScreen()),
      ),
      child: const Icon(Icons.qr_code_scanner),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WelcomeBanner(),
        const SizedBox(height: AppSpacing.stackMd),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
          ),
          child: SearchBarWidget(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackLg),
        // Padding(
        //   padding: const EdgeInsets.symmetric(
        //     horizontal: AppSpacing.containerMargin,
        //   ),
        //   child: Row(
        //     children: [
        //       Text(
        //         AppLocalizations.departments,
        //         style: context.textStyles.displaySmall,
        //       ),
        //       const Spacer(),
        //       TextButton(
        //         onPressed: () {},
        //         child: Text(AppLocalizations.viewAll),
        //       ),
        //     ],
        //   ),
        // ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.containerMargin,
              vertical: AppSpacing.gutter,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.stackSm,
                    ),
                    child: Text(
                      AppLocalizations.departments,
                      style: context.textStyles.displaySmall,
                    ),
                  ),
                  BlocBuilder<DepartmentCubit, DepartmentState>(
                    builder: (context, state) {
                      if (state.status == DepartmentStatus.loading) {
                        return const Expanded(
                          child: DepartmentListSkeleton(),
                        );
                      } else if (state.status == DepartmentStatus.error) {
                        return AppErrorWidget(
                          onRetry: () =>
                              context.read<DepartmentCubit>().loadDepartments(),
                        );
                      } else if (state.status == DepartmentStatus.empty ||
                          state.departments.isEmpty) {
                        return const SizedBox(
                          height: 200,
                          child: EmptyWidget(),
                        );
                      }
                      return Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.stackSm,
                          ),
                          itemCount: state.departments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.stackSm),
                          itemBuilder: (_, i) => DepartmentTile(
                            key: ValueKey(state.departments[i].id),
                            department: state.departments[i],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
