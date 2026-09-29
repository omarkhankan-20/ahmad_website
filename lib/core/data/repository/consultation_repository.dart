import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../enums/request_type.dart';
import '../../utils/network_util.dart';
import '../models/api_response.dart';
import '../models/consultation_models.dart';
import '../network/network_config.dart';

class ConsultationRepository {
  /// Brief and payment travel together: unlike a course purchase there is no
  /// separate checkout step, so the form collects both before submitting.
  Future<Either<ApiFailure, ConsultationBooking>> book({
    required String accountLink,
    required String industry,
    required String sessionObjective,
    required String preferredTime,
    required String paymentMethodCode,
    required String transactionNumber,
    required Uint8List receiptBytes,
    required String receiptName,
  }) async {
    try {
      final raw = await NetworkUtil.sendMultipartBytes(
        route: '/api/consultations/book',
        fields: {
          'account_link': accountLink,
          'industry': industry,
          'session_objective': sessionObjective,
          'preferred_time': preferredTime,
          'payment_method_code': paymentMethodCode,
          'transaction_number': transactionNumber,
        },
        fileField: 'receipt',
        fileName: receiptName,
        fileBytes: receiptBytes,
        headers: NetworkConfig.getHeaders(
          needAuth: true,
          type: RequestType.post,
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
      return Right(
        ConsultationBooking.fromJson(Map<String, dynamic>.from(model)),
      );
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  Future<Either<ApiFailure, List<ConsultationBooking>>> myConsultations({
    int rows = 10,
    int page = 1,
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/consultations/get-user-consultation-list',
        body: {'rows': rows, 'page': page},
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
              .map((e) =>
                  ConsultationBooking.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ConsultationBooking>[];
      return Right(list);
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}