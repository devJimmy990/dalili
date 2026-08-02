import 'package:dalili/core/services/map_loader_service.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
import 'package:dalili/features/library/presentation/screens/navigation/ar_navigation_screen.dart';
import 'package:dalili/features/library/presentation/screens/navigation/qr_scanner_screen.dart';
import 'package:dalili/features/library/presentation/screens/navigation/select_destination_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        NavigationCubit,
        NavigationState,
        (bool loading, bool navigating)
      >(
        selector: (state) => (state.loading, state.navigating),
        builder: (context, flags) {
          final (loading, navigating) = flags;
          final cubit = context.read<NavigationCubit>();

          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: loading || navigating
                      ? null
                      : () => _startFlow(context),
                  child: const Text("Start Navigation"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: navigating ? cubit.stopNavigation : null,
                  child: const Text("Stop Navigation"),
                ),
              ),
            ],
          );
        },
      );

  Future<void> _startFlow(BuildContext context) async {
    final map = await const MapLoaderService().load();

    if (!context.mounted) return;

    // Step 1: where do they want to go.
    final endNode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => SelectDestinationScreen(map: map)),
    );

    if (endNode == null || !context.mounted) return;

    // Step 2: where are they starting from (QR scan).
    final startNode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QRScannerScreen(mode: QRScanMode.startNavigation, map: map),
      ),
    );

    if (startNode == null || !context.mounted) return;

    final cubit = context.read<NavigationCubit>();

    await cubit.startNavigation(startNode: startNode, endNode: endNode);

    if (!context.mounted) return;

    if (cubit.state.error != null) {
      // Sensors failed to start (e.g. permission denied) — the AR screen
      // would otherwise show a frozen, never-updating arrow with no
      // visible explanation. Stay here; the error banner already shown
      // on this screen covers it.
      return;
    }

    // Navigator.push creates a route that sits outside this BlocProvider's
    // widget subtree, so the cubit instance must be handed to it
    // explicitly via BlocProvider.value — otherwise the AR screen would
    // have no way to read live navigation updates.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const ArNavigationScreen()),
      ),
    );
  }
}
