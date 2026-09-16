import 'models/payment_method.dart';

/// TODO(ahmad): replace the placeholder numbers below with the real Whish and
/// OMT numbers and the exact beneficiary name as it appears on the account.
/// The site must not be shown to anyone - client included - while these are
/// still XX.
class PaymentContent {
  PaymentContent._();

  static const List<PaymentMethod> methods = [
    PaymentMethod(
      id: 'whish',
      name: 'Whish Money',
      number: '+961 XX XXX XXX',
      beneficiary: 'أحمد الحسيني',
    ),
    PaymentMethod(
      id: 'omt',
      name: 'OMT',
      number: '+961 XX XXX XXX',
      beneficiary: 'أحمد الحسيني',
    ),
  ];

  /// Answers the one fear manual payment creates: "I send money into the void
  /// and then what?"
  static const String reassurance =
      'إذا في أي مشكلة بالتحويل، أحمد بيتواصل معك — ما بينرفض طلبك بصمت.';

  static const String reviewNote = 'التفعيل عادةً خلال ٢٤ ساعة من المراجعة.';
}