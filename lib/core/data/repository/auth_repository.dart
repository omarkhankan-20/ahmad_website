import 'package:ahmad_website/core/data/repository/storage_repository.dart';
import 'package:dartz/dartz.dart';

import '../../enums/request_type.dart';
import '../../utils/network_util.dart';
import '../models/api_response.dart';
import '../network/network_config.dart';

/// Backend field names differ from the form's. Translated here so the screens
/// keep their own keys and nothing downstream has to know the API's naming.
const Map<String, String> _fieldMap = {
  'name': 'name',
  'email': 'email',
  'phone': 'whatsapp',
  'password': 'password',
  'code': 'code',
  'new_password': 'newPassword',
};

Map<String, String> _translate(Map<String, String> apiFields) {
  final out = <String, String>{};
  apiFields.forEach((key, value) {
    // device_id and anything unmapped has no input on screen, so it surfaces
    // as a form-level message instead of being silently dropped.
    out[_fieldMap[key] ?? 'form'] = value;
  });
  return out;
}

class AuthRepository {
  // register calls /api/user/register, which sends a verification code to the email or
  Future<Either<ApiFailure, bool>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/user/register',
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'device_id': storage.deviceId,
        },
        headers: NetworkConfig.getHeaders(type: RequestType.post),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);

      if (response.isSuccess) {
        return const Right(true);
      }
      return Left(
        ApiFailure(response.message, fields: _translate(response.fieldErrors)),
      );
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  // verifyOtp calls /api/user/otp/verify, which returns a token if the code is correct. The token is stored for future requests.
  Future<Either<ApiFailure, bool>> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/user/otp/verify',
        body: {
          'identifier': identifier,
          'code': code,
          'device_id': storage.deviceId,
        },
        headers: NetworkConfig.getHeaders(type: RequestType.post),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);

      if (response.isSuccess) {
        final model = response.model;
        if (model is Map) {
          if (model['token'] != null) {
            storage.setToken(model['token'].toString());
          }
          // The whole user object is kept so the nav bar and the course pages
          // have a name and an id without another round trip.
          storage.setUser(Map<String, dynamic>.from(model));
        }
        return const Right(true);
      }
      return Left(
        ApiFailure(response.message, fields: _translate(response.fieldErrors)),
      );
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  // resendOtp calls /api/user/otp/resend, which sends a new code to the email or phone. The identifier is the same one used for register and verifyOtp.
  Future<Either<ApiFailure, bool>> resendOtp({
    required String identifier,
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/user/otp/resend',
        body: {'identifier': identifier},
        headers: NetworkConfig.getHeaders(type: RequestType.post),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);
      return response.isSuccess
          ? const Right(true)
          : Left(ApiFailure(response.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  Future<Either<ApiFailure, bool>> login({
    required String email,
    required String password,
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/user/login',
        body: {'type': 'email', 'identifier': email, 'password': password},
        headers: NetworkConfig.getHeaders(type: RequestType.post),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);

      if (response.isSuccess) {
        final model = response.model;
        if (model is Map) {
          if (model['token'] != null) {
            storage.setToken(model['token'].toString());
          }
          storage.setUser(Map<String, dynamic>.from(model));
        }
        return const Right(true);
      }

      // Wrong credentials come back as one message, not per field. Shown above
      // both inputs so neither is singled out - saying which half was wrong
      // would confirm that an email has an account.
      return Left(
        ApiFailure(
          response.message,
          fields: response.fieldErrors.isEmpty
              ? {'form': response.message}
              : _translate(response.fieldErrors),
        ),
      );
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  Future<Either<ApiFailure, bool>> logout() async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/user/logout',
        headers: NetworkConfig.getHeaders(
          needAuth: true,
          type: RequestType.post,
        ),
      );
      final response = ApiResponse<dynamic>.fromJson(raw);
      return response.isSuccess
          ? const Right(true)
          : Left(ApiFailure(response.message));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// Validates the stored token against the server. Used on boot, and handy
  /// for confirming the 401 path works end to end.
  Future<Either<ApiFailure, Map<String, dynamic>>> generalUserData() async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/general-user-data',
        headers: NetworkConfig.getHeaders(
          needAuth: true,
          type: RequestType.post,
        ),
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

  /// The new password travels with this request. The emailed code that
  /// follows only confirms the account belongs to whoever asked - it does not
  /// carry the password.
  Future<Either<ApiFailure, bool>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        // Spelled "rest" on the backend, not "reset".
        route: '/api/user/rest-password',
        body: {
          'type': 'email',
          'identifier': email,
          'new_password': newPassword,
        },
        headers: NetworkConfig.getHeaders(type: RequestType.post),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);
      return response.isSuccess
          ? const Right(true)
          : Left(
              ApiFailure(
                response.message,
                fields: _translate(response.fieldErrors),
              ),
            );
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}
