import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

// @JsonSerializable()
// class User {
//   final String id;
//   final String name;

//   User({
//     required this.id,
//     required this.name,
//   });

//   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
//   Map<String, dynamic> toJson() => _$UserToJson(this);
// }

@JsonSerializable()
class UserResponse {
  final String email;
  final String name;
  final String token;

  UserResponse({
    required this.email,
    required this.name,
    required this.token,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final String deviceName;

  LoginRequest({
    required this.email,
    required this.password,
    required this.deviceName,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String name;
  final String email;
  final String token;

  LoginResponse({
    required this.name,
    required this.email,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
