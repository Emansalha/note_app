import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notes_controller.dart';
import '../models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final NotesController controller = Get.find();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  late int selectedColor;
  late String selectedCategory;

  final List<int> colorOptions = [
    0xFF7868E6, // Purple
    0xFFE66868, // Red
    0xFF68E6A7, // Green
    0xFF68C5E6, // Blue
    0xFFE6B868, // Orange
    0xFFE668B3, // Pink
  ];

  final List<String> categories = ['General', 'Work', 'Personal', 'Ideas', 'Urgent'];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
      selectedColor = widget.note!.colorValue;
      selectedCategory = widget.note!.category;
    } else {
      selectedColor = colorOptions[0];
      selectedCategory = categories[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _saveNote,
            icon: const Icon(Icons.check_circle_outline, size: 30),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient matching selected color
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(selectedColor), const Color(0xFF1A1A2E)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Category Selector
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedCategory == categories[index];
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = categories[index]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Color Picker
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: colorOptions.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedColor == colorOptions[index];
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = colorOptions[index]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            width: 35,
                            decoration: BoxDecoration(
                              color: Color(colorOptions[index]),
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                              boxShadow: isSelected ? [BoxShadow(color: Colors.black26, blurRadius: 10)] : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 20),
                  TextField(
                    controller: contentController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Type your thoughts...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Empty Title', 'Please give your note a title');
      return;
    }

    NoteModel newNote = NoteModel(
      id: widget.note?.id,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? Timestamp.now(),
      colorValue: selectedColor,
      category: selectedCategory,
    );

    if (widget.note == null) {
      controller.addNote(newNote);
    } else {
      controller.updateNote(newNote);
    }
    Get.back();
  }
}
