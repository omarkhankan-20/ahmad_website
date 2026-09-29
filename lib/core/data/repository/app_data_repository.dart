import 'package:dartz/dartz.dart';

import '../../enums/request_type.dart';
import '../../utils/network_util.dart';
import '../models/api_response.dart';
import '../network/network_config.dart';

class AppDataRepository {
  /// Sends the timestamps we already hold; the server replies with only the
  /// sections that changed since. Passing null for a section asks for it in
  /// full - which is what happens on a first run.
  Future<Either<ApiFailure, Map<String, dynamic>>> fetch({
    String? generalSettings,
    String? aboutUs,
    String? terms,
    String? privacy,
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/application-data',
        body: {
          'general_settings_last_updated': generalSettings,
          'about_us_last_updated': aboutUs,
          'terms_and_conditions_last_updated': terms,
          'privacy_policy_last_updated': privacy,
        },
        headers: NetworkConfig.getHeaders(type: RequestType.post),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);
      if (response.isSuccess) {
        final model = response.model;
        return Right(
          model is Map ? Map<String, dynamic>.from(model) : <String, dynamic>{},
        );
      }
      return Left(ApiFailure(response.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}