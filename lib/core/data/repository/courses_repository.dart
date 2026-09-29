import 'package:dartz/dartz.dart';

import '../../enums/request_type.dart';
import '../../utils/network_util.dart';
import '../models/api_response.dart';
import '../models/course_models.dart';
import '../network/network_config.dart';

class CoursesRepository {
  /// The landing page and the checkout summary both read from here, so the
  /// price shown is always the server's - never a number typed into the app.
  ///
  /// Sent with auth when available: is_purchased and can_access are
  /// per-user, and an anonymous call simply gets them all false.
  Future<Either<ApiFailure, List<Course>>> filter({
    int rows = 10,
    int page = 1,
    String orderBy = 'published_at',
    String orderDirection = 'desc',
  }) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/courses/filter',
        body: {
          'rows': rows,
          'page': page,
          'order_by': orderBy,
          'order_direction': orderDirection,
        },
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
                .map((e) => Course.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : <Course>[];
      return Right(list);
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  Future<Either<ApiFailure, Course>> details(int courseId) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/courses/details',
        body: {'course_id': courseId.toString()},
        headers: NetworkConfig.getHeaders(
          needAuth: true,
          type: RequestType.post,
        ),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);
      if (!response.isSuccess) return Left(ApiFailure(response.message));

      final model = response.model;
      if (model is! Map) {
        return Left(const ApiFailure('ما قدرنا نجيب تفاصيل الدورة'));
      }
      return Right(Course.fromJson(Map<String, dynamic>.from(model)));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// Everything the signed-in student has paid for.
  Future<Either<ApiFailure, List<Course>>> myPurchasedCourses() async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/courses/my-purchased-courses',
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
                .map((e) => Course.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : <Course>[];
      return Right(list);
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  Future<Either<ApiFailure, String>> lessonPlayback(int lessonId) async {
    try {
      final raw = await NetworkUtil.sendRequest(
        type: RequestType.post,
        route: '/api/courses/lessons/playback',
        body: {'lesson_id': lessonId},
        headers: NetworkConfig.getHeaders(
          needAuth: true,
          type: RequestType.post,
        ),
      );

      final response = ApiResponse<dynamic>.fromJson(raw);
      if (!response.isSuccess) return Left(ApiFailure(response.message));

      final model = response.model;
      final url = model is Map ? model['content_url']?.toString() : null;
      if (url == null || url.isEmpty) {
        return Left(const ApiFailure('ما قدرنا نجيب رابط الدرس'));
      }
      return Right(url);
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}
