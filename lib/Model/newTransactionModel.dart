class NewTransactionModel {
  bool? error;
  String? message;
  String? total;
  List<Data>? data;

  NewTransactionModel({this.error, this.message, this.total, this.data});

  NewTransactionModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    total = json['total'];
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
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? userId;
  String? paymentType;
  String? paymentAddress;
  String? amountRequested;
  Null? remarks;
  String? status;
  String? dateCreated;

  Data(
      {this.id,
        this.userId,
        this.paymentType,
        this.paymentAddress,
        this.amountRequested,
        this.remarks,
        this.status,
        this.dateCreated});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    paymentType = json['payment_type'];
    paymentAddress = json['payment_address'];
    amountRequested = json['amount_requested'];
    remarks = json['remarks'];
    status = json['status'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['payment_type'] = this.paymentType;
    data['payment_address'] = this.paymentAddress;
    data['amount_requested'] = this.amountRequested;
    data['remarks'] = this.remarks;
    data['status'] = this.status;
    data['date_created'] = this.dateCreated;
    return data;
  }
}
