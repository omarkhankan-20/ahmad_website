import '../../enums/offering_type.dart';
import '../../enums/request_status.dart';

/// One submitted payment request. Shape follows the API contract, so the
/// pending and rejected screens read the same object the server returns.
class PurchaseRequest {
  const PurchaseRequest({
    required this.id,
    required this.productTitle,
    required this.type,
    required this.senderName,
    required this.transactionNumber,
    required this.status,
    this.amountLabel,
    this.rejectReason,
    this.createdAt,
  });

  final String id;
  final String productTitle;
  final OfferingType type;
  final String senderName;
  final String transactionNumber;
  final RequestStatus status;
  final String? amountLabel;

  /// Set only when status is rejected. Always a real sentence - the buyer
  /// reads it, so "invalid" alone is useless to them.
  final String? rejectReason;

  final DateTime? createdAt;

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(
      id: json['id'] as String? ?? '',
      productTitle: json['productTitle'] as String? ?? '',
      type: json['type'] == 'consultation'
          ? OfferingType.consultation
          : OfferingType.course,
      senderName: json['senderName'] as String? ?? '',
      transactionNumber: json['transactionNumber'] as String? ?? '',
      status: requestStatusFrom(json['status'] as String?),
      rejectReason: json['rejectReason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }
}