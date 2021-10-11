// To parse this JSON data, do
//
//     final loginUser = loginUserFromJson(jsonString);

import 'dart:convert';

LoginUser loginUserFromJson(String str) => LoginUser.fromJson(json.decode(str));

String loginUserToJson(LoginUser data) => json.encode(data.toJson());

class LoginUser {
  LoginUser({
    this.error,
    this.email,
    this.name,
    this.token,
  });

  String error;
  String email;
  String name;
  String token;

  factory LoginUser.fromJson(Map<String, dynamic> json) => LoginUser(
    error: json["error"],
    email: json["email"],
    name: json["name"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "email": email,
    "name": name,
    "token": token,
  };
}
