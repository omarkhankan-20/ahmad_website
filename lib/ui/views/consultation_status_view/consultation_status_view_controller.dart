import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/data/models/consultation.dart';
import '../../../core/enums/consultation_status.dart';

class ConsultationStatusViewController extends GetxController {
  final consultation = Rxn<Consultation>();
  final isLoading = false.obs;
  final copiedLink = false.obs;

  /// TODO(ahmad): real support number.
  static const String supportWhatsapp = '+961 XX XXX XXX';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Consultation) {
      consultation.value = args;
    } else {
      load();
    }
  }

  /// GET /consultations/mine (or the consultation embedded in the accepted
  /// purchase request).
  Future<void> load() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // TEMP: sample row so the screen can be reviewed. Delete once the
    // endpoint is live - switch `status` to try the other two states.
    consultation.value = Consultation(
      id: 'con_1',
      status: ConsultationStatus.scheduled,
      accountLink: 'instagram.com/ahmad.example',
      field: 'طبخ',
      goal: 'عندي ٣ آلاف متابع وما عم يزيدوا من ٤ شهور، بدي أفهم ليش.',
      preferredTime: 'evening',
      scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
      meetingLink: 'https://meet.google.com/xxx-xxxx-xxx',
    );

    isLoading.value = false;
  }

  ConsultationStatus get status =>
      consultation.value?.status ?? ConsultationStatus.awaiting;

  Future<void> copyMeetingLink() async {
    final link = consultation.value?.meetingLink;
    if (link == null) return;
    await Clipboard.setData(ClipboardData(text: link));
    copiedLink.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    copiedLink.value = false;
  }

  static const _months = [
    'كانون الثاني', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران',
    'تموز', 'آب', 'أيلول', 'تشرين الأول', 'تشرين الثاني', 'كانون الأول',
  ];

  static const _weekdays = [
    'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
    'الجمعة', 'السبت', 'الأحد',
  ];

  /// Written out rather than 2026-09-18 14:00. A session time is something
  /// the buyer has to remember, and a date they can read is one they keep.
  String get scheduleLabel {
    final date = consultation.value?.scheduledAt;
    if (date == null) return '';
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'صباحاً' : 'مساءً';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$weekday ${date.day} $month · $hour:$minute $period';
  }

  String get countdownLabel {
    final date = consultation.value?.scheduledAt;
    if (date == null) return '';
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return '';
    if (diff.inHours < 1) return 'بعد ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'بعد ${diff.inHours} ساعة';
    return 'بعد ${diff.inDays} يوم';
  }
}