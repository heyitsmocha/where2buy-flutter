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