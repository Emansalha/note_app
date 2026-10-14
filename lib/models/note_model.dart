import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteModel {
  String? id;
  String title;
  String content;
  Timestamp createdAt;
  int colorValue; // To store the note's theme color
  String category;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.colorValue = 0xFF7868E6, // Default purple
    this.category = 'General',
  });

  factory NoteModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return NoteModel(
      id: doc.id,
      title: data?['title'] ?? '',
      content: data?['content'] ?? '',
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      colorValue: data?['colorValue'] ?? 0xFF7868E6,
      category: data?['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'colorValue': colorValue,
      'category': category,
    };
  }
}
