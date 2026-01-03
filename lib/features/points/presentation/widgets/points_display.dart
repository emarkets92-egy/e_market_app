import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class PointsDisplay extends StatelessWidget {
  const PointsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: di.sl<AuthCubit>(),
      builder: (context, state) {
        final points = state.user?.points ?? 0;
        return Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber),
            const SizedBox(width: 4),
            Text('$points', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }
}
