import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../models/group_model.dart';
import '../../../models/message_model.dart';
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
      throw Exception(['Invalid Token']);
    }

    final payload = await context.request.formData();
    final requiredFields = [
      'to',
      'message',
    ];

    final payloadKeys = <String>[];

    payload.files.forEach((key, value) {
      payloadKeys.add(key);
    });

    payload.fields.forEach((key, value) {
      payloadKeys.add(key);
    });

    final xValid = AppConstants.xValidRequest(
      requiredFields: requiredFields,
      payloadKeys: payloadKeys,
    );

    if(!xValid){
      throw Exception([
        'Please make sure following fields are included $requiredFields'
      ]);
    }

    final to = payload.fields['to'];
    final message = payload.fields['message'];
    final image = payload.files['image'];

    var toUser = await DatabaseORM.fetchDataById(
        id: to.toString(),
        col: DatabaseService.colUsers
    );

    toUser ??= await DatabaseORM.fetchDataById(
          id: to.toString(),
          col: DatabaseService.colGroups
      );

    if(toUser==null){
      throw Exception([
        'Something went wrong in user ids'
      ]);
    }

    var imagePath = '';

    if(image!=null){
      imagePath = (
          await DatabaseORM.storeFile(
            context: context,
            uploadedFile: image,
            parentPath: AppConstants.filePathMessageImages
          )
      )??'';
    }

    final messageModel = MessageModel(
      id: '',
      from: user.id,
      to: to.toString(),
      dateTime: DateTime.now(),
      image: imagePath,
      message: message.toString(),
    );

    final result = await DatabaseORM.insertDataIntoCollection(
        dbCollection: DatabaseService.colMessages,
        data: messageModel.toMap()
    );

    if(result==null){
      throw Exception(['Something went wrong']);
    }
    if(!result.isSuccess){
      throw Exception(['Something went wrong']);
    }



    return Response.json(
      statusCode: HttpStatus.created,
      body: AppConstants.customResponseBody(
        xSuccess: true,
        message: 'Message Created Successfully',
        data: messageModel.toMap(excludedFields: ['id']),
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