
import '../utils/app_constants.dart';
import '../utils/services/db_services.dart';

class GroupModel{

  GroupModel({
    required this.id,
    required this.name,
    required this.image,
    required this.members,
    required this.hosts,
  });

  factory GroupModel.fromMongo({required Map<String,dynamic> data}){
    return GroupModel(
      id: DatabaseService.idParser(data),
      name: data['name'].toString(),
      image: data['image'].toString(),
      members: (data['members']) as List<String>,
      hosts: (data['hosts']) as List<String>
    );
  }

  String id;
  String name;
  List<String> members;
  List<String> hosts;
  String image;

  Map<String,dynamic> toMap({
    List<String> excludedFields = const [],
    bool xFullPath = false
  }){

    final data = <String,dynamic>{
      'id' : id,
      'name' : name,
      'image' : xFullPath?AppConstants.convertLocalImage(image: image):image,
      'members' : members,
      'hosts' : hosts
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