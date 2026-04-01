import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:w2b_flutter/util/location_util.dart';

part 'inquiry_model.g.dart';

@JsonSerializable()
class Inquiry {
  final int id;
  final DateTime createdAt;

  final int userId;
  final int itemName;
  final String? itemDescription;

  @JsonKey(fromJson: LocationUtil.latLngFromJson, toJson: jsonEncode)
  final LatLng location;

  final int searchRadiusMeters;
  final bool sameCountryOnly, anywhere;
  
  // optional image
  final String? imageUrl;

  Inquiry({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.itemName,
    required this.itemDescription,
    required this.location,
    required this.searchRadiusMeters,
    required this.sameCountryOnly,
    required this.anywhere,
    this.imageUrl,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) => _$InquiryFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryToJson(this);
}