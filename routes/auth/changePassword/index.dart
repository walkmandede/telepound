import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_constants.dart';
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
            data: <String>[]
        ),
    );
  }
}

Future<Response> _middleware({required RequestContext context}) async {

  final payload = (await context.request.json()) as Map<String,dynamic>;
  final requiredFields = [
    'phone',
    'oldPassword',
    'newPassword',
  ];

  final xValid = AppConstants.xValidRequest(
    requiredFields: requiredFields,
    payloadKeys: payload.keys.toList(),
  );
  if(!xValid){
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: AppConstants.customResponseBody(
          xSuccess: false,
          message: 'Please fill required fields',
        ),
    );
  }

  final phone = payload['phone'].toString();
  final oldPassword = payload['oldPassword'].toString();
  final newPassword = payload['newPassword'].toString();

  final userResult = await DatabaseService.colUsers.findOne(
    where.eq('phone', phone)
  );
  if(userResult==null){
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: AppConstants.customResponseBody(
          xSuccess: false,
          message: 'There is no such phone in our system',
        ),
    );
  }

  final user = UserModel.fromMongo(data: userResult);
  final xValidOldPassword = oldPassword == user.password;
  if(!xValidOldPassword){
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: AppConstants.customResponseBody(
          xSuccess: false,
          message: 'Wrong password',
        ),
    );
  }

  if(newPassword.length < 8){
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: AppConstants.customResponseBody(
        xSuccess: false,
        message: 'Password length must be at least 8',
      ),
    );
  }

  final result = await DatabaseORM.modifyDocument(
      dbCollection: DatabaseService.colUsers,
      objectId: user.id,
      fieldName: 'password',
      value: newPassword,
  );

  if(!result.isSuccess){
    return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: AppConstants.customResponseBody(
          xSuccess: false,
          message: 'Something went wrong',
        )
    );
  }

  return Response.json(
    statusCode: HttpStatus.created,
    body: AppConstants.customResponseBody(
        xSuccess: true,
        message: 'Password has been changed successfully',
    ),
  );
}
