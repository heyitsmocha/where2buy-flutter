import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable()
class ItemSearchSuggestion {
  final int id;
  final String name;

  ItemSearchSuggestion({
    required this.id,
    required this.name,
  });

  factory ItemSearchSuggestion.fromJson(Map<String, dynamic> json) => _$ItemSearchSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$ItemSearchSuggestionToJson(this);
}