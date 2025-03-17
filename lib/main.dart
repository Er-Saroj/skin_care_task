import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaipur/blocs/routine/routine_event.dart';
import 'package:jaipur/blocs/streak/streak_event.dart';
import 'package:jaipur/firebase_option.dart';
import 'package:jaipur/repositories/routine_repo.dart';
import 'package:jaipur/repositories/streak_repo.dart';
import 'screens/home_screen.dart';
import 'blocs/routine/routine_bloc.dart';
import 'blocs/streak/streak_bloc.dart';
import 'theme/app_theme.dart';
import 'utils/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with your configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up BLoC observer for better debugging
  Bloc.observer = AppBlocObserver();
  
  // Initialize repositories
  final routineRepository = RoutineRepository();
  final streakRepository = StreakRepository();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<RoutineBloc>(
          create: (context) => RoutineBloc(
            routineRepository: routineRepository,
          )..add(LoadRoutine()),
        ),
        BlocProvider<StreakBloc>(
          create: (context) => StreakBloc(
            streakRepository: streakRepository,
            routineRepository: routineRepository,
          )..add(LoadStreak()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Culture Skincare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

