class ReviewModel {
  bool? error;
  String? message;
  List<Data>? data;

  ReviewModel({this.error, this.message, this.data});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? username;
  String? userId;
  String? driverId;
  String? orderId;
  String? comment;
  String? ratting;
  String? date;

  Data(
      {this.id,
      this.username,
      this.userId,
      this.driverId,
      this.orderId,
      this.comment,
      this.ratting,
      this.date});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    userId = json['user_id'];
    driverId = json['driver_id'];
    orderId = json['order_id'];
    comment = json['comment'];
    ratting = json['ratting'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['user_id'] = this.userId;
    data['driver_id'] = this.driverId;
    data['order_id'] = this.orderId;
    data['comment'] = this.comment;
    data['ratting'] = this.ratting;
    data['date'] = this.date;
    return data;
  }
}
