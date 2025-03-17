// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jaipur/blocs/streak/streak_event.dart';
import '../blocs/streak/streak_bloc.dart';
import '../blocs/streak/streak_state.dart';
import '../theme/app_theme.dart';

class StreaksTab extends StatelessWidget {
  const StreaksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state is StreakError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<StreakBloc>().add(LoadStreak());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is StreakLoaded) {
          final streakData = state.streakData;
          final selectedPeriod = state.selectedPeriod;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Streaks',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 24),
                  _buildGoalCard(streakData.currentStreak, streakData.targetStreak),
                  const SizedBox(height: 24),
                  _buildStreakStatsCard(streakData.currentStreak, streakData.last30DaysPercentage),
                  const SizedBox(height: 24),
                  _buildChartCard(context, streakData, selectedPeriod),
                  const SizedBox(height: 24),
                  _buildGetStartedButton(context),
                ],
              ),
            ),
          );
        }
        
        // Initial state or fallback
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
  
  Widget _buildGoalCard(int currentStreak, int targetStreak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Goal: $targetStreak streak days',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Streak Days',
                    style: AppTheme.bodyStyle,
                  ),
                  const Spacer(),
                  Text(
                    '$currentStreak',
                    style: AppTheme.headingStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreakStatsCard(int currentStreak, double last30DaysPercentage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Streak',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              '$currentStreak',
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Last 30 Days',
                  style: AppTheme.captionStyle,
                ),
                const SizedBox(width: 8),
                Text(
                  '${last30DaysPercentage.toStringAsFixed(0)}%',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChartCard(BuildContext context, streakData, String selectedPeriod) {
    final streakBloc = BlocProvider.of<StreakBloc>(context);
    final historyData = streakData.getHistoryForPeriod(
      _getPeriodDays(selectedPeriod)
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _createChartData(historyData),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPeriodButton(context, '1D', selectedPeriod),
                _buildPeriodButton(context, '1W', selectedPeriod),
                _buildPeriodButton(context, '1M', selectedPeriod),
                _buildPeriodButton(context, '3M', selectedPeriod),
                _buildPeriodButton(context, '1Y', selectedPeriod),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Keep it up! You\'re on a roll.',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<FlSpot> _createChartData(List<MapEntry<DateTime, bool>> historyData) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < historyData.length; i++) {
      final value = historyData[i].value ? 1.0 : 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return spots;
  }
  
  Widget _buildPeriodButton(BuildContext context, String period, String selectedPeriod) {
    final isSelected = selectedPeriod == period;
    final streakBloc = BlocProvider.of<StreakBloc>(context);
    
    return InkWell(
      onTap: () {
        streakBloc.updateSelectedPeriod(period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.lightTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppTheme.lightTextColor)),
        onPressed: () {
          // Navigate to routine tab
          Navigator.of(context).pop();
        },
        child: const Text('Get Started'),
      ),
    );
  }
  
  int _getPeriodDays(String period) {
    switch (period) {
      case '1D':
        return 1;
      case '1W':
        return 7;
      case '1M':
        return 30;
      case '3M':
        return 90;
      case '1Y':
        return 365;
      default:
        return 30;
    }
  }
}

