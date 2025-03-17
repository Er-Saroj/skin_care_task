import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/streak_data.dart';
import '../models/daily_routine.dart';

class StreakRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get streak data
  Future<StreakData> getStreakData() async {
    try {
      final doc = await _firestore
          .collection('streaks')
          .doc('user_streak') // In a real app, use the user's ID
          .get();
      
      if (doc.exists) {
        return StreakData.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        final newStreakData = StreakData();
        await saveStreakData(newStreakData);
        return newStreakData;
      }
    } catch (e) {
      debugPrint('Error loading streak data: $e');
      return StreakData();
    }
  }
  
  // Save streak data
  Future<void> saveStreakData(StreakData streakData) async {
    try {
      await _firestore
          .collection('streaks')
          .doc('user_streak') // In a real app, use the user's ID
          .set(streakData.toMap());
    } catch (e) {
      debugPrint('Error saving streak data: $e');
      throw Exception('Failed to save streak data');
    }
  }
  
  // Update streak with completed routine
  Future<StreakData> updateStreakWithRoutine(StreakData streakData, DailyRoutine routine) async {
    if (!routine.isCompleted) return streakData;
    
    final updatedStreak = streakData.addCompletionDay(routine.date);
    await saveStreakData(updatedStreak);
    return updatedStreak;
  }
  
  // Set target streak
  Future<StreakData> setTargetStreak(StreakData streakData, int target) async {
    final updatedStreak = streakData.copyWith(targetStreak: target);
    await saveStreakData(updatedStreak);
    return updatedStreak;
  }
}

