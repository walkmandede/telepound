import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/global_functions.dart';
import '../../../utils/services/db_orm.dart';
import '../../../utils/services/db_services.dart';

Future<Response> onRequest(RequestContext context) async{
  if(context.request.method == HttpMethod.get){
    return DatabaseService.startConnection(
      context,
      _middleware(context: context),
    );
  }
  else{
    return Response.json(
        statusCode: HttpStatus.methodNotAllowed,
        body: AppConstants.customResponseBody(
            xSuccess: false,
            message: 'Method Not Allowed',
            data: <String>[]
        )
    );
  }
}

Future<Response> _middleware({required RequestContext context}) async {
  try{
    final token = context.request.headers['token']??'';
    final user = await DatabaseORM.fetchUserByToken(token: token);
    if(user==null){
      throw Exception(['Invalid Token']);
    }

    final query = context.request.uri.queryParameters;
    final toId = query['to'];

    if(toId==null){
      throw Exception(["Please include 'to' parameter"]);
    }

    final result = await DatabaseService.colMessages.find(
      where.eq('to', toId)
    ).toList();

    return Response.json(
      statusCode: HttpStatus.created,
      body: AppConstants.customResponseBody(
        xSuccess: false,
        message: 'Successfully Fetched',
        data: result.map((e) {
          return MessageModel.fromMongo(data: e).toMap(xFullPath: true);
        }).toList(),
      ),
    );
  }
  catch(e){
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: AppConstants.customResponseBody(
        xSuccess: false,
        message: e.toString(),
      ),
    );
  }
}
