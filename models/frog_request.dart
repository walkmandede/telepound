
import 'package:dart_frog/dart_frog.dart';

class FrogRequest{

  FrogRequest({
    required this.formData,
    required this.json,
    required this.body,
    required this.headers,
    required this.queryParameters
  });

  Map<String,String> queryParameters;
  Map<String,String> headers;
  String body;
  Map<String,dynamic> json;
  FormData formData;
}
