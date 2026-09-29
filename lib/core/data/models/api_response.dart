class ApiResponse<T> {
  ApiResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    this.model,
    this.fieldErrors = const {},
  });

  final int statusCode;
  final bool status;
  final String message;
  final T? model;

  /// Backend field name -> first message for that field.
  final Map<String, String> fieldErrors;

  bool get isSuccess => status && statusCode.toString().startsWith('2');

  factory ApiResponse.fromJson(dynamic raw) {
    // NetworkUtil hands back { statusCode, response }.
    final int code = (raw is Map ? raw['statusCode'] : null) as int? ?? 0;
    final dynamic body = raw is Map ? raw['response'] : null;

    if (body is! Map) {
      return ApiResponse<T>(
        statusCode: code,
        status: false,
        message: _fallbackMessage(code),
        fieldErrors: const {},
      );
    }

    final bool ok = body['Status'] == true;
    final String message =
        (body['Message'] as String?)?.trim().isNotEmpty == true
            ? body['Message'] as String
            : _fallbackMessage(code);

    return ApiResponse<T>(
      statusCode: code,
      status: ok,
      message: message,
      model: body['Model'] as T?,
      fieldErrors: _parseValidation(body['MessageDebug']),
    );
  }

  /// MessageDebug.validation is { field: [msg, msg] }. Only the first message
  /// per field is shown - the screen has room for one line under each input.
  static Map<String, String> _parseValidation(dynamic debug) {
    if (debug is! Map) return const {};
    final validation = debug['validation'];
    if (validation is! Map) return const {};

    final result = <String, String>{};
    validation.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key.toString()] = value.first.toString();
      } else if (value != null) {
        result[key.toString()] = value.toString();
      }
    });
    return result;
  }

  static String _fallbackMessage(int code) {
    switch (code) {
      case 0:
        return 'ما قدرنا نتصل بالسيرفر — تأكد من الإنترنت';
      case 401:
        return 'انتهت الجلسة، سجّل دخولك من جديد';
      case 403:
        return 'ما عندك صلاحية لهالعملية';
      case 404:
        return 'الطلب غير موجود';
      case 422:
        return 'تحقق من البيانات';
      case 429:
        return 'محاولات كتير — استنى شوي وجرّب بعدين';
      case 500:
      case 503:
        return 'في مشكلة بالسيرفر، جرّب بعد شوي';
      default:
        return 'صار خطأ غير متوقع';
    }
  }
}

/// What a repository returns on the Left side. Carries the field errors too -
/// a plain String would drop them, and the forms render errors per input.
class ApiFailure {
  const ApiFailure(this.message, {this.fields = const {}});

  final String message;
  final Map<String, String> fields;

  bool get hasFields => fields.isNotEmpty;
}