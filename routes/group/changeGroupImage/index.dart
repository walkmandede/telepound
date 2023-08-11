import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/group_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/global_functions.dart';
import '../../../utils/services/db_orm.dart';
import '../../../utils/services/db_services.dart';

Future<Response> onRequest(RequestContext context) async{
  if(context.request.method == HttpMethod.patch){
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
     'image'
    ];

    final payloadKeys = <String>[];

    payload.files.forEach((key, value) {
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

    final query = context.request.uri.queryParameters;
    final gid = query['id'];
    if(gid==null){
      throw Exception(['Please make sure to include group id in parameter']);
    }

    final groupModel = await DatabaseService.colGroups.findOne(
      where.eq('_id', ObjectId.parse(gid)),
    );
    if(groupModel==null){
      throw Exception(['There is no such group in our system']);
    }

    final uploadedImage = payload.files['image'];

    if(uploadedImage==null){
      throw Exception(['Required Non-null image field']);
    }

    final imagePath = await DatabaseORM.storeFile(
      context: context,
      uploadedFile: uploadedImage,
      parentPath: AppConstants.filePathGroupImages
    );

    final result = await DatabaseORM.modifyDocument(
        dbCollection: DatabaseService.colGroups,
        objectId: gid,
        fieldName: 'image',
        value: imagePath
    );

    if(!result.isSuccess){
      throw Exception(['Something went wrong']);
    }

    return Response.json(
      body: AppConstants.customResponseBody(
        xSuccess: true,
        message: 'Group Image Has Been Changed Successfully',
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