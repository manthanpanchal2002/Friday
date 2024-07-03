class db_data_subscription {
  String? key;
  data_Subscription? data_subscription;

  db_data_subscription({this.key, this.data_subscription});
}

class data_Subscription {
  String? cost;
  String? logo;
  String? subtitle;
  late List<String> services;

  data_Subscription(
      {this.cost, this.logo, this.subtitle, required this.services});

  data_Subscription.fromJson(Map<dynamic, dynamic> json) {
    cost = json['cost'];
    logo = json['logo'];
    subtitle = json['subtitle'];
    services = json['services'].cast<String>();
  }
}
