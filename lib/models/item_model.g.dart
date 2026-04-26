// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemSearchSuggestion _$ItemSearchSuggestionFromJson(
        Map<String, dynamic> json) =>
    ItemSearchSuggestion(
      itemId: (json['item_id'] as num).toInt(),
      itemName: json['item_name'] as String,
    );

Map<String, dynamic> _$ItemSearchSuggestionToJson(
        ItemSearchSuggestion instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'item_name': instance.itemName,
    };
