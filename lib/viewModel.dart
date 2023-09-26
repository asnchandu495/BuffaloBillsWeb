class EntriesData {
  late String? entriesPerMinute;
  late String? totalEntries;

  EntriesData({ this.entriesPerMinute,  this.totalEntries});

  EntriesData.fromJson(Map<String, dynamic> json) {
    entriesPerMinute = json['entriesPerMinute'];
    totalEntries = json['totalEntries'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entriesPerMinute'] = this.entriesPerMinute;
    data['totalEntries'] = this.totalEntries;
    return data;
  }


}



EntriesData entriesData = EntriesData();