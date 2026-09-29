import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../enums/request_type.dart';
import '../../utils/network_util.dart';
import '../models/api_response.dart';
import '../models/purchase_request.dart';
import '../network/network_config.dart';

class PurchaseRepository {
  /// Submits the transfer for review. Multipart because the receipt is a real
  /// file, and on web that file only exists as bytes - there is no path to
  /// hand to MultipartFile.fromPath.
  ///
  /// Known server responses: 422 duplicate transaction, 422 receipt required,
  /// 422 whole course only, 401 unauthorized.
  Future<Either<ApiFailure, PurchaseRequest>> purchaseCourse({
    required int courseId,
    required String paymentMethodCode,
    required String transactionNumber,
    required Uint8List receiptBytes,
    required String receiptName,
  }) async {
    try {
      final raw = await NetworkUtil.sendMultipartBytes(
        route: '/api/purchases/purchase',
        fields: {
          'course_id': courseId.toString(),
          'payment_method_code': paymentMethodCode,
          'transaction_number': transactionNumber,
        },
        fileField: 'receipt',
        fileName: receiptName,
        fileBytes: receiptBytes,
        headers: NetworkConfig.getHeaders(
          needAuth: true,
          type: RequestType.post,
          // Content-Type is set by the multipart request itself, boundary
          // included; sending application/json here breaks the upload.
          isMultipart: true,
        ),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);
      if (!response.isSuccess) {
        return Left(ApiFailure(response.message, fields: response.fieldErrors));
      }

      final model = response.model;
      if (model is! Map) {
        return Left(const ApiFailure('ما قدرنا نقرا رد السيرفر'));
      }
      return Right(PurchaseRequest.fromApi(Map<String, dynamic>.from(model)));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// Backs the orders screen and decides what the pending screen shows.
  Future<Either<ApiFailure, List<PurchaseRequest>>> myHistory() async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/purchases/get-user-purchase-list',
        body: {'page': '1', 'rows': '25'},
        headers: NetworkConfig.getHeaders(
          needAuth: true,
          type: RequestType.post,
        ),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);
      if (!response.isSuccess) return Left(ApiFailure(response.message));

      final model = response.model;
      final list = model is List
          ? model
                .whereType<Map>()
                .map(
                  (e) => PurchaseRequest.fromApi(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <PurchaseRequest>[];
      return Right(list);
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}
