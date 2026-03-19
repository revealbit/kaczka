import 'package:freezed_annotation/freezed_annotation.dart';

part 'costume.freezed.dart';
part 'costume.g.dart';

enum CostumeType { hat, body, accessory, background }

enum CostumeRarity { common, rare, epic }

@freezed
abstract class Costume with _$Costume {
  const factory Costume({
    required String id,
    required String name,
    required CostumeType type,
    required CostumeRarity rarity,
    required String assetPath,
    int? pricePoints,
  }) = _Costume;

  factory Costume.fromJson(Map<String, dynamic> json) => _$CostumeFromJson(json);
}

@freezed
abstract class UserCostume with _$UserCostume {
  const factory UserCostume({
    required String id,
    required Costume costume,
    required DateTime acquiredAt,
    @Default(false) bool isEquipped,
  }) = _UserCostume;

  factory UserCostume.fromJson(Map<String, dynamic> json) => _$UserCostumeFromJson(json);
}

@freezed
abstract class ShopItem with _$ShopItem {
  const factory ShopItem({
    required String id,
    required Costume costume,
    required int pricePoints,
    required DateTime availableUntil,
  }) = _ShopItem;

  factory ShopItem.fromJson(Map<String, dynamic> json) => _$ShopItemFromJson(json);
}
