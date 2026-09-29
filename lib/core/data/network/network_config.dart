import 'package:ahmad_website/core/data/repository/storage_repository.dart';
import 'package:ahmad_website/core/enums/request_type.dart';

class NetworkConfig {
  static Map<String, String> getHeaders({
    bool? needAuth = false,
    required RequestType type,
    bool isMultipart = false,
    Map<String, String>? extraHeaders,
  }) {
    return {
      if (needAuth!) "Authorization": "Bearer ${storage.token}",
      // MultipartRequest sets its own Content-Type with the boundary; adding
      // application/json here silently breaks the upload.
      if (type != RequestType.get && !isMultipart)
        "Content-Type": "application/json",
      if (extraHeaders != null) ...extraHeaders,
      "Accept-Language": storage.language,
      "Accept": "application/json",
    };
  }
}
