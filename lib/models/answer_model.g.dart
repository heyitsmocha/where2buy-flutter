// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      storeName: json['store_name'] as String,
      storeAddress: json['store_address'] as String?,
      additionalInfo: json['additional_info'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'store_name': instance.storeName,
      'store_address': instance.storeAddress,
      'additional_info': instance.additionalInfo,
      'like_count': instance.likeCount,
      'image_url': instance.imageUrl,
    };
