/// Course → units → lessons, exactly as /api/courses/filter and
/// /api/courses/details return it.
///
/// Access is decided by the server per lesson. `contentUrl` comes back null
/// when the viewer has not paid, while `previewUrl` is always present - so a
/// visitor can sample every lesson before buying.

class Course {
  const Course({
    required this.id,
    required this.title,
    this.thumbnail = '',
    this.shortDescription = '',
    this.description = '',
    this.price = '',
    this.isFree = false,
    this.comingSoon = false,
    this.isPurchased = false,
    this.totalDuration = '',
    this.subscribeCount = 0,
    this.units = const [],
  });

  final int id;
  final String title;
  final String thumbnail;
  final String shortDescription;
  final String description;

  /// Kept as the string the server sends. Parsing it into a double and
  /// reformatting risks showing a different number than the buyer transfers.
  final String price;

  final bool isFree;
  final bool comingSoon;
  final bool isPurchased;
  final String totalDuration;
  final int subscribeCount;
  final List<CourseUnit> units;

  int get lessonCount =>
      units.fold(0, (sum, unit) => sum + unit.lessons.length);

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as int? ?? 0,
        title: json['title']?.toString() ?? '',
        thumbnail: json['thumbnail']?.toString() ?? '',
        shortDescription: json['short_description']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: json['price']?.toString() ?? '',
        isFree: json['is_free'] == true,
        comingSoon: json['coming_soon'] == true,
        isPurchased: json['is_purchased'] == true,
        totalDuration: json['total_duration']?.toString() ?? '',
        subscribeCount: json['subscribe_count'] as int? ?? 0,
        units: (json['units'] as List?)
                ?.whereType<Map>()
                .map((e) => CourseUnit.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );
}

class CourseUnit {
  const CourseUnit({
    required this.id,
    required this.title,
    this.position = 0,
    this.isFree = false,
    this.comingSoon = false,
    this.isPurchased = false,
    this.lessons = const [],
  });

  final int id;
  final String title;
  final int position;
  final bool isFree;
  final bool comingSoon;
  final bool isPurchased;
  final List<CourseLesson> lessons;

  /// Shown on the unit header, so a student sees the length before opening it.
  int get totalMinutes =>
      lessons.fold(0, (sum, lesson) => sum + lesson.durationMinutes);

  bool get hasAnyAccess => lessons.any((l) => l.canAccess);

  factory CourseUnit.fromJson(Map<String, dynamic> json) => CourseUnit(
        id: json['id'] as int? ?? 0,
        title: json['title']?.toString() ?? '',
        position: json['position'] as int? ?? 0,
        isFree: json['is_free'] == true,
        comingSoon: json['coming_soon'] == true,
        isPurchased: json['is_purchased'] == true,
        lessons: (json['lessons'] as List?)
                ?.whereType<Map>()
                .map((e) => CourseLesson.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );
}

class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.title,
    this.position = 0,
    this.contentUrl,
    this.previewUrl,
    this.isFree = false,
    this.comingSoon = false,
    this.isPurchased = false,
    this.canAccess = false,
    this.durationMinutes = 0,
    this.durationForHumans = '',
  });

  final int id;
  final String title;
  final int position;

  /// Bunny embed url, signed and time limited. Null when the viewer has no
  /// access - the server decides, not the client.
  final String? contentUrl;

  /// Always present: a short sample the server serves to anyone.
  final String? previewUrl;

  final bool isFree;
  final bool comingSoon;
  final bool isPurchased;
  final bool canAccess;
  final int durationMinutes;
  final String durationForHumans;

  /// What the player should load. Falls back to the preview so a locked
  /// lesson still shows something instead of an empty frame.
  String? get playableUrl => canAccess && contentUrl != null
      ? contentUrl
      : previewUrl;

  bool get isLocked => !canAccess;

  factory CourseLesson.fromJson(Map<String, dynamic> json) => CourseLesson(
        id: json['id'] as int? ?? 0,
        title: json['title']?.toString() ?? '',
        position: json['position'] as int? ?? 0,
        contentUrl: json['content_url']?.toString(),
        previewUrl: json['preview_url']?.toString(),
        isFree: json['is_free'] == true,
        comingSoon: json['coming_soon'] == true,
        isPurchased: json['is_purchased'] == true,
        canAccess: json['can_access'] == true,
        durationMinutes: json['duration_minutes'] as int? ?? 0,
        durationForHumans: json['duration_for_humans']?.toString() ?? '',
      );
}