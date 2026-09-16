import 'models/lesson.dart';

/// Placeholder lessons for building the screen. Replaced by GET /lessons once
/// the API is live - nothing here should survive to production.
class CourseContent {
  CourseContent._();

  static const String courseTitle = 'الدورة الكاملة';

  static const List<Lesson> lessons = [
    Lesson(
      id: 'les_1',
      order: 1,
      title: 'الانطلاقة الفعلية',
      description:
          'ترجم أفكارك إلى محتوى مؤثر بأبسط الأدوات المتاحة حولك، بدون معدات ولا استوديو.',
      durationSeconds: 842,
      // The first lesson stays open: with manual local payment the buyer is
      // taking the bigger risk, and a free sample lifts conversion more than
      // anything else on the page.
      isFree: true,
      attachmentUrl: 'lesson-1-worksheet.pdf',
      isCompleted: true,
    ),
    Lesson(
      id: 'les_2',
      order: 2,
      title: 'الكاريزما والكاميرا',
      description:
          'ابنِ شخصية مميزة أمام الكاميرا يخلق معها الجمهور رابط ثقة وتفاعل.',
      durationSeconds: 1290,
      isCompleted: true,
    ),
    Lesson(
      id: 'les_3',
      order: 3,
      title: 'هندسة النص',
      description:
          'اكتب سكريبتات متماسكة بإيقاع مشدود تربط أجزاء الفكرة بذكاء، من الهوك للخاتمة.',
      durationSeconds: 1125,
      attachmentUrl: 'script-template.pdf',
    ),
    Lesson(
      id: 'les_4',
      order: 4,
      title: 'فن السرد القصصي',
      description:
          'حوّل المعلومة الجافة إلى حبكة ممتعة ترفع معدلات الاحتفاظ بالمشاهد.',
      durationSeconds: 1510,
    ),
    Lesson(
      id: 'les_5',
      order: 5,
      title: 'البصمة البصرية',
      description:
          'وظّف الديكور والإضاءة والمؤثرات لتبني عالماً بصرياً خاصاً ببرنامجك.',
      durationSeconds: 1160,
    ),
  ];
}