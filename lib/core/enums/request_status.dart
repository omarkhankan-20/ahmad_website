/// Mirrors the `status` field on GET /purchase-requests/mine. The screen a
/// buyer sees is decided by this value from the server - never by which
/// button they happened to press to get there.
enum RequestStatus { pending, accepted, rejected }

RequestStatus requestStatusFrom(String? raw) {
  switch (raw) {
    case 'accepted':
      return RequestStatus.accepted;
    case 'rejected':
      return RequestStatus.rejected;
    default:
      return RequestStatus.pending;
  }
}