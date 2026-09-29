/// A booked consultation, as /api/consultations/book and
/// /api/consultations/get-user-consultation-list return it.
///
/// One request carries both the brief and the payment - unlike a course,
/// where the two are separate steps.
class ConsultationBooking {
  const ConsultationBooking({
    required this.id,
    this.accountLink = '',
    this.industry = '',
    this.sessionObjective = '',
    this.preferredTime = '',
    this.paymentMethodName = '',
    this.transactionNumber = '',
    this.amount = '',
    this.status = ConsultationStatus.pending,
    this.sessionDate,
    this.sessionTime,
    this.timezone = '',
    this.meetingLink,
    this.createdAt,
  });

  final int id;
  final String accountLink;

  /// Called "industry" by the API; the form labels it "مجال العمل".
  final String industry;

  final String sessionObjective;

  /// One of morning / afternoon / evening - a request, not a booking.
  final String preferredTime;

  final String paymentMethodName;
  final String transactionNumber;
  final String amount;
  final ConsultationStatus status;

  /// Null until Ahmad schedules it. These are the confirmed slot, as opposed
  /// to preferredTime which is only what the client asked for.
  final String? sessionDate;
  final String? sessionTime;

  /// The zone the session time is stated in. Shown next to the time: a client
  /// abroad reading "6:00" with no zone will miss the call.
  final String timezone;

  final String? meetingLink;
  final DateTime? createdAt;

  bool get isScheduled =>
      status == ConsultationStatus.scheduled && sessionDate != null;

  bool get hasMeetingLink => (meetingLink ?? '').isNotEmpty;

  String get preferredTimeLabel {
    switch (preferredTime) {
      case 'morning':
        return 'صباحاً';
      case 'afternoon':
        return 'بعد الظهر';
      case 'evening':
        return 'مساءً';
      default:
        return preferredTime;
    }
  }

  factory ConsultationBooking.fromJson(Map<String, dynamic> json) =>
      ConsultationBooking(
        id: json['id'] as int? ?? 0,
        accountLink: json['account_link']?.toString() ?? '',
        industry: json['industry']?.toString() ?? '',
        sessionObjective: json['session_objective']?.toString() ?? '',
        preferredTime: json['preferred_time']?.toString() ?? '',
        paymentMethodName: json['payment_method_name']?.toString() ?? '',
        transactionNumber: json['transaction_number']?.toString() ?? '',
        amount: json['amount']?.toString() ?? '',
        status: consultationStatusFrom(json['status']?.toString()),
        sessionDate: json['session_date']?.toString(),
        sessionTime: json['session_time']?.toString(),
        timezone: json['timezone']?.toString() ?? '',
        meetingLink: json['meeting_link']?.toString(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'].toString()),
      );
}

enum ConsultationStatus { pending, scheduled, done, rejected }

/// The API says "paid" where the dashboard says "مقبول"; a paid consultation
/// with no date yet is awaiting scheduling, which the screen treats as its
/// own state.
ConsultationStatus consultationStatusFrom(String? value) {
  switch (value) {
    case 'scheduled':
    case 'paid':
    case 'accepted':
      return ConsultationStatus.scheduled;
    case 'done':
    case 'completed':
      return ConsultationStatus.done;
    case 'rejected':
    case 'refused':
      return ConsultationStatus.rejected;
    default:
      return ConsultationStatus.pending;
  }
}