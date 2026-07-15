import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationInfoCard extends StatelessWidget {
  const NavigationInfoCard({super.key, required this.state, required this.map});

  final NavigationState state;
  final LibraryMapModel? map;

  @override
  Widget build(BuildContext context) {
    final session = state.session;

    if (session == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (state.decision != null)
              Text(
                state.decision!.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 12),

            Text(
              session.currentInstruction.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: session.progress.progress(session.currentSegment),
            ),

            const SizedBox(height: 16),

            Text(
              "Remaining : ${session.progress.remainingDistance.toStringAsFixed(1)} m",
            ),

            const SizedBox(height: 8),

            Text("Heading : ${session.heading.toStringAsFixed(1)}°"),

            if (state.decision != null) ...[
              const SizedBox(height: 4),
              Text(
                "Target Difference : ${state.decision!.angleDifference.toStringAsFixed(1)}°",
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Scan QR Again"),
                onPressed: () async {
                  final nodeId = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NavigationInfoCard(state: state, map: state.map),
                    ),
                  );

                  if (nodeId == null) {
                    return;
                  }

                  if (!context.mounted) {
                    return;
                  }

                  await context.read<NavigationCubit>().updateCurrentPosition(
                    nodeId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
