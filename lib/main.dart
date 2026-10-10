import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/logger.dart';
import 'features/wellness/model/wellness_state.dart';
import 'features/wellness/provider/wellness_provider.dart';

/// 恢复本地生活记录后启动应用。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final wellnessRepository = WellnessRepository();
  WellnessState initialWellnessState;
  try {
    initialWellnessState = await wellnessRepository.load();
  } catch (error, stackTrace) {
    Logger.e('生活记录恢复失败', error, stackTrace);
    initialWellnessState = WellnessState.seed().copyWith(loadFailed: true);
  }

  runApp(
    ProviderScope(
      overrides: [
        wellnessRepositoryProvider.overrideWithValue(wellnessRepository),
        initialWellnessStateProvider.overrideWithValue(initialWellnessState),
      ],
      child: const App(),
    ),
  );
}
