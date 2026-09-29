import 'dart:convert';
import 'dart:typed_data';
import 'package:ahmad_website/core/enums/request_type.dart';
import 'package:ahmad_website/core/services/session_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class NetworkUtil {
  static String baseUrl = 'dashboard.ahmadalhuseini.com';
  static Future<dynamic> sendRequest({
    required RequestType type,
    required String route,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    var url = Uri.https(baseUrl, route, params);
    http.Response response;

    switch (type) {
      case RequestType.get:
        response = await http.get(url, headers: headers);
        break;
      case RequestType.patch:
        response = await http.patch(
          url,
          body: jsonEncode(body),
          headers: headers,
        );
      case RequestType.post:
        response = await http.post(
          url,
          body: jsonEncode(body),
          headers: headers,
        );
        break;
      case RequestType.delete:
        response = await http.delete(
          url,
          body: jsonEncode(body),
          headers: headers,
        );
        break;
      case RequestType.put:
        response = await http.put(
          url,
          body: jsonEncode(body),
          headers: headers,
        );
        break;
    }

    Map<String, dynamic> jsonResponse = {};
    dynamic result;
    String decodedBody = Utf8Codec().decode(response.bodyBytes);

    try {
      result = jsonDecode(decodedBody);
    } catch (e) {}

    jsonResponse.putIfAbsent(
      'response',
      () => result ?? {'message': decodedBody},
    );

    jsonResponse.putIfAbsent('statusCode', () => response.statusCode);
    SessionHandler.checkStatus(response.statusCode);
    return jsonResponse;
  }

  /// bytes the picker handed back.
  static Future<dynamic> sendMultipartBytes({
    required String route,
    required Map<String, String> fields,
    required String fileField,
    required String fileName,
    required Uint8List fileBytes,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) async {
        final request =
        http.MultipartRequest('POST', Uri.https(baseUrl, route, params));

    request.fields.addAll(fields);
    if (headers != null) request.headers.addAll(headers);

    request.files.add(
      http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fileName,
        contentType: getContentType(fileName),
      ),
    );

    final streamed = await request.send();
    final value = await streamed.stream.bytesToString();

    SessionHandler.checkStatus(streamed.statusCode);

    dynamic decoded;
    try {
      decoded = jsonDecode(value);
    } catch (_) {}

    return {
      'statusCode': streamed.statusCode,
      'response': decoded ?? {'Message': value},
    };
  }

  static MediaType getContentType(String name) {
    //!=> user.png
    //!=> user.png.split('.')  ["user","png"]
    //!=> ["user","png"].last => Png

    var ext = name.split('.').last;
    if (ext == "png" || ext == "jpeg") {
      return MediaType.parse("image/jpg");
    } else if (ext == 'pdf') {
      return MediaType.parse("application/pdf");
    } else {
      return MediaType.parse("image/jpg");
    }
  }
}
