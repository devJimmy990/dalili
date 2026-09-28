import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
import 'package:dalili/features/library/presentation/screens/navigation/widgets/navigation_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// NOTE: The on-screen map (previously NavigationMapWidget/Painter, driven
// by NavigationImagePositionEngine) was intentionally removed — the
// project now relies entirely on real corridor/destination dimensions
// (width/height) plus the AR screen's directional arrow, rather than
// showing a visual map to the user.

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => NavigationCubit(),
    child: Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.indoorNav)),
      body: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const NavigationControls(),

              if (state.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                ),

              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // NavigationInfoCard(state: state, map: state.map),
              if (state.arrived)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    AppLocalizations.navArrivedMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
