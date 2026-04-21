// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inquiry _$InquiryFromJson(Map<String, dynamic> json) => Inquiry(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      itemName: json['item_name'] as String,
      itemDescription: json['item_description'] as String?,
      location:
          LocationUtil.latLngFromJson(json['location'] as Map<String, dynamic>),
      searchRadiusMeters: (json['search_radius_meters'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$InquiryToJson(Inquiry instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'item_name': instance.itemName,
      'item_description': instance.itemDescription,
      'location': jsonEncode(instance.location),
      'search_radius_meters': instance.searchRadiusMeters,
      'image_url': instance.imageUrl,
    };

NearbyInquiry _$NearbyInquiryFromJson(Map<String, dynamic> json) =>
    NearbyInquiry(
      id: (json['id'] as num).toInt(),
      itemName: json['item_name'] as String,
      itemDescription: json['item_description'] as String?,
    );

Map<String, dynamic> _$NearbyInquiryToJson(NearbyInquiry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_name': instance.itemName,
      'item_description': instance.itemDescription,
    };
