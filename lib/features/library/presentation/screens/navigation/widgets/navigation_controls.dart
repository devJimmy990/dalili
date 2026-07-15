import 'package:dalili/core/services/map_loader_service.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/screens/navigation/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.endNode});

  final String endNode;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NavigationCubit>().state;
    final cubit = context.read<NavigationCubit>();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: state.loading || state.navigating
                ? null
                : () async {
                    final map = await const MapLoaderService().load();

                    if (!context.mounted) return;

                    final startNode = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QRScannerScreen(
                          mode: QRScanMode.startNavigation,
                          map: map,
                        ),
                      ),
                    );

                    if (startNode == null) return;

                    if (!context.mounted) return;

                    context.read<NavigationCubit>().startNavigation(
                      startNode: startNode,
                      endNode: endNode,
                    );
                  },
            child: const Text("Start Navigation"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: state.navigating ? cubit.stopNavigation : null,
            child: const Text("Stop Navigation"),
          ),
        ),
      ],
    );
  }
}
