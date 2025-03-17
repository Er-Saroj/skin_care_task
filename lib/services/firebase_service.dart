import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // Upload image to Firebase Storage
  static Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  // Save data to Firestore
  static Future<bool> saveData(String collection, String document, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(document).set(data);
      return true;
    } catch (e) {
      print('Error saving data: $e');
      return false;
    }
  }
  
  // Get data from Firestore
  static Future<Map<String, dynamic>?> getData(String collection, String document) async {
    try {
      final doc = await _firestore.collection(collection).doc(document).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting data: $e');
      return null;
    }
  }
  
  // Update data in Firestore
  static Future<bool> updateData(String collection, String document, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(document).update(data);
      return true;
    } catch (e) {
      print('Error updating data: $e');
      return false;
    }
  }
}

