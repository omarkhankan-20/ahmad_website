/// A local transfer destination shown on the checkout page.
///
/// These are real money destinations, so they never get hardcoded in a widget:
/// one wrong digit means a customer transfers to a stranger, and that becomes
/// your problem, not theirs.
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.name,
    required this.number,
    required this.beneficiary,
    this.note,
  });

  final String id;
  final String name;

  /// Kept as a display string with its country code. Never reformatted in the
  /// UI - what the customer copies must match what Ahmad receives.
  final String number;

  final String beneficiary;
  final String? note;
}