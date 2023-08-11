import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../models/group_model.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/global_functions.dart';
import '../../../utils/services/db_orm.dart';
import '../../../utils/services/db_services.dart';

Future<Response> onRequest(RequestContext context) async{
  if(context.request.method == HttpMethod.post){
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
      return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: AppConstants.customResponseBody(
            xSuccess: false,
            message: 'Invalid Token',
          )
      );
    }

    final payload = await context.request.json() as Map<String,dynamic>;
    final requiredFields = [
      'name',
      'members',
    ];

    final xValid = AppConstants.xValidRequest(
      requiredFields: requiredFields,
      payloadKeys: payload.keys.toList(),
    );

    if(!xValid){
      throw Exception([
        'Please make sure following fields are included $requiredFields'
      ]);
    }

    final name = payload['name'].toString();
    final members = payload['members'] as List<dynamic>;

    if(name.toString().isEmpty){
      throw Exception([
        'Name should not be empty'
      ]);
    }

    for (final each in members) {
      final userModel = await DatabaseORM.fetchDataById(
          id: each.toString(),
          col: DatabaseService.colUsers
      );
      if(userModel==null){
        throw Exception(['There is no such users']);
      }
    }

    final groupModel = GroupModel(
      hosts: [
        user.id
      ],
      image: AppConstants.groupDefaultImage,
      members: [
        user.id,
        ...members.map((e) => e.toString()).toList(),
      ],
      name: name,
      id: ''
    );

    final writeResult = await DatabaseORM.insertDataIntoCollection(
        dbCollection: DatabaseService.colGroups,
        data: groupModel.toMap()
    );

    if(writeResult==null){
      throw Exception(['Something went wrong']);
    }
    else if(!writeResult.success){
      throw Exception(['Something went wrong']);
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: AppConstants.customResponseBody(
        xSuccess: true,
        message: 'Group Created Successfully',
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