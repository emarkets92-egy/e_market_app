import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/points_cubit.dart';
import '../cubit/points_state.dart';

class PointsDisplay extends StatelessWidget {
  const PointsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PointsCubit, PointsState>(
      bloc: di.sl<PointsCubit>(),
      builder: (context, state) {
        return Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${state.balance}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}
