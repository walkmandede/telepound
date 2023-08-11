
import '../utils/app_constants.dart';
import '../utils/services/db_services.dart';

enum MessageListType{
  group,
  dm
}

class MessageListModel{

  MessageListModel({
    required this.toId,
    required this.name,
    required this.dateTime,
    required this.type,
    required this.image,
    required this.lastMessage,
  });

  String toId;
  MessageListType type;
  DateTime dateTime;
  String name;
  String image;
  String lastMessage;

  Map<String,dynamic> toMap({
    List<String> excludedFields = const [],
    bool xFullPath = false
  }){

    final data = <String,dynamic>{
      'toId' : toId,
      'type' : type.name,
      'dateTime' : dateTime.toString(),
      'name' : name,
      'image' : image,
      'lastMessage' : lastMessage
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