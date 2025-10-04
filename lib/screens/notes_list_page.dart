import 'dart:io';

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../utils/app_theme.dart';
import '../utils/database_helper.dart';
import '../utils/widget_service.dart';

import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/loading_overlay.dart';

import 'add_edit_note_page.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  List<Note> notes = [];
  String searchQuery = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetService.initializeWidget();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      isLoading = true;
    });

    final loadedNotes = await DatabaseHelper.instance.readAllNotes();

    setState(() {
      notes = loadedNotes;
      isLoading = false;
    });

    await WidgetService.updateWidget();
  }

  Future<void> _togglePinNote(Note note) async {
    try {
      await DatabaseHelper.instance.togglePinNote(note.id);
      await WidgetService.updateWidget();
      await _loadNotes();

      final isPinned = note.isPinned ? 'Note unpinned' : 'Note pinned';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPinned),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _deleteNote(Note note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (shouldDelete == true) {
      try {
        await DatabaseHelper.instance.delete(note.id);

        // Delete image if exists
        if (note.imagePath != null && note.imagePath!.isNotEmpty) {
          try {
            await File(note.imagePath!).delete();
          } catch (e) {
            print('Error deleting image: $e');
          }
        }

        // Update widget if deleted note was pinned
        if (note.isPinned) {
          await WidgetService.updateWidget();
        }
        _loadNotes();

        setState(() {
          notes.removeWhere((each) => each.id == note.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting note: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _navigateToAddEdit(BuildContext context, {Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNotePage(note: note)),
    );

    if (result != null && result is Note) {
      setState(() {
        if (note != null) {
          final index = notes.indexWhere((n) => n.id == note.id);
          if (index != -1) {
            notes[index] = result;
          }
        } else {
          notes.insert(0, result);
        }
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
    }
  }

  List<Note> get filteredNotes {
    if (searchQuery.isEmpty) return notes;
    return notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: LoadingOverlay(
        isLoading: isLoading,
        message: 'Memuat catatan...',
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.backgroundColor,
                title: const Text('Notu'),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SearchBar(
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                  ),
                ),
              ),
              if (filteredNotes.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(searchMode: searchQuery.isNotEmpty),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final note = filteredNotes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NoteCard(
                          note: note,
                          onTap: () => _navigateToAddEdit(context, note: note),
                          onDelete: () => _deleteNote(note),
                          onTogglePin: () => _togglePinNote(note),
                        ),
                      );
                    }, childCount: filteredNotes.length),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(context),
        label: const Text('New Note'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// Stateless Widget untuk Search Bar
class SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
