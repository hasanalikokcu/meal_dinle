import 'dart:convert';

class SavedSureInfo {
  SavedSureInfo({
    this.sureIndex,
    this.surePosition,
  });
  String? sureIndex;
  String? surePosition;

  Map<String, dynamic> toJson() {
    return {
      'surePosition': surePosition,
      'sureIndex': sureIndex,
    };
  }

  SavedSureInfo.fromJson(Map<String, dynamic> json) {
    sureIndex = json["sureIndex"] ?? "0";
    surePosition = json["surePosition"] ?? "0";
  }

  @override
  String toString() {
    return jsonEncode(
        {'sureIndex': this.sureIndex, 'surePosition': this.surePosition});
  }
}
