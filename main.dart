import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

import 'utils/app_constants.dart';
import 'utils/services/db_services.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async{

  await DatabaseService.connect();
  return serve(handler, InternetAddress(AppConstants.endPoint), AppConstants.port);
  // return serve(handler, ip, 8080);
}