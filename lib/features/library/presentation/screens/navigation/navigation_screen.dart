import 'package:dalili/features/library/presentation/cubits/navigation/navigation_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/navigation/navigation_state.dart';
import 'package:dalili/features/library/presentation/screens/navigation/widgets/navigation_controls.dart';
import 'package:dalili/features/library/presentation/screens/navigation/widgets/navigation_info_card.dart';
import 'package:dalili/features/library/presentation/screens/navigation/widgets/navigation_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  static const String endNode = "N6";

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => NavigationCubit(),
    child: Scaffold(
      appBar: AppBar(title: const Text("Indoor Navigation")),
      body: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const NavigationControls(endNode: endNode),

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

              NavigationInfoCard(state: state, map: state.map),

              if (state.map != null && state.session != null)
                Expanded(
                  child: NavigationMapWidget(
                    map: state.map!,
                    session: state.session!,
                  ),
                ),

              if (state.arrived)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "لقد وصلت إلى وجهتك 🎉",
                    style: TextStyle(
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
