import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import '../controllers/notes_controller.dart';
import '../models/note_model.dart';
import 'add_note_screen.dart';

class HomeScreen extends StatelessWidget {
  final NotesController controller = Get.put(NotesController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () => _showSearchDialog(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7868E6), Color(0xFF343A70), Color(0xFF1A1A2E)],
              ),
            ),
          ),
          // Animated Bubbles for extra aesthetic
          Positioned(
            top: -50,
            right: -50,
            child: _buildBubble(200, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: _buildBubble(150, Colors.purple.withOpacity(0.1)),
          ),
          // Main Content
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (controller.filteredNotes.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: controller.filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = controller.filteredNotes[index];
                  return OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedElevation: 0,
                    closedColor: Colors.transparent,
                    openBuilder: (context, _) => AddNoteScreen(note: note),
                    closedBuilder: (context, openContainer) => 
                      _buildNoteCard(note, openContainer),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) => AddNoteScreen(),
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        closedColor: const Color(0xFF7868E6),
        closedBuilder: (context, openContainer) => SizedBox(
          height: 56,
          width: 56,
          child: Center(
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 100, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            controller.searchQuery.value.isEmpty 
              ? 'Start your creative journey...\nAdd your first note!'
              : 'No notes match your search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 18, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, VoidCallback onTap) {
    String formattedDate = DateFormat('MMM d, h:mm a').format(note.createdAt.toDate());
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(note.colorValue).withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          note.category,
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white60, size: 22),
                        onPressed: () => _confirmDelete(note.id!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Search Notes",
      titleStyle: const TextStyle(color: Color(0xFF343A70)),
      backgroundColor: Colors.white.withOpacity(0.9),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: "Search title or content...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
      confirm: TextButton(onPressed: () => Get.back(), child: const Text("Done")),
    );
  }

  void _confirmDelete(String id) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Delete Note?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("This action cannot be undone. Are you sure?"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                    onPressed: () {
                      controller.deleteNote(id);
                      Get.back();
                    },
                    child: const Text("Delete"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
