import 'dart:convert';

class SavedTabIndex {
  SavedTabIndex(
      {
      this.tabIndex});
  String? tabIndex;

  Map<String, dynamic> toJson() {
    return {
      'tabIndex': tabIndex,
    };
  }

  SavedTabIndex.fromJson(Map<String, dynamic> json) {
    tabIndex = json["tabIndex"] ?? "0";
  }

  @override
  String toString() {
    return jsonEncode({
       'tabIndex': this.tabIndex,
    });
  }
}
