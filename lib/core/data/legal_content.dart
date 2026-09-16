/// Placeholder structure for the terms and privacy pages.
///
/// IMPORTANT: the bodies below are scaffolding, not legal text. They describe
/// how the site actually works so Ahmad (or his lawyer) has something concrete
/// to correct, but nothing here has been reviewed by anyone qualified. Selling
/// a paid product while linking to invented terms is worse than linking to
/// none.
///
/// Must be settled before launch:
///   - refund policy: "no refunds" is a valid answer, silence is not
///   - the legal entity behind the sale, and the country whose law applies
///   - how long receipt images are kept, and who can see them
///   - a contact address for data requests
class LegalSection {
  const LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

class LegalContent {
  LegalContent._();

  /// TODO(ahmad): update whenever the text changes.
  static const String lastUpdated = 'أيلول ٢٠٢٦';

  static const List<LegalSection> terms = [
    LegalSection(
      title: 'الخدمة',
      body:
          'المنصة بتبيع دورة مسجّلة وجلسات استشارية فردية. الدورة بتنفتح على حسابك بعد تأكيد الدفع، والوصول إلها دائم ما دامت المنصة شغّالة.',
    ),
    LegalSection(
      title: 'الحساب',
      body:
          'الحساب شخصي وممنوع مشاركتو. الوصول محدود بعدد أجهزة، وإذا تبيّن إنو الحساب مشترك بين أكتر من شخص، بينعلّق بدون استرجاع.',
    ),
    LegalSection(
      title: 'الدفع والتفعيل',
      body:
          'الدفع بيتم بتحويل محلي، وبترفع صورة الإيصال ليتم التحقق منها يدوياً. التفعيل عادةً خلال ٢٤ ساعة. إذا ما قدرنا نطابق التحويل، بينوصلك سبب واضح وبتقدر تعيد الإرسال.',
    ),
    LegalSection(
      title: 'الاسترجاع',
      // TODO(ahmad): this is the single most asked question with manual
      // payment. Replace with the real policy - whatever it is.
      body: '⚠️ بانتظار نص سياسة الاسترجاع من أحمد.',
    ),
    LegalSection(
      title: 'الملكية الفكرية',
      body:
          'كل محتوى الدورة ملك لصاحب المنصة. ممنوع تسجيلو أو تحميلو أو إعادة نشرو أو بيعو. كل فيديو عليه علامة مائية بمعلومات حسابك، وأي تسريب بينتتبّع لمصدرو.',
    ),
    LegalSection(
      title: 'الجلسات الاستشارية',
      body:
          'الجلسة بتنحدّد بالتنسيق معك بعد تأكيد الدفع. إذا ما حضرت بدون إشعار مسبق، بتُحتسب الجلسة مستهلكة.',
    ),
  ];

  static const List<LegalSection> privacy = [
    LegalSection(
      title: 'شو بنجمع',
      body:
          'اسمك، بريدك الإلكتروني، رقم واتساب، وصورة إيصال التحويل مع اسم المُرسِل ورقم العملية. للجلسات الاستشارية: رابط حسابك ومجالك وهدفك من الجلسة.',
    ),
    LegalSection(
      title: 'ليش بنجمعها',
      body:
          'لفتح حسابك، للتحقق من التحويل، وللتواصل معك بخصوص طلبك. معلومات الجلسة بتُستعمل لتحضير التشخيص قبل موعدك.',
    ),
    LegalSection(
      title: 'صور الإيصالات',
      body:
          'صورة الإيصال بتتخزّن بشكل محمي وما بيوصلها غير صاحب المنصة لغرض التحقق. ما منشاركها مع أي جهة تانية.',
      // TODO(ahmad): add the retention period - how long before receipts are
      // deleted?
    ),
    LegalSection(
      title: 'ما منبيع بياناتك',
      body:
          'ما منبيع ولا منأجّر بياناتك لأي طرف ثالث، وما منستعملها لإعلانات.',
    ),
    LegalSection(
      title: 'حقوقك',
      body:
          'بتقدر تطلب نسخة من بياناتك أو حذف حسابك بأي وقت عبر التواصل معنا.',
      // TODO(ahmad): add the contact address for these requests.
    ),
  ];
}