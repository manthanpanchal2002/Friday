class db_data_help {
  String? key;
  data_Help? data_help;

  db_data_help({this.key, this.data_help});
}

class data_Help {
  String? title;
  String? que;
  String? ans;

  data_Help({this.title, this.que, this.ans});

  data_Help.fromJson(Map<dynamic, dynamic> json) {
    title = json['title'];
    que = json['que'];
    ans = json['ans'];
  }
}
