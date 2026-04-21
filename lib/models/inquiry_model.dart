import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:w2b_flutter/util/location_util.dart';

part 'inquiry_model.g.dart';

@JsonSerializable()
class Inquiry {
  final int id;
  final DateTime createdAt;

  final String itemName;
  final String? itemDescription;

  @JsonKey(fromJson: LocationUtil.latLngFromJson, toJson: jsonEncode)
  final LatLng location;

  final int searchRadiusMeters;
  
  // optional image
  final String? imageUrl;

  Inquiry({
    required this.id,
    required this.createdAt,
    required this.itemName,
    this.itemDescription,
    required this.location,
    required this.searchRadiusMeters,
    this.imageUrl,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) => _$InquiryFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryToJson(this);
}

@JsonSerializable()
class NearbyInquiry {
  final int id;
  final String itemName;
  final String? itemDescription;

  NearbyInquiry({
    required this.id,
    required this.itemName,
    this.itemDescription,
  });

  factory NearbyInquiry.fromJson(Map<String, dynamic> json) => _$NearbyInquiryFromJson(json);
  Map<String, dynamic> toJson() => _$NearbyInquiryToJson(this);
}
