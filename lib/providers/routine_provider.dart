// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/daily_routine.dart';

class RoutineProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  DailyRoutine? _todayRoutine;
  bool _isLoading = false;
  
  DailyRoutine? get todayRoutine => _todayRoutine;
  bool get isLoading => _isLoading;
  
  RoutineProvider() {
    _loadTodayRoutine();
  }
  
  Future<void> _loadTodayRoutine() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final snapshot = await _firestore
          .collection('routines')
          .where('date', isEqualTo: today.millisecondsSinceEpoch)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        _todayRoutine = DailyRoutine.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>
        );
      } else {
        _todayRoutine = DailyRoutine.create();
        await _saveRoutine(_todayRoutine!);
      }
    } catch (e) {
      debugPrint('Error loading routine: $e');
      _todayRoutine = DailyRoutine.create();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _saveRoutine(DailyRoutine routine) async {
    try {
      await _firestore
          .collection('routines')
          .doc(routine.id)
          .set(routine.toMap());
    } catch (e) {
      debugPrint('Error saving routine: $e');
    }
  }
  
  Future<void> toggleStepCompletion(int index) async {
    if (_todayRoutine == null) return;
    
    final step = _todayRoutine!.steps[index];
    final updatedStep = step.copyWith(
      isCompleted: !step.isCompleted,
      timestamp: DateTime.now(),
    );
    
    final updatedRoutine = _todayRoutine!.updateStep(index, updatedStep);
    _todayRoutine = updatedRoutine;
    notifyListeners();
    
    await _saveRoutine(updatedRoutine);
  }
  
  Future<void> updateStepProduct(int index, String productName) async {
    if (_todayRoutine == null) return;
    
    final step = _todayRoutine!.steps[index];
    final updatedStep = step.copyWith(productName: productName);
    
    final updatedRoutine = _todayRoutine!.updateStep(index, updatedStep);
    _todayRoutine = updatedRoutine;
    notifyListeners();
    
    await _saveRoutine(updatedRoutine);
  }
  
  Future<void> uploadStepPhoto(int index, File photoFile) async {
    if (_todayRoutine == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final step = _todayRoutine!.steps[index];
      final fileName = '${_todayRoutine!.id}_${step.type.toString()}.jpg';
      final ref = _storage.ref().child('routine_photos/$fileName');
      
      await ref.putFile(photoFile);
      final downloadUrl = await ref.getDownloadURL();
      
      final updatedStep = step.copyWith(
        photoUrl: downloadUrl,
        isCompleted: true,
        timestamp: DateTime.now(),
      );
      
      final updatedRoutine = _todayRoutine!.updateStep(index, updatedStep);
      _todayRoutine = updatedRoutine;
      
      await _saveRoutine(updatedRoutine);
    } catch (e) {
      debugPrint('Error uploading photo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
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

