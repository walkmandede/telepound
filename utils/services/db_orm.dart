
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../models/user_model.dart';
import '../app_constants.dart';
import '../global_functions.dart';
import 'db_services.dart';

class DatabaseORM{

  static Future<List<Map<dynamic,dynamic>>> getCollectionAllData({
    required DbCollection dbCollection,
  }) async{
    return dbCollection.find().toList();
  }

  static Future<Map<dynamic,dynamic>> deleteDocument({
    required DbCollection dbCollection,
    required String objectId,
  }) async{
    return dbCollection.remove({'_id' : ObjectId.parse(objectId)});
  }

  static Future<void> updateDocument({
    required DbCollection dbCollection,
    required String objectId,
    required Map<String,dynamic> json,
  }) async{
    await dbCollection.replaceOne({'_id' : ObjectId.parse(objectId)},json);
  }

  static Future<WriteResult> modifyDocument({
    required DbCollection dbCollection,
    required String objectId,
    required String fieldName,
    required dynamic value
  }) async{
    return dbCollection.updateOne(
        {'_id' : ObjectId.parse(objectId)},
        modify.set(fieldName, value)
    );
  }


  static Future<WriteResult?> insertDataIntoCollection({
    required DbCollection dbCollection,
    required Map<String,dynamic> data,
  }) async{
    WriteResult? writeResult;
    try{
      writeResult = await dbCollection.insertOne(data);
    }
    catch(e){
      superPrint(e);
    }
    return writeResult;
  }

  static Future<bool> hasData({
    required DbCollection dbCollection,
    required dynamic value,
    required String fieldName
  }) async{
    var xHasData = true;
    try{
      xHasData = (
          await dbCollection.find(
            where.eq(fieldName, value),
          ).toList()
      ).isNotEmpty;
    }
    catch(e){
      superPrint(e);
    }
    return xHasData;
  }

  static Future<UserModel?> fetchUserByToken({
    required String token,
  }) async{
    UserModel? userModel;
    try{
      if(token.isEmpty){
        throw Exception();
      }
      final result = await DatabaseService.colUsers.findOne(
          where.eq('token', token)
      );
      if(result!=null){
        userModel = UserModel.fromMongo(
          data: result,
        );
      }
    }
    catch(e){
      return userModel;
    }
    return userModel;
  }

  static Future<Map<dynamic,dynamic>?> fetchDataById({
    required String id,
    required DbCollection col,
  }) async{
    Map<dynamic,dynamic>? result;
    try{
       result =await col.findOne(where.eq('_id', ObjectId.parse(id)));
    }
    catch(e){
      return result;
    }
    return result;
  }

  static Map<String,dynamic> findThatInArray({
    required dynamic data,
  }){
    return {r'$elemMatch': {r'$eq': data}};
  }

  static Future<String?> storeFile({
    required RequestContext context,
    required UploadedFile uploadedFile,
    String parentPath = '',
  }) async{

    String? newPath;

    try{
      final now = DateTime.now();
      final currentDirectory = Directory('${Directory.current.path}/public/$parentPath');
      final newDir = await currentDirectory.create();
      final newFile = File(
          '${newDir.path}'
              '${now.millisecondsSinceEpoch}_'
              '${uploadedFile.name}');
      final fileResult = await newFile.writeAsBytes(await uploadedFile.readAsBytes());
      newPath = fileResult.path.split('public').last;
    }
    catch(e){
      superPrint(e);
    }
    return newPath;
  }

}
