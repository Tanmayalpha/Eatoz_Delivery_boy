import 'dart:convert';

import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:deliveryboy_multivendor/Model/deliveryChargeModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AllDeliveryCharge extends StatefulWidget {
  const AllDeliveryCharge({Key? key}) : super(key: key);

  @override
  State<AllDeliveryCharge> createState() => _AllDeliveryChargeState();
}

class _AllDeliveryChargeState extends State<AllDeliveryCharge> {


    DeliveryChargeModel deliveryModel =  DeliveryChargeModel();

    var cityName;

    getRiderDetail()async{
      var headers = {
        'Cookie': 'ci_session=e90c4186f65bb67b49856836022c050df4ce225e'
      };
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}get_delivery_boy_details'));
      request.fields.addAll({
        'id': '${CUR_USERID}'
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var finalResult = await response.stream.bytesToString();
        final jsonResponse = json.decode(finalResult);
        setState(() {
          cityName = jsonResponse['data'][0]['city'].toString();
        });
        getAllDeliveryCharge(cityName);
      }
      else {
        print(response.reasonPhrase);
      }
    }

  getAllDeliveryCharge(String city)async{
    var headers = {
      'Cookie': 'ci_session=03a1081dbcf95b882c8c5203f0474f19df254001'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}get_delivery_charge_report'));
    request.fields.addAll({
      'user_id': '${CUR_USERID}',
      "city":"${city}"
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
       final jsonResult = DeliveryChargeModel.fromJson(json.decode(finalResult));
       setState(() {
         deliveryModel = jsonResult;
       });
    }
    else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Future.delayed(Duration(milliseconds: 400),(){
    //   return getAllDeliveryCharge();
    // });
    Future.delayed(Duration(milliseconds: 200),(){
      return  getRiderDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar("Delivery Charge", context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 15),
      child: deliveryModel ==  null ? Center(child: CircularProgressIndicator(),) : deliveryModel.data == null ? Center(child: Text("No data to show"),) :  ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: deliveryModel.data!.length,
            itemBuilder: (c,i){
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("City"),
                    Text("${deliveryModel.data![i].city}")
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Max_km"),
                    Text("${deliveryModel.data![i].maximumKm} KM")
                  ],
                ), SizedBox(height: 10,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Min_km"),
                    Text("${deliveryModel.data![i].minimumKm} KM")
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Delivery Charge"),
                    Text("\u{20B9} ${deliveryModel.data![i].deliveryCharges}")
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Extra Charge"),
                    Text("\u{20B9} ${deliveryModel.data![i].extraCharge}")
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
