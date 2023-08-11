
import '../utils/app_constants.dart';
import '../utils/services/db_services.dart';

class MessageModel{

  MessageModel({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.image,
    required this.dateTime
  });

  factory MessageModel.fromMongo({required Map<String,dynamic> data}){
    return MessageModel(
      id: DatabaseService.idParser(data),
      from: data['from'].toString(),
      to: data['to'].toString(),
      dateTime: DateTime.tryParse(data['dateTime'].toString())??DateTime(2000),
      message: data['message'].toString(),
      image: data['image'].toString(),
    );
  }

  String id;
  String from;
  String to;
  DateTime dateTime;
  String message;
  String image;

  Map<String,dynamic> toMap({
    List<String> excludedFields = const [],
    bool xFullPath = false
  }){

    final data = <String,dynamic>{
      'id' : id,
      'from' : from,
      'to' : to,
      'dateTime' : dateTime.toString(),
      'message' : message,
      'image' : xFullPath?AppConstants.convertLocalImage(image: image):image
    };

    final result = <String,dynamic>{};

    data.forEach((key, value) {
      if(!excludedFields.contains(key)){
        result[key] = value;
      }
    });

    return result;
  }

}