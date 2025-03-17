// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/daily_routine.dart';
import '../models/routine_step.dart';

class RoutineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Get today's routine
  Future<DailyRoutine> getTodayRoutine() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final snapshot = await _firestore
          .collection('routines')
          .where('date', isEqualTo: today.millisecondsSinceEpoch)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return DailyRoutine.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>
        );
      } else {
        final newRoutine = DailyRoutine.create();
        await saveRoutine(newRoutine);
        return newRoutine;
      }
    } catch (e) {
      debugPrint('Error loading routine: $e');
      // Return a new routine if there's an error
      return DailyRoutine.create();
    }
  }
  
  // Save routine to Firestore
  Future<void> saveRoutine(DailyRoutine routine) async {
    try {
      await _firestore
          .collection('routines')
          .doc(routine.id)
          .set(routine.toMap());
    } catch (e) {
      debugPrint('Error saving routine: $e');
      throw Exception('Failed to save routine');
    }
  }
  
  // Update a step in the routine
  Future<DailyRoutine> updateRoutineStep(DailyRoutine routine, int index, RoutineStep updatedStep) async {
    final updatedRoutine = routine.updateStep(index, updatedStep);
    await saveRoutine(updatedRoutine);
    return updatedRoutine;
  }
  
  // Toggle step completion
  Future<DailyRoutine> toggleStepCompletion(DailyRoutine routine, int index) async {
    final step = routine.steps[index];
    final updatedStep = step.copyWith(
      isCompleted: !step.isCompleted,
      timestamp: DateTime.now(),
    );
    
    return await updateRoutineStep(routine, index, updatedStep);
  }
  
  // Update step product name
  Future<DailyRoutine> updateStepProduct(DailyRoutine routine, int index, String productName) async {
    final step = routine.steps[index];
    final updatedStep = step.copyWith(productName: productName);
    
    return await updateRoutineStep(routine, index, updatedStep);
  }
  
  // Upload photo for a step
  Future<DailyRoutine> uploadStepPhoto(DailyRoutine routine, int index, File photoFile) async {
    try {
      final step = routine.steps[index];
      final fileName = '${routine.id}_${step.type.toString()}.jpg';
      final ref = _storage.ref().child('routine_photos/$fileName');
      
      await ref.putFile(photoFile);
      final downloadUrl = await ref.getDownloadURL();
      
      final updatedStep = step.copyWith(
        photoUrl: downloadUrl,
        isCompleted: true,
        timestamp: DateTime.now(),
      );
      
      return await updateRoutineStep(routine, index, updatedStep);
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      throw Exception('Failed to upload photo');
    }
  }
  
  // Get recent routines
  Future<List<DailyRoutine>> getRecentRoutines(int days) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);
    
    try {
      final snapshot = await _firestore
          .collection('routines')
          .where('date', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => DailyRoutine.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting recent routines: $e');
      return [];
    }
  }
}

