import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => AuthCubit(),
      child: const PosApp(),
    ),
  );
}
