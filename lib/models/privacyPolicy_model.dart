class db_data_privacyPolicy{
  String? key;
  data_PrivacyPolicy? data_privacyPolicy;

  db_data_privacyPolicy({this.key, this.data_privacyPolicy});
}

class data_PrivacyPolicy{
  String? introduction;
  String? section;
  String? detail;

  data_PrivacyPolicy({this.introduction, this.section, this.detail});

  data_PrivacyPolicy.fromJson(Map<dynamic, dynamic> json) {
    introduction = json['introduction'];
    section = json['section'];
    detail = json['detail'];
  }
}