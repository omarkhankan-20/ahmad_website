import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/legal_content.dart';

class LegalViewController extends GetxController {
  /// Which document to render is read from the URL, so /terms and /privacy
  /// each stay a real, linkable, bookmarkable page.
  bool get isTerms => Get.currentRoute == Routes.terms;

  String get title => isTerms ? 'الشروط والأحكام' : 'سياسة الخصوصية';

  List<LegalSection> get sections =>
      isTerms ? LegalContent.terms : LegalContent.privacy;
}