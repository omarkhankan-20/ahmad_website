import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/main_content.dart';
import '../../../core/data/models/content_models.dart';
import '../../../core/enums/offering_type.dart';

class ConsultationViewController extends GetxController {
  final name = TextEditingController();
  final whatsapp = TextEditingController();
  final accountLink = TextEditingController();
  final field = TextEditingController();
  final goal = TextEditingController();

  final preferredTime = 'evening'.obs;
  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  /// Values match the API contract exactly, so nothing has to be translated
  /// on the way out.
  static const times = [
    ('morning', 'صباحاً'),
    ('afternoon', 'بعد الضهر'),
    ('evening', 'مساءً'),
  ];

  Offering get offering => MainContent.offerings
      .firstWhere((o) => o.type == OfferingType.consultation);

  void selectTime(String id) => preferredTime.value = id;

  void clearError(String key) {
    if (errors.containsKey(key)) {
      errors.remove(key);
      errors.refresh();
    }
  }

  bool validate() {
    final next = <String, String>{};

    if (name.text.trim().length < 3) {
      next['name'] = 'اكتب اسمك الكامل';
    }

    final phone = whatsapp.text.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(phone)) {
      next['whatsapp'] = 'رقم واتساب غير صحيح — ابدأ برمز الدولة';
    }

    // Ahmad studies the account before the session. Without a usable link the
    // hour gets spent on introductions instead of diagnosis.
    final link = accountLink.text.trim();
    if (link.length < 5 || link.contains(' ')) {
      next['accountLink'] = 'حط رابط حسابك كامل';
    }

    if (field.text.trim().isEmpty) {
      next['field'] = 'شو مجالك؟';
    }

    if (goal.text.trim().length < 15) {
      next['goal'] = 'اكتب بجملتين وين انت هلق ووين بدك توصل';
    }

    errors.value = next;
    return next.isEmpty;
  }

  /// The form is filled BEFORE payment on purpose. Two reasons: writing out a
  /// goal makes the buyer feel the session is being prepared for them, which
  /// justifies the price; and whoever fills it but does not pay is still a
  /// lead Ahmad can follow up. Payment first loses those people silently.
  Future<void> submit() async {
    if (!validate()) return;

    isLoading.value = true;
    // POST /consultations returns an id, which then travels with
    // POST /purchase-requests as consultationId.
    //
    // The endpoint needs a token, so if the visitor is not signed in yet the
    // answers are kept as a draft through signup and sent right after.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;

    Get.toNamed(Routes.checkout, arguments: offering);
  }

  @override
  void onClose() {
    name.dispose();
    whatsapp.dispose();
    accountLink.dispose();
    field.dispose();
    goal.dispose();
    super.onClose();
  }
}