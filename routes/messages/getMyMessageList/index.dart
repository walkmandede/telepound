import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/group_model.dart';
import '../../../models/message_list_model.dart';
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

    final result = await DatabaseService.colMessages.find(
      where.eq('to', user.id).or(where.eq('from', user.id))
    ).toList();

    final resultModel = result.map((e) {
      return MessageModel.fromMongo(data: e);
    }).toList();

    final categorizedList = <String,MessageModel>{};


    for (final newModel in resultModel) {
      if(!categorizedList.containsKey(newModel.to)){
        //notContainInKeys-new
        categorizedList[newModel.to] = newModel;
      }
      else{
        final oldModel = categorizedList[newModel.to];
        if(newModel.dateTime.isAfter(oldModel!.dateTime)){
          categorizedList[newModel.to] = newModel;
        }
      }
    }



    final dataList = <MessageListModel>[];

    for(final each in categorizedList.values){

      var image = '';
      var name = '';
      var type = MessageListType.dm;

      final userData = await DatabaseORM.fetchDataById(
          id: each.to,
          col: DatabaseService.colUsers
      );

      final groupData = await DatabaseORM.fetchDataById(
          id: each.to,
          col: DatabaseService.colGroups
      );

      if(userData!=null){
        final userModel = UserModel.fromMongo(
            data: userData as Map<String,dynamic>
        );
        image = userModel.image;
        name = userModel.name;
        type = MessageListType.dm;
      }
      else if(groupData!=null){
        final groupModel = GroupModel.fromMongo(
            data: groupData as Map<String,dynamic>
        );
        image = groupModel.image;
        name = groupModel.name;
        type = MessageListType.group;
      }

      dataList.add(
        MessageListModel(
          toId: each.to,
          name: name,
          dateTime: each.dateTime,
          type: type,
          image: image,
          lastMessage: each.message,
        ),
      );
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: AppConstants.customResponseBody(
        xSuccess: false,
        message: 'Successfully Fetched',
        data: dataList.map((e) => e.toMap()).toList()
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
