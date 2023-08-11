
import '../utils/app_constants.dart';
import '../utils/services/db_services.dart';

class UserModel{

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.image,
    required this.token,
  });

  factory UserModel.fromMongo({required Map<String,dynamic> data}){
    return UserModel(
        id: DatabaseService.idParser(data),
        name: data['name'].toString(),
        password: data['password'].toString(),
        phone: data['phone'].toString(),
        token: data['token'].toString(),
        image: data['image'].toString(),
    );
  }

  String id;
  String name;
  String phone;
  String password;
  String token;
  String image;

  Map<String,dynamic> toMap({
    List<String> excludedFields = const [],
    bool xFullPath = false
  }){

    final data = <String,dynamic>{
      'id' : id,
      'name' : name,
      'phone' : phone,
      'password' : password,
      'token' : token,
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