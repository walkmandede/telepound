import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DatabaseService {
  static const dbAddress =
      'mongodb+srv://walkmandede:sio64ati7o@cluster0.qag8tm8.mongodb.net/telepound?retryWrites=true&w=majority';
  // static const dbAddress = 'mongodb+srv://walkmandede:sio64ati7o@cluster0.qag8tm8.mongodb.net/telepound?retryWrites=true&w=majority';
  static Db db = Db(dbAddress);

  //collections
  static final colUsers = db.collection('users');
  static final colGroups = db.collection('groups');
  static final colMessages = db.collection('messages');

  static Future<void> connect() async {
    db = await Db.create(dbAddress);
    await db.open(secure: true);
  }

  static Future<void> openDb() async {
    if (db.isConnected == false) {
      await db.open(secure: true);
    }
  }

  static Future<void> closeDb() async {
    if (db.isConnected == true) {
      await db.close();
    }
  }

  static String idParser(Map<dynamic, dynamic> data) {
    try {
      final objectId = data['_id'] as ObjectId;
      return objectId.$oid;
    } catch (e) {
      return '';
    }
  }

  static Future<Response> startConnection(
    RequestContext context,
    Future<Response> callBack,
  ) async {
    var response = Response.json(
      statusCode: 500,
      body: {'message': 'Internal server error'},
    );
    try {
      await connect();
    } catch (_) {}
    try {
      // await openDb();
      response = await callBack;
      // await closeDb();
    } catch (_) {}
    try {
      await closeDb();
    } catch (_) {}
    return response;
  }
}
