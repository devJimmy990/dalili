import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/presentation/cubits/search/search_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/search/search_state.dart';
import 'package:dalili/features/library/presentation/widgets/book_card.dart';
import 'package:dalili/features/library/presentation/widgets/search_bar_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/empty_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/error_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<SearchCubit>(
    create: (_) => sl<SearchCubit>(),
    child: Builder(
      builder: (context) => Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                ),
                child: SearchBarWidget(
                  editable: true,
                  controller: _controller,
                  onChanged: (v) => context.read<SearchCubit>().search(v),
                ),
              ),
              const SizedBox(height: AppSpacing.stackMd),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state.status == SearchStatus.loading) {
                      return const BookListSkeleton();
                    } else if (state.status == SearchStatus.error) {
                      return const AppErrorWidget();
                    } else if (state.status == SearchStatus.empty) {
                      return EmptyWidget(message: AppLocalizations.noResults);
                    } else if (state.status == SearchStatus.initial) {
                      return EmptyWidget(message: AppLocalizations.searchHint);
                    }
                    return ListView.builder(
                      itemCount: state.results.length,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemBuilder: (_, i) => BookCard(
                        book: state.results[i],
                        key: ValueKey(state.results[i].id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
