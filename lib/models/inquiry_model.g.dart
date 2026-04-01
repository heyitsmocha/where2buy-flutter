// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inquiry _$InquiryFromJson(Map<String, dynamic> json) => Inquiry(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: (json['user_id'] as num).toInt(),
      itemName: (json['item_name'] as num).toInt(),
      itemDescription: json['item_description'] as String?,
      location:
          LocationUtil.latLngFromJson(json['location'] as Map<String, dynamic>),
      searchRadiusMeters: (json['search_radius_meters'] as num).toInt(),
      sameCountryOnly: json['same_country_only'] as bool,
      anywhere: json['anywhere'] as bool,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$InquiryToJson(Inquiry instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'user_id': instance.userId,
      'item_name': instance.itemName,
      'item_description': instance.itemDescription,
      'location': jsonEncode(instance.location),
      'search_radius_meters': instance.searchRadiusMeters,
      'same_country_only': instance.sameCountryOnly,
      'anywhere': instance.anywhere,
      'image_url': instance.imageUrl,
    };
