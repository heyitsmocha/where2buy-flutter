import 'package:json_annotation/json_annotation.dart';

part 'answer_model.g.dart';

@JsonSerializable()
class Answer {
  final int id;
  final DateTime createdAt;

  final double latitude;
  final double longitude;
  
  final String storeName;
  final String? storeAddress;
  final String? additionalInfo;

  final int? likeCount;
  final String? imageUrl;

  Answer({
    required this.id,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.storeName,
    this.storeAddress,
    this.additionalInfo,
    this.likeCount,
    this.imageUrl,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}