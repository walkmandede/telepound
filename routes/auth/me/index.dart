import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/global_functions.dart';
import '../../../utils/services/db_orm.dart';
import '../../../utils/services/db_services.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return DatabaseService.startConnection(
      context,
      _middleware(context: context),
    );
  } else {
    return Response.json(
        statusCode: HttpStatus.methodNotAllowed,
        body: AppConstants.customResponseBody(
            xSuccess: false, message: 'Method Not Allowed', data: <String>[]));
  }
}

Future<Response> _middleware({required RequestContext context}) async {
  try {
    final token = context.request.headers['token'] ?? '';
    final user = await DatabaseORM.fetchUserByToken(token: token);
    if (user == null) {
      throw Exception(['Invalid Token']);
    }
    return Response.json(
      statusCode: HttpStatus.created,
      body: AppConstants.customResponseBody(
        xSuccess: true,
        message: 'Successfully Fetched',
        data: user.toMap(excludedFields: ['password'], xFullPath: true),
      ),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: AppConstants.customResponseBody(
        xSuccess: false,
        message: e.toString(),
      ),
    );
  }
}
