import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
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

  final payloads = (await context.request.json()) as Map<String,dynamic>;

  final requiredFields = [
    'phone',
    'password',
  ];

  final payloadKeys = <String>[];

  for (final key in payloads.keys) {
    payloadKeys.add(key);
  }

  final xValid = AppConstants.xValidRequest(
    requiredFields: requiredFields,
    payloadKeys: payloadKeys,
  );

  if(xValid){
    try{
      final phone = payloads['phone'];
      final password = payloads['password'];

      final result = await DatabaseService.colUsers.findOne(
        where.eq('phone', phone).and(where.eq('password', password))
      );

      if(result==null){
        //wrongAuth
        return Response.json(
            statusCode: HttpStatus.badRequest,
            body: AppConstants.customResponseBody(
              xSuccess: false,
              message: 'Wrong phone or password! Try again!',
              // data: result
            )
        );
      }
      else{
        //success
        final userModel = UserModel.fromMongo(data: result);
        final uuid = AppConstants.createUUID();

        final writeResult = await DatabaseORM.modifyDocument(
            dbCollection: DatabaseService.colUsers,
            objectId: userModel.id,
            fieldName: 'token',
            value: uuid,
        );

        if(writeResult.isFailure){
          return Response.json(
              statusCode: HttpStatus.badRequest,
              body: AppConstants.customResponseBody(
                  xSuccess: false,
                  message: 'Something went wrong',
              )
          );
        }

        return Response.json(
            statusCode: HttpStatus.accepted,
            body: AppConstants.customResponseBody(
              xSuccess: true,
              message: 'Login Success',
              data: {
                'token' : uuid,
              }
            )
        );
      }
    }
    catch(e){
      return Response.json(
          statusCode: HttpStatus.badRequest,
          body: AppConstants.customResponseBody(
            xSuccess: false,
            message: e.toString(),
          )
      );
    }
  }
  else{
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: AppConstants.customResponseBody(
            xSuccess: false,
            message: 'Please make sure following fields are included',
            data: <String,dynamic>{
              'requiredFields' : requiredFields
            }
        )
    );
  }




}