import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:w2b_flutter/util/location_util.dart';

part 'answer_model.g.dart';

@JsonSerializable()
class Answer {
  final int id;
  final DateTime createdAt;

  final int userId;
  final int inquiryId;

  @JsonKey(fromJson: LocationUtil.latLngFromJson, toJson: jsonEncode)
  final LatLng location;
  final String storeName;
  final String storeAddress;
  final String? additionalInfo;

  final int? likeCount;
  final String? imageUrl;

  Answer({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.inquiryId,
    required this.location,
    required this.storeName,
    required this.storeAddress,
    this.additionalInfo,
    this.likeCount,
    this.imageUrl,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}