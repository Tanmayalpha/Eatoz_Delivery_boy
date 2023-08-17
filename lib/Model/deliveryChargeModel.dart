/// error : false
/// message : "Data retrieved successfully"
/// data : [{"id":"4","city":"Indore","minimum_km":"0","maximum_km":"10","delivery_charges":"10","extra_charge":"1"},{"id":"7","city":"Indore","minimum_km":"1","maximum_km":"15","delivery_charges":"20","extra_charge":"30"},{"id":"8","city":"Indore","minimum_km":"0","maximum_km":"10","delivery_charges":"50","extra_charge":"10"}]

class DeliveryChargeModel {
  DeliveryChargeModel({
      bool? error, 
      String? message, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _data = data;
}

  DeliveryChargeModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  List<Data>? _data;
DeliveryChargeModel copyWith({  bool? error,
  String? message,
  List<Data>? data,
}) => DeliveryChargeModel(  error: error ?? _error,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get error => _error;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "4"
/// city : "Indore"
/// minimum_km : "0"
/// maximum_km : "10"
/// delivery_charges : "10"
/// extra_charge : "1"

class Data {
  Data({
      String? id, 
      String? city, 
      String? minimumKm, 
      String? maximumKm, 
      String? deliveryCharges, 
      String? extraCharge,}){
    _id = id;
    _city = city;
    _minimumKm = minimumKm;
    _maximumKm = maximumKm;
    _deliveryCharges = deliveryCharges;
    _extraCharge = extraCharge;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _city = json['city'];
    _minimumKm = json['minimum_km'];
    _maximumKm = json['maximum_km'];
    _deliveryCharges = json['delivery_charges'];
    _extraCharge = json['extra_charge'];
  }
  String? _id;
  String? _city;
  String? _minimumKm;
  String? _maximumKm;
  String? _deliveryCharges;
  String? _extraCharge;
Data copyWith({  String? id,
  String? city,
  String? minimumKm,
  String? maximumKm,
  String? deliveryCharges,
  String? extraCharge,
}) => Data(  id: id ?? _id,
  city: city ?? _city,
  minimumKm: minimumKm ?? _minimumKm,
  maximumKm: maximumKm ?? _maximumKm,
  deliveryCharges: deliveryCharges ?? _deliveryCharges,
  extraCharge: extraCharge ?? _extraCharge,
);
  String? get id => _id;
  String? get city => _city;
  String? get minimumKm => _minimumKm;
  String? get maximumKm => _maximumKm;
  String? get deliveryCharges => _deliveryCharges;
  String? get extraCharge => _extraCharge;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['city'] = _city;
    map['minimum_km'] = _minimumKm;
    map['maximum_km'] = _maximumKm;
    map['delivery_charges'] = _deliveryCharges;
    map['extra_charge'] = _extraCharge;
    return map;
  }

}