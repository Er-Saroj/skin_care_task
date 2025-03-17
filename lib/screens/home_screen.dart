import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaipur/blocs/routine/routine_state.dart';
import '../blocs/routine/routine_bloc.dart';
import '../blocs/streak/streak_bloc.dart';
import '../blocs/streak/streak_event.dart';
import '../widgets/routine_tab.dart';
import '../widgets/streaks_tab.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _tabs = [
    const RoutineTab(),
    const StreaksTab(),
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Listen for routine updates to update streak
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routineBloc = BlocProvider.of<RoutineBloc>(context);
      final streakBloc = BlocProvider.of<StreakBloc>(context);
      
      routineBloc.stream.listen((state) {
        if (state is RoutineLoaded && state.routine.isCompleted) {
          streakBloc.add(UpdateStreakWithRoutine(state.routine));
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _tabs[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.lightTextColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.spa_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.spa),
            ),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.local_fire_department_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.local_fire_department),
            ),
            label: 'Streaks',
          ),
        ],
        // Center the items
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 24,
        backgroundColor: Colors.white,
      ),
    );
  }
}

