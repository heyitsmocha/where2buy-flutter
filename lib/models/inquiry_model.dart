import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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

@JsonSerializable()
class CreateInquiryRequest {
  final int? itemId;
  final String? name;
  final String? description;

  final double latitude;
  final double longitude;

  final int searchRadiusMeters;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final File? image;

  CreateInquiryRequest({
    this.itemId,
    this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.searchRadiusMeters,
    this.image,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      if (itemId != null) 'item_id': itemId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'search_radius_meters': searchRadiusMeters,
      if (image != null)
        'file': await MultipartFile.fromFile(
          image!.path,
          filename: image!.path.split(Platform.pathSeparator).last,
        ),
    });
  }

  factory CreateInquiryRequest.fromJson(Map<String, dynamic> json) => _$CreateInquiryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateInquiryRequestToJson(this);
}