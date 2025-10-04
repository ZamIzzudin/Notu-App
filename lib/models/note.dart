// import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? imagePath; // Path to stored image
  final bool isPinned;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.isPinned = false,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  // Copy with method untuk update
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? imagePath,
    bool? clearImage,
    bool? isPinned,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePath: clearImage == true ? null : (imagePath ?? this.imagePath),
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert Note to JSON untuk database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'imagePath': imagePath,
      'isPinned': isPinned ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      color: json['color'] as int,
      imagePath: json['imagePath'] as String?,
      isPinned: (json['isPinned'] as int) == 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content,imagePath:$imagePath, isPinned: $isPinned, color: $color, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
