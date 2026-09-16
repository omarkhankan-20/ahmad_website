/// Mirrors the `status` field on the consultation object.
///
/// awaiting  - payment approved, Ahmad has not set a time yet
/// scheduled - a time is fixed
/// done      - the session has happened
enum ConsultationStatus { awaiting, scheduled, done }

ConsultationStatus consultationStatusFrom(String? raw) {
  switch (raw) {
    case 'scheduled':
      return ConsultationStatus.scheduled;
    case 'done':
      return ConsultationStatus.done;
    default:
      return ConsultationStatus.awaiting;
  }
}