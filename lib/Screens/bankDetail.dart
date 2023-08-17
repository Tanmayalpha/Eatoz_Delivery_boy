import 'dart:convert';

import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class BankDetail extends StatefulWidget {
  const BankDetail({Key? key}) : super(key: key);

  @override
  State<BankDetail> createState() => _BankDetailState();
}

class _BankDetailState extends State<BankDetail> {


  String? accountName,accountNumber,bankName,bankCode;

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
        accountName = jsonResponse['data'][0]['account_name'].toString();
        accountNumber = jsonResponse['data'][0]['account_number'].toString();
        bankCode = jsonResponse['data'][0]['ifsc_code'].toString();
        bankName = jsonResponse['data'][0]['bank_name'].toString();

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
    Future.delayed(Duration(milliseconds: 200),(){
      return getRiderDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar("Bank Detail", context),
      body: Container(
        child: Column(
          children: [
            ListTile(
              title: Text("Account Name"),
              subtitle: accountName == "" || accountName == null || accountName == "null" ? Text("Not added yet") : Text("${accountName}"),
            ),
            ListTile(
              title: Text("Account Number"),
              subtitle: accountNumber == "" || accountNumber == null || accountNumber == "null" ? Text("Not added yet") :Text("${accountNumber}"),
            ),
            ListTile(
              title: Text("Bank Name"),
              subtitle:bankName == "" || bankName == null || bankName == "null" ? Text("Not added yet") : Text("${bankName}"),
            ),
            ListTile(
              title: Text("Bank Code"),
              subtitle:bankCode == "" || bankCode == null || bankCode == "null" ? Text("Not added yet") : Text("${bankCode}"),
            ),
          ],
        ),
      ),
    );
  }
}
