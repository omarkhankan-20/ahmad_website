import 'consultation_models.dart';
import 'purchase_request.dart';
import '../../enums/request_status.dart';

enum OrderKind { course, consultation }

/// Wider than a purchase status: a consultation can also be scheduled or
/// finished, states a course purchase never has.
enum OrderStatus { pending, accepted, rejected, scheduled, done }

/// One row in "طلباتي", whichever product it came from.
///
/// Courses and consultations live behind different endpoints and different
/// models, but to the buyer they are just two things they paid for - so they
/// are merged here rather than split across two screens.
class OrderItem {
  const OrderItem({
    required this.kind,
    required this.title,
    required this.status,
    this.transactionNumber = '',
    this.createdAt,
    this.rejectReason,
    this.purchase,
    this.booking,
  });

  final OrderKind kind;
  final String title;
  final OrderStatus status;
  final String transactionNumber;
  final DateTime? createdAt;
  final String? rejectReason;

  /// The original object, carried so the row can hand it to whichever screen
  /// it opens.
  final PurchaseRequest? purchase;
  final ConsultationBooking? booking;

  bool get isCourse => kind == OrderKind.course;

  factory OrderItem.fromPurchase(PurchaseRequest request) => OrderItem(
        kind: OrderKind.course,
        title: request.productTitle,
        status: switch (request.status) {
          RequestStatus.pending => OrderStatus.pending,
          RequestStatus.accepted => OrderStatus.accepted,
          RequestStatus.rejected => OrderStatus.rejected,
        },
        transactionNumber: request.transactionNumber,
        createdAt: request.createdAt,
        rejectReason: request.rejectReason,
        purchase: request,
      );

  factory OrderItem.fromBooking(ConsultationBooking booking) {
    // Paid but undated is still "accepted" from the buyer's point of view:
    // the money went through, the slot just is not set.
    final status = switch (booking.status) {
      ConsultationStatus.pending => OrderStatus.pending,
      ConsultationStatus.rejected => OrderStatus.rejected,
      ConsultationStatus.done => OrderStatus.done,
      ConsultationStatus.scheduled =>
        booking.sessionDate == null ? OrderStatus.accepted : OrderStatus.scheduled,
    };

    return OrderItem(
      kind: OrderKind.consultation,
      title: 'جلسة استشارية',
      status: status,
      transactionNumber: booking.transactionNumber,
      createdAt: booking.createdAt,
      booking: booking,
    );
  }
}