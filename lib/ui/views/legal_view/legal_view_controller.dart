import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/data/models/app_data_models.dart';
import '../../../core/services/app_data_service.dart';

class LegalViewController extends GetxController {
  /// Which document to render is read from the URL, so /terms and /privacy
  /// each stay a real, linkable, bookmarkable page.
  bool get isTerms => Get.currentRoute == Routes.terms;

  String get title => isTerms ? 'الشروط والأحكام' : 'سياسة الخصوصية';

  /// Text comes from the dashboard, not the app: Ahmad edits these without a
  /// rebuild, and a legal document that needs a release to fix is a liability.
  List<LegalClause> get clauses => isTerms ? appData.terms : appData.privacy;

  /// Every clause carries its own updated_at; the newest one dates the page.
  String get lastUpdated {
    final dates =
        clauses.map((c) => c.updatedAt).where((d) => d.isNotEmpty).toList()
          ..sort();
    if (dates.isEmpty) return '';
    // Date only - the time of day is noise on a legal page.
    return dates.last.split(' ').first;
  }
}
