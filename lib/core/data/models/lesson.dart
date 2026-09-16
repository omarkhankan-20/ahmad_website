/// One lesson. Mirrors GET /lessons.
///
/// There is deliberately no videoUrl field: the playable link is fetched
/// per-play from GET /lessons/{id}/stream, signed and short-lived. A url
/// sitting in this model would end up in the page payload, where anyone can
/// read it out of the network tab - which is how course leaks usually start.
class Lesson {
  const Lesson({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.durationSeconds,
    this.isFree = false,
    this.attachmentUrl,
    this.isCompleted = false,
  });

  final String id;
  final int order;
  final String title;
  final String description;
  final int durationSeconds;
  final bool isFree;
  final String? attachmentUrl;
  final bool isCompleted;

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Lesson copyWith({bool? isCompleted}) => Lesson(
        id: id,
        order: order,
        title: title,
        description: description,
        durationSeconds: durationSeconds,
        isFree: isFree,
        attachmentUrl: attachmentUrl,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String? ?? '',
        order: json['order'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        isFree: json['isFree'] as bool? ?? false,
        attachmentUrl: json['attachmentUrl'] as String?,
      );
}