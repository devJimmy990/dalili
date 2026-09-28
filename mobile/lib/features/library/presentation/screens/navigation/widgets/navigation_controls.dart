import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/services/map_loader_service.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
import 'package:dalili/features/library/presentation/screens/navigation/ar_navigation_screen.dart';
import 'package:dalili/features/library/presentation/screens/navigation/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads the map immediately on open and shows a destination dropdown —
/// picking a destination goes straight into the QR-scan step, replacing
/// the previous separate "Start Navigation" button + destination-picker
/// screen with a single inline step.
class NavigationControls extends StatefulWidget {
  const NavigationControls({super.key});

  @override
  State<NavigationControls> createState() => _NavigationControlsState();
}

class _NavigationControlsState extends State<NavigationControls> {
  late final Future<LibraryMapModel> _mapFuture;

  @override
  void initState() {
    super.initState();
    _mapFuture = const MapLoaderService().load();
  }

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

          // // Once navigation is active the AR screen owns the experience
          // // (including its own cancel confirmation) — nothing to show here.
          // if (navigating) {
          //   return const SizedBox.shrink();
          // }

          return FutureBuilder<LibraryMapModel>(
            future: _mapFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  AppLocalizations.error,
                  style: const TextStyle(color: Colors.red),
                );
              }

              final map = snapshot.data;

              if (map == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final destinations = map.nodes
                  .where((node) => node.type == 'destination')
                  .toList();

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.navSelectDestinationHint,
                  border: const OutlineInputBorder(),
                ),
                items: destinations
                    .map(
                      (node) => DropdownMenuItem(
                        value: node.id,
                        child: Text(node.name),
                      ),
                    )
                    .toList(),
                onChanged: loading
                    ? null
                    : (endNode) {
                        if (endNode != null) {
                          _onDestinationSelected(context, map, endNode);
                        }
                      },
              );
            },
          );
        },
      );

  Future<void> _onDestinationSelected(
    BuildContext context,
    LibraryMapModel map,
    String endNode,
  ) async {
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

    if (cubit.state.session == null) {
      // Route/session build itself failed (e.g. no path found) — nothing
      // to show in AR. Stay here; the error banner on this screen (see
      // NavigationScreen's BlocBuilder) covers it.
      return;
    }

    // A session exists even if sensors failed to start (e.g. permission
    // denied) — push the AR screen regardless so the user always lands
    // somewhere actionable. The AR screen itself renders the permission
    // error (with a retry) instead of a frozen/blank experience.

    // Navigator.push creates a route that sits outside this BlocProvider's
    // widget subtree, so the cubit instance must be handed to it
    // explicitly via BlocProvider.value.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const ArNavigationScreen()),
      ),
    );
  }
}
