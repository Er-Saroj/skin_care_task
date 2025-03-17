import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/streak_data.dart';
import '../models/daily_routine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StreakRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache keys
  static const String _streakDataKey = 'streak_data';
  
  // Get streak data with caching for better performance
  Future<StreakData> getStreakData() async {
    try {
      // Try to get from cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_streakDataKey);
      
      if (cachedData != null) {
        try {
          final streakMap = json.decode(cachedData) as Map<String, dynamic>;
          return StreakData.fromMap(streakMap);
        } catch (e) {
          debugPrint('Error parsing cached streak data: $e');
          // Continue to fetch from Firestore if cache parsing fails
        }
      }
      
      // If not in cache, fetch from Firestore
      final doc = await _firestore
          .collection('streaks')
          .doc('user_streak') // In a real app, use the user's ID
          .get();
      
      StreakData streakData;
      if (doc.exists) {
        streakData = StreakData.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        streakData = StreakData();
        await saveStreakData(streakData);
      }
      
      // Cache the streak data
      await prefs.setString(_streakDataKey, json.encode(streakData.toMap()));
      
      return streakData;
    } catch (e) {
      debugPrint('Error loading streak data: $e');
      return StreakData();
    }
  }
  
  // Save streak data to Firestore and update cache
  Future<void> saveStreakData(StreakData streakData) async {
    try {
      // Save to Firestore
      await _firestore
          .collection('streaks')
          .doc('user_streak') // In a real app, use the user's ID
          .set(streakData.toMap());
      
      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_streakDataKey, json.encode(streakData.toMap()));
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
  
  // Clear cache (useful for testing or when user logs out)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_streakDataKey);
  }
}

