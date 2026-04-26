import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable()
class ItemSearchSuggestion {
  final int itemId;
  final String itemName;

  ItemSearchSuggestion({
    required this.itemId,
    required this.itemName,
  });

  factory ItemSearchSuggestion.fromJson(Map<String, dynamic> json) => _$ItemSearchSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$ItemSearchSuggestionToJson(this);
}