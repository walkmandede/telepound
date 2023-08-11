import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
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

  final formData = await context.request.formData();
  final requiredFields = [
    'name',
    'phone',
    'password',
    'image'
  ];

  final payloadKeys = <String>[];

  formData.files.forEach((key, value) {
    payloadKeys.add(key);
  });

  formData.fields.forEach((key, value) {
    payloadKeys.add(key);
  });

  final xValid = AppConstants.xValidRequest(
      requiredFields: requiredFields,
      payloadKeys: payloadKeys,
  );

  if(xValid){
    try{
      final image = formData.files['image'];
      final fields = formData.fields;

      final userModel = UserModel(
        id: '',
        name: fields['name'].toString(),
        phone: fields['phone'].toString(),
        password: fields['password'].toString(),
        token: '',
        image: ''
      );

      final xAlreadyExisted = await DatabaseORM.hasData(
          dbCollection: DatabaseService.colUsers,
          value: userModel.phone,
          fieldName: 'phone',
      );

      if(xAlreadyExisted){
        return Response.json(
            statusCode: HttpStatus.badRequest,
            body: AppConstants.customResponseBody(
                xSuccess: false,
                message: 'The phone number is already registered',
            )
        );
      }
      else{
        final imagePath = await DatabaseORM.storeFile(
          context: context,
          uploadedFile: image!,
          parentPath: AppConstants.filePathUserImages,
        );
        superPrint(imagePath);
        userModel.image = imagePath!;
        final writeResult = await DatabaseORM.insertDataIntoCollection(
          dbCollection: DatabaseService.colUsers,
          data: userModel.toMap(),
        );
        if(writeResult!=null){
          return Response.json(
              statusCode: HttpStatus.created,
              body: AppConstants.customResponseBody(
                  xSuccess: true,
                  message: 'Register Success',
                  data: userModel.toMap(excludedFields: ['password'])
              )
          );
        }
        else{
          throw Exception('Something went wrong');
        }
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