import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthServices {


Future<String> login(String Email, String Password) async{
final uri = Uri.parse("https://nejda.onrender.com/api/admin/login");
try{
  print(Password.trim());
final response = await http.post(uri,
body: {
    "email" : Email.trim(),
    "password" : Password.trim()

}
);
final data = jsonDecode(response.body);
if(response.statusCode == 200 || response.statusCode == 201){


 return data["status"];

}else{

  
  return  data["message"];
}}catch(e){
  return "Problem de server ";
}

}




}