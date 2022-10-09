import 'dart:convert';

class SavedInfo {
  SavedInfo(
      {this.cuzIndex,
      this.cuzPosition,
      this.tabIndex});
  String? tabIndex;
  String? cuzIndex;
  String? cuzPosition;

  Map<String, dynamic> toJson() {
    return {
      'cuzIndex': cuzIndex,
      'cuzPosition': cuzPosition,
      'tabIndex': tabIndex,
    };
  }

  SavedInfo.fromJson(Map<String, dynamic> json) {
    cuzIndex = json["cuzIndex"] ?? "0";
    cuzPosition = json["cuzPosition"] ??"0";
    tabIndex = json["tabIndex"] ?? "0";
  }

  @override
  String toString() {
    return jsonEncode({
       'tabIndex': this.tabIndex,
      'cuzIndex': this.cuzIndex,
      'cuzPosition': this.cuzPosition,
    });
  }
}
