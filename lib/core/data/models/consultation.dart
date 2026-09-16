import '../../enums/consultation_status.dart';

class Consultation {
  const Consultation({
    required this.id,
    required this.status,
    this.accountLink = '',
    this.field = '',
    this.goal = '',
    this.preferredTime = '',
    this.scheduledAt,
    this.meetingLink,
  });

  final String id;
  final ConsultationStatus status;

  /// The brief the buyer submitted before paying. Shown back to them so they
  /// can check what Ahmad will be preparing from.
  final String accountLink;
  final String field;
  final String goal;
  final String preferredTime;

  final DateTime? scheduledAt;
  final String? meetingLink;

  factory Consultation.fromJson(Map<String, dynamic> json) => Consultation(
        id: json['id'] as String? ?? '',
        status: consultationStatusFrom(json['status'] as String?),
        accountLink: json['accountLink'] as String? ?? '',
        field: json['field'] as String? ?? '',
        goal: json['goal'] as String? ?? '',
        preferredTime: json['preferredTime'] as String? ?? '',
        scheduledAt: json['scheduledAt'] == null
            ? null
            : DateTime.tryParse(json['scheduledAt'] as String),
        meetingLink: json['meetingLink'] as String?,
      );
}