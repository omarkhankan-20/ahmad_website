/// Mirrors the `status` field on GET /purchase-requests/mine. The screen a
/// buyer sees is decided by this value from the server - never by which
/// button they happened to press to get there.
enum RequestStatus { pending, accepted, rejected }

RequestStatus requestStatusFrom(String? value) {
  switch (value) {
    // The dashboard labels this "مقبول" but the API value is "paid".
    case 'accepted':
    case 'paid':
    case 'approved':
      return RequestStatus.accepted;
    case 'rejected':
    case 'refused':
      return RequestStatus.rejected;
    default:
      return RequestStatus.pending;
  }
}
