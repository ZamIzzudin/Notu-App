import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/note.dart';
import '../utils/app_theme.dart';
import '../utils/database_helper.dart';

import '../widgets/color_picker.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  int _selectedColor = 0;
  String? _imagePath;
  bool _hasChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
      _imagePath = widget.note!.imagePath;
    }

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note cannot be empty'),
          backgroundColor: AppTheme.deleteColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final id = const Uuid().v4();

      final note = Note(
        id: widget.note?.id ?? id,
        title: _titleController.text.isEmpty
            ? 'Untitled'
            : _titleController.text,
        content: _contentController.text,
        imagePath: _imagePath,
        isPinned: widget.note?.isPinned ?? false,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        color: _selectedColor,
      );

      if (widget.note == null) {
        await DatabaseHelper.instance.create(note);
      } else {
        await DatabaseHelper.instance.update(note);
      }

      if (mounted) {
        Navigator.pop(context, note);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: _isLoading
            ? [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Discard',
                    style: TextStyle(color: AppTheme.deleteColor),
                  ),
                ),
              ],
      ),
    );

    return shouldDiscard ?? false;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Save image to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final savedImage = await File(
          pickedFile.path,
        ).copy('${appDir.path}/$fileName');

        setState(() {
          // Delete old image if exists
          if (_imagePath != null && _imagePath!.isNotEmpty) {
            try {
              File(_imagePath!).deleteSync();
            } catch (e) {
              print('Error deleting old image: $e');
            }
          }
          _imagePath = savedImage.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null && _imagePath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      if (_imagePath != null && _imagePath!.isNotEmpty) {
        try {
          File(_imagePath!).deleteSync();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
      _imagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.noteColors[_selectedColor],
        appBar: AppBar(
          backgroundColor: AppTheme.noteColors[_selectedColor],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.image),
              onPressed: _showImageSourceDialog,
              tooltip: 'Add Image',
            ),
            IconButton(
              icon: const Icon(Icons.check, size: 28),
              onPressed: _saveNote,
              tooltip: 'Save',
            ),
          ],
        ),
        body: Column(
          children: [
            ColorPicker(
              selectedColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                  _hasChanges = true;
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_imagePath != null && _imagePath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_imagePath!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: _removeImage,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        filled: false,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Start typing...',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        filled: false,
                      ),
                      maxLines: null,
                      minLines: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
