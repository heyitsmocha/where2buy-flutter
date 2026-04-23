// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inquiry _$InquiryFromJson(Map<String, dynamic> json) => Inquiry(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      itemId: (json['item_id'] as num?)?.toInt(),
      itemName: json['item_name'] as String?,
      itemDescription: json['item_description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      searchRadiusMeters: (json['search_radius_meters'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$InquiryToJson(Inquiry instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'item_id': instance.itemId,
      'item_name': instance.itemName,
      'item_description': instance.itemDescription,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
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

CreateInquiryRequest _$CreateInquiryRequestFromJson(
        Map<String, dynamic> json) =>
    CreateInquiryRequest(
      itemId: (json['item_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      searchRadiusMeters: (json['search_radius_meters'] as num).toInt(),
    );

Map<String, dynamic> _$CreateInquiryRequestToJson(
        CreateInquiryRequest instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'search_radius_meters': instance.searchRadiusMeters,
    };
