import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/data/models/consultation_models.dart';
import '../../../core/data/repository/consultation_repository.dart';

class ConsultationStatusViewController extends GetxController {
  final booking = Rxn<ConsultationBooking>();
  final isLoading = false.obs;
  final copiedLink = false.obs;

  final _repo = ConsultationRepository();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ConsultationBooking) {
      booking.value = args;
    } else {
      // Opened directly or reloaded: the newest booking is the one this
      // screen is about.
      load();
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    final result = await _repo.myConsultations();
    isLoading.value = false;

    result.fold((_) {}, (list) {
      if (list.isNotEmpty) booking.value = list.first;
    });
  }

  ConsultationStatus get status =>
      booking.value?.status ?? ConsultationStatus.pending;

  /// Paid but not yet dated is its own state: the money went through, Ahmad
  /// just has not picked a slot. Treating it as "scheduled" would show an
  /// empty date where the client expects one.
  bool get isAwaitingSchedule =>
      status == ConsultationStatus.scheduled &&
      (booking.value?.sessionDate == null);

  Future<void> copyMeetingLink() async {
    final link = booking.value?.meetingLink ?? '';
    if (link.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: link));
    copiedLink.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    copiedLink.value = false;
  }
}