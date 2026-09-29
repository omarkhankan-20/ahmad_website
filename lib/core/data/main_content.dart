import 'package:flutter/material.dart';

import '../enums/offering_type.dart';
import 'models/content_models.dart';

/// Static copy for the landing page, all of it from Ahmad.
///
/// The course is RECORDED, self-paced, lifetime access. Nothing here may imply
/// a live session: no "within hours", no "limited seats", no "reserve your
/// place", no "workshop". A buyer who expects a live class and finds videos
/// asks for a refund.
///
/// Still needed from Ahmad before launch:
///   - final prices for both products
///   - real student testimonials (name + result + permission to publish)
///   - refund policy
///   - Whish / OMT numbers and the beneficiary name
///   - terms of service and privacy policy text
///
/// Prices and product data are placeholders: once the API is live they come
/// from GET /products, not from this file - otherwise Ahmad cannot change a
/// price without a new build.
class MainContent {
  MainContent._();

  static const String creatorName = 'أحمد الحسيني';
  static const String eyebrow = 'صانع محتوى منذ 2015';
  static const String headline = 'كون صانع محتوى، ليس مجرد صانع فيديوهات';
  static const String subheadline =
      'مش شروحات نظرية. نظام متكامل بياخد بإيدك من الفكرة لحدّ التنفيذ، '
      'تتابعه بوقتك ومن مكانك.';

  /// A recorded course has no built-in deadline, so nothing pushes the buyer
  /// to decide today. This line is the substitute - and it only works if
  /// Ahmad actually raises the price on that date. A deadline that passes
  /// unchanged teaches people to ignore the next one.
  static const String launchOffer = 'سعر الإطلاق ساري حتى ٣٠ أيلول';

  static const List<Stat> stats = [
    Stat(value: 'أكثر من مليون', label: 'متابع على المنصات'),
    Stat(value: 'أكثر من ١٠٠ مليون', label: 'مشاهدة'),
    Stat(value: '١٠ سنوات', label: 'في صناعة المحتوى'),
  ];

  static const String aboutBody =
      'صانع محتوى منذ ٢٠١٥، وبدأ بفكرة الفيديوهات المجتمعية التوعوية سنة ٢٠٢٤. '
      'اليوم يدرّب الأفراد والشركات على صناعة المحتوى، حضورياً وأونلاين.';

  static const List<String> credentials = [
    'تجهيز كوادر عمل في شركات متخصصة بتسويق المحتوى',
    'مساعدة الأفراد والشركات على فهم تفاعل المنصات مع المحتوى',
    'تدريبات حضورية وأونلاين، إضافة إلى الاستشارات الفردية',
  ];

  static const List<Offering> offerings = [
    Offering(
      id: 'consult_1on1',
      type: OfferingType.consultation,
      title: 'جلسة استشارية',
      // This is the live one. Saying so plainly is what keeps the two
      // products from blurring into each other.
      meta: 'مباشرة · فردية · للأفراد والشركات',
      bullets: [
        'تشخيص دقيق لحسابك',
        'استراتيجية مصمّمة لمجالك',
        'خطوات تطبيق فورية',
      ],
      ctaLabel: 'احجز جلستك',
      icon: Icons.chat_bubble_outline,
    ),
    Offering(
      id: 'course_main',
      type: OfferingType.course,
      title: 'الدورة الكاملة',
      meta: 'مسجّلة · تتابعها بوقتك · وصول دائم',
      bullets: [
        'نظام من الفكرة إلى التنفيذ',
        'خمسة محاور عملية',
        'تحديثات مجانية مدى الحياة',
        'مجموعة خاصة للطلاب مع أحمد',
      ],
      ctaLabel: 'اشترك الآن',
      icon: Icons.school_outlined,
      featured: true,
      badge: 'الأشمل',
    ),
  ];

  /// Ahmad's own wording, from the workshop outline he sent. Kept close to how
  /// he put it: he knows which phrases land with his audience.
  static const List<Module> modules = [
    Module(
      order: 1,
      title: 'مقدمة عن صناعة المحتوى',
      description: 'شو يعني صانع محتوى فعلياً، ووين مكانك بهالمجال.',
    ),
    Module(
      order: 2,
      title: 'كيف أبدأ وشو بحتاج',
      description: 'أول خطوة عملية، والأدوات اللي فعلاً لازمك — مش أكتر.',
    ),
    Module(
      order: 3,
      title: 'استخدام الذكاء الصنعي بالمحتوى',
      description: 'توظيف الأدوات الجديدة بشغلك بدل ما تضيع وقتك فيها.',
    ),
    Module(
      order: 4,
      title: 'أداء الفيديو من الألف للياء',
      description: 'من الفكرة للتصوير للمونتاج — المسار الكامل خطوة خطوة.',
    ),
    Module(
      order: 5,
      title: 'خوارزميات ومحظورات النمو',
      description: 'شو بيرفع وصولك، وشو الأخطاء اللي بتوقّفو بدون ما تنتبه.',
    ),
  ];

  static const List<FaqItem> faqs = [
    // Leads the list on purpose: it is the first thing a buyer wonders about
    // a recorded course, and leaving it unanswered costs sales.
    FaqItem(
      question: 'في مواعيد محددة لازم ألتزم فيها؟',
      answer:
          'لا. الدورة مسجّلة بالكامل، تبدأ وقت ما تحب وتتابعها بالسرعة اللي تناسبك، وتعيد أي درس متى شئت.',
    ),
    FaqItem(
      question: 'بحتاج كاميرا أو معدات غالية؟',
      answer:
          'لا. الدورة مبنية على التصوير بالموبايل من أول درس، والمعدات إضافة لاحقة وليست شرطاً للبداية.',
    ),
    FaqItem(
      question: 'كيف يوصلني المحتوى بعد الدفع؟',
      answer:
          'ترفع صورة إيصال التحويل، ويراجعها أحمد ويفتح لك الحساب. عادةً خلال ٢٤ ساعة، ويصلك إشعار عند التفعيل.',
    ),
    FaqItem(
      question: 'هل الوصول للدورة دائم؟',
      answer:
          'نعم. بعد تفعيل حسابك تبقى الدروس متاحة لك دون حد زمني، مع أي تحديث يضاف لاحقاً بدون رسوم إضافية.',
    ),
    FaqItem(
      question: 'ما الفرق بين الدورة والجلسة الاستشارية؟',
      answer:
          'الدورة نظام تعليمي مسجّل تتابعه بوقتك. الجلسة الاستشارية لقاء مباشر مع أحمد يشخّص حسابك أنت تحديداً ويبني خطة على وضعك الحالي.',
    ),
    // acceptable answer, but the question must not stay unanswered - with
    // manual local payment every buyer asks it.
  ];

  static const List<ResultShot> results = [
    ResultShot(asset: 'assets/images/results/result-1.png'),
    ResultShot(asset: 'assets/images/results/result-2.png'),
    ResultShot(asset: 'assets/images/results/result-3.png'),
    ResultShot(asset: 'assets/images/results/result-4.png'),
    ResultShot(asset: 'assets/images/results/result-5.png'),
    ResultShot(asset: 'assets/images/results/result-6.png'),
    ResultShot(asset: 'assets/images/results/result-7.png'),
  ];

  static const String finalCtaTitle =
      'الفرق بينك وبين صانع محتوى ناجح هو النظام';
  static const String finalCtaBody =
      'توقف عن إهدار الوقت في تجارب غير محسوبة. ابدأ اليوم، وتابع بوقتك.';
}
