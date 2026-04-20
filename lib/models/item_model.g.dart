// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemSearchSuggestion _$ItemSearchSuggestionFromJson(
        Map<String, dynamic> json) =>
    ItemSearchSuggestion(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ItemSearchSuggestionToJson(
        ItemSearchSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
