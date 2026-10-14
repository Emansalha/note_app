import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';

class NotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observables
  var notes = <NoteModel>[].obs;
  var filteredNotes = <NoteModel>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind the notes stream from Firestore
    notes.bindStream(getNotesStream());
    
    // Listen to changes in notes or search query to update filtered list
    ever(notes, (_) => _filterNotes());
    ever(searchQuery, (_) => _filterNotes());
  }

  Stream<List<NoteModel>> getNotesStream() {
    return _firestore
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      isLoading.value = false;
      return snapshot.docs.map((doc) => NoteModel.fromDocumentSnapshot(doc)).toList();
    });
  }

  void _filterNotes() {
    if (searchQuery.value.isEmpty) {
      filteredNotes.assignAll(notes);
    } else {
      filteredNotes.assignAll(
        notes.where((note) =>
            note.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            note.content.toLowerCase().contains(searchQuery.value.toLowerCase())).toList(),
      );
    }
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await _firestore.collection('notes').add(note.toMap());
      Get.snackbar('Success', 'Note added beautifully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor.withOpacity(0.7),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add note: $e');
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      await _firestore.collection('notes').doc(note.id).update(note.toMap());
      Get.snackbar('Updated', 'Note updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _firestore.collection('notes').doc(id).delete();
    } catch (e) {
      Get.snackbar('Error', 'Delete failed: $e');
    }
  }
}
