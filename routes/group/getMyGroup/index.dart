import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/group_model.dart';
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

    final result = await DatabaseService.colGroups.find(
      where.eq('members', DatabaseORM.findThatInArray(data: user.id))
    ).toList();

    return Response.json(
      statusCode: HttpStatus.created,
      body: AppConstants.customResponseBody(
        xSuccess: true,
        message: 'Group Fetched Successfully',
        data: result.toSet().map((e) {
          return GroupModel.fromMongo(data: e).toMap(xFullPath: true);
        }).toList()
      ),
    );
  }
  catch(e){
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: AppConstants.customResponseBody(
        xSuccess: false,
        message: e.toString(),
      ),
    );
  }
}