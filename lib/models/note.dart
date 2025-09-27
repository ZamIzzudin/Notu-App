class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime modifiedAt;
  int color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    required this.color,
  });
}
