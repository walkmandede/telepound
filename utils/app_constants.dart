import 'dart:developer';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../models/frog_request.dart';

class AppConstants {
  static String endPoint = '192.168.100.96';
  static int port = 4321;
  static String filePathUserImages = 'userImages/';
  static String filePathMessageImages = 'messageImages/';
  static String filePathGroupImages = 'messageImages/';

  static String groupDefaultImage = '$endPoint:$port/appImages/group_image.png';

  static Map<String, dynamic> defRespBody = {
    'meta': {'success': false, 'message': 'Something went wrong'}
  };

  static Map<String, dynamic> customResponseBody(
      {required bool xSuccess, required String message, dynamic data}) {
    return {
      'meta': {'success': xSuccess, 'message': message},
      if (data != null) 'data': data
    };
  }

  static Future<FrogRequest> convertRequest({
    required RequestContext context,
  }) async {
    return FrogRequest(
      queryParameters: context.request.uri.queryParameters,
      body: '',
      headers: context.request.headers,
      formData: await context.request.formData(),
      json: (await context.request.json()) as Map<String, dynamic>,
    );
  }

  static bool xValidRequest(
      {required List<String> requiredFields,
      required List<String> payloadKeys}) {
    for (final eachField in requiredFields) {
      if (payloadKeys.contains(eachField)) {
      } else {
        return false;
      }
    }

    return true;
  }

  static String createUUID() {
    const uuid = Uuid();
    final result = uuid.v5(null, null);
    return result.replaceAll('-', '_');
  }

  static String convertLocalImage({required String image}) {
    if (AppConstants.endPoint.contains('http')) {
      return '${AppConstants.endPoint}:${AppConstants.port}$image';
    } else {
      return 'http://${AppConstants.endPoint}:${AppConstants.port}$image';
    }
  }
}
