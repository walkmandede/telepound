import 'package:dart_frog/dart_frog.dart';

import '../utils/app_constants.dart';

Future<Response> onRequest(RequestContext context) async {
  return Response.json(
    body: AppConstants.customResponseBody(
      xSuccess: true,
      message: 'Welcome to Telepound v1.0.4',
    ),
  );
}
