import 'dart:convert';

import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../Helper/Session.dart';

class CashCollection extends StatefulWidget {
  String? cashValue;
  CashCollection({this.cashValue});
  @override
  State<CashCollection> createState() => _CashCollectionState();
}

class _CashCollectionState extends State<CashCollection> {
  Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUserDetails();
    //UNCOMMENT
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  TextEditingController amountController = TextEditingController();
  uploadMoney() async {
    DateTime dateTime = DateTime.now();
    print("checking date time here ${dateTime}");
    var headers = {
      'Cookie': 'ci_session=4c08e6643825ccb4cb6c79d834e9510080ee90f3'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(baseUrl + 'manage_cash_collection'));
    request.fields.addAll({
      'delivery_boy_id': '${CUR_USERID}',
      'amount': amountController.text,
      'date': dateTime.toString(),
      'message': 'test'
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var fianlResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(fianlResult);
      setState(() {
        setSnackbar("${jsonResponse['message']}");
      });
      Navigator.pop(context, true);
    } else {
      print(response.reasonPhrase);
    }
  }

  double finalPrice = 0;

  checkOut() {
    finalPrice = double.parse(amountController.text) * 100;
    print(finalPrice);
    var options = {
      'key': "rzp_test_CpvP0qcfS4CSJD",
      'amount': finalPrice.toStringAsFixed(0),
      'currency': 'INR',
      'name': 'Eatoz',
      'description': '',
      // 'prefill': {'contact': userMobile, 'email': userEmail},
    };
    print("OPTIONS ===== $options");
    _razorpay.open(options);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // var userId = await MyToken.getUserID();
    uploadMoney();
    // purchasePlan("$userId", planI,"${response.paymentId}");
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("FAILURE === ${response.message}");
    // UtilityHlepar.getToast("${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear(); //UNCOMMENT
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar("Cash Collection", context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8)),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Total Cash Collection",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "\u{20b9} ${widget.cashValue}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: "Enter amount",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    onPressed: () {
                      //uploadMoney();
                      if (amountController.text.isEmpty) {
                        setSnackbar("Amount is required");
                      } else {
                        checkOut();
                      }
                    },
                    child: Text(
                      "Debit to Admin",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    color: primary,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
