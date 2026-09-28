import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/presentation/cubits/department/department_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/department/department_state.dart';
import 'package:dalili/features/library/presentation/widgets/book_card.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/empty_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/error_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentBooksScreen extends StatefulWidget {
  const DepartmentBooksScreen(this.department, {super.key});

  final Department department;

  @override
  State<DepartmentBooksScreen> createState() => _DepartmentBooksScreenState();
}

class _DepartmentBooksScreenState extends State<DepartmentBooksScreen> {
  late final DepartmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DepartmentCubit>()..loadBooksByDepartment(widget.department);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<DepartmentCubit>.value(
    value: _cubit,
    child: Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(widget.department.name),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: BlocBuilder<DepartmentCubit, DepartmentState>(
        builder: (context, state) {
          if (state.status == DepartmentStatus.loading) {
            return const BookListSkeleton();
          }
          if (state.status == DepartmentStatus.error) {
            return AppErrorWidget(
              onRetry: () => _cubit.loadBooksByDepartment(widget.department),
            );
          }
          if (state.status == DepartmentStatus.empty || state.books.isEmpty) {
            return EmptyWidget(message: AppLocalizations.noResults);
          }
          return ListView.builder(
            itemCount: state.books.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (_, i) => BookCard(
              book: state.books[i],
              key: ValueKey(state.books[i].id),
            ),
          );
        },
      ),
    ),
  );
}
