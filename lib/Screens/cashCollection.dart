import 'dart:convert';

import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:deliveryboy_multivendor/Screens/webView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/Session.dart';
import 'Webviewexample.dart';

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
    getPhonpayURL();
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
    print('___________${request.fields}__________');

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


  // void initiatePayment(String url) async{
  //   // Replace this with the actual PhonePe payment URL you have
  //  // String phonePePaymentUrl = '${url}';
  //  // String calBackurl = phonePePaymentUrl + 'Eatoz';
  //  // print("call back url ${calBackurl}");
  //   var data = await Navigator.push(context, CupertinoPageRoute(
  //     builder: (context) {
  //       return WebViewExample(
  //         amount: amountController.text,
  //           url: url);
  //     },
  //   ));
  //   print("Payment Data${data}");
  // }




  Future<void> initiatePayment() async {
    // Replace this with the actual PhonePe payment URL you have
    String phonePePaymentUrl = '${url}';
    String calBackurl = phonePePaymentUrl + 'Eatoz';
    print("call back url ${calBackurl}");
    var data = await Navigator.push(context!, CupertinoPageRoute(
      builder: (context) {
        return WebViewExample(
            url: phonePePaymentUrl);
      },
    ));
    print("Payment Data$data");
    if(data!=null){
      http.post(Uri.parse("https://developmentalphawizz.com/eatoz/app/v1/api/check_phonepay_status"),body: {
        "transaction_id": merchantTransactionId
      }).then((value) {
        print("Payment Data1${value.body}");
        Map response = jsonDecode(value.body);
        if(response['data']!=null) {
          setSnackbar("${response['data'][0]["message"]}");
          if ( response['data'][0]["error"]=="false"){
            uploadMoney();
          } else {
          }
        }else{
          setSnackbar("Payment Failed or Cancelled");
        }
      });
    }else{
      setSnackbar("Payment Failed or Cancelled");
    }
    /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('PhonePe Payment'),
          ),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(phonePePaymentUrl)),

            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStop: (controller, url) async {
              if (url.toString().contains('https://giftsbash.com/home/phonepay_success')) {
                handelPhonePaySuccess(url.toString());
                // Extract payment status from URL
                //String? paymentStatus = extractPaymentStatusFromUrl(url.toString());
                // Update payment status
              //  print("jhhhhhhhhhhhhhhhhhh ${url}");
               // setState(() {
                  //_paymentStatus = paymentStatus!;
             //   });
                await _webViewController?.stopLoading();
                if(await _webViewController?.canGoBack() ?? false){
                  await _webViewController?.goBack();
                }else {
                  print('${paymentStatuss}____________');
                  if(paymentStatuss == true){
                    placeOrder(merchantTransactionId);
                  }
                  Navigator.pop(context);
                }
                //
                // Stop loading and close WebView
              //
                //await _webViewController?.goBack();
              }
            },
          ),
        ),
      ),
    );*/
  }

  String? newStats;
  bool? paymentStatuss;
  handelPhonePaySuccess(String url) async{
    Map <String, dynamic> finalResult = await fetchPaymentStatus();
    if(finalResult['data'][0]['error'] ==  'true'){
      // newStats = false;
      Fluttertoast.showToast(msg: "Payment Failed");
      paymentStatuss  = false ;
    }
    else{
      paymentStatuss  = true ;
      Fluttertoast.showToast(msg: "Payment Success");
    }
  }

  Future<Map <String, dynamic>> fetchPaymentStatus () async {
    var headers = {
      'Cookie': 'ci_session=2192e13e91c2acac91d03ed3ab66370064afc742'
    };
    print(url);
    var request = http.MultipartRequest('POST', Uri.parse('https://developmentalphawizz.com/eatoz/app/v1/api/check_phonepay_status'));
    request.fields.addAll({
      'transaction_id': '${merchantTransactionId}'
    });
    print("check paymnet status ${request.fields}");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var Result = await response.stream.bytesToString();
      var finalResult = jsonDecode(Result);
      return finalResult;
    }
    else {
      var Result = await response.stream.bytesToString();
      var finalResult = jsonDecode(Result);
      return finalResult;
      //print(response.reasonPhrase);
    }
  }

  String? extractPaymentStatusFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String? paymentStatus = uri.queryParameters['status'];
    return paymentStatus;
  }

  String url = '';
  String? merchantId;
  String? merchantTransactionId;
  String? mobile;

  Future<void> getPhonpayURL() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mobile = preferences.getString("mobile");
    print('___mobile_______${mobile}_________');
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    var headers = {
      'Cookie': 'ci_session=56691520ceefd28e91e4992a486249c971156c0d'
    };
    var request = http.MultipartRequest('POST', Uri.parse('https://developmentalphawizz.com/eatoz/app/v1/api/initiate_phone_payment'));
    request.fields.addAll({
      'user_id': '$CUR_USERID',
      'mobile': '$mobile',
      'amount': amountController.text
    });
    print("initiate phone pay para${request.fields}");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print(result);
      var finalResult = jsonDecode(result);
      url = finalResult['data']['data']['instrumentResponse']['redirectInfo']['url'];
      merchantId = finalResult['data']['data']['merchantId'];
      merchantTransactionId = finalResult['data']['data']['merchantTransactionId'];
      print("merchante trancfags ${merchantTransactionId}");
      await initiatePayment();
    }
    else {
      print(response.reasonPhrase);
    }
  }

  // _initiateCcAvenuePayment(double totalPrice) async {
  //   // OrderModel model = OrderModel(listStatus: []);
  //   // try {
  //   //  // finalPrice = double.parse(amountController.text) * 100;
  //   //   // final finalPrice = totalPrice.toString();
  //   //   setState(() {
  //   //     // _loading = true;
  //   //     // errorText = "";
  //   //   });
  //   //   final response = await http.get(Uri.parse('${baseUrl}ccevenue_handler_wallet?amount=$finalPrice'));
  //   //   // .post(Uri.parse(UrlList.merchant_server_enc_url),
  //   //   // body: {"amount": amount});
  //   //   // final json = jsonDecode(response.body);
  //   //   // final data = PaymentData.fromJson(json);
  //   //   final data = response.body;
  //   //   var data1 =jsonDecode(data);
  //   //   String url = data1["message"];
  //   //   print('${response.body}_______dfkljd');
  //   //   // if (data.statusMessage == "SUCCESS") {
  //   //   initiatePayment(url);
  //   //   setState(() {
  //   //     // _loading = false;
  //   //   });
  //   //
  //   // } catch (e) {
  //   //   print(e.toString());
  //   //   setState(() {
  //   //     // _loading = false;
  //   //   });
  //   // }
  //
  //
  // }

  String? urlPath ;
  // _initiateCcAvenuePayment(double totalPrice) async {
  //   // OrderModel model = OrderModel(listStatus: []);
  //   // try {
  //   //   // finalPrice = double.parse(amountController.text) * 100;
  //   //   // final finalPrice = totalPrice.toString();
  //   //   setState(() {
  //   //     // _loading = true;
  //   //     // errorText = "";
  //   //   });
  //   DateTime dateTime = DateTime.now();
  //   var headers = {
  //     'Cookie': 'ci_session=vtq04ncq941lian925u84bhsvjicbr66'
  //   };
  //   var request = http.MultipartRequest('POST', Uri.parse(
  //       '${baseUrl}ccevenue_handler_wallet'));
  //   request.fields.addAll({
  //     //'amount': finalPrice.toString(),
  //     'delivery_boy_id': '${CUR_USERID}',
  //     'amount': amountController.text,
  //     'date': dateTime.toString(),
  //     'message': 'test'
  //   });
  //   print('_____request.fields______${request.fields}__________');
  //
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     var result = await response.stream.bytesToString();
  //     var finalResult = jsonDecode(result);
  //     setState(() {
  //       urlPath =  finalResult['message'];
  //     });
  //     print('____dddd_______${urlPath}__________');
  //     initiatePayment(urlPath!);
  //   }
  //   else {
  //     print(response.reasonPhrase);
  //   }
  //
  //
  //
  //   //   final response = await http.get(Uri.parse('${baseUrl}/ccevenue_handler_wallet?amount=$finalPrice'));
  //   //   // .post(Uri.parse(UrlList.merchant_server_enc_url),
  //   //   // body: {"amount": amount});
  //   //   // final json = jsonDecode(response.body);
  //   //   // final data = PaymentData.fromJson(json);
  //   //   final data = response.body;
  //   //   var data1 =jsonDecode(data);
  //   //   String url = data1["message"];
  //   //   print('${response.body}_______dfkljd');
  //   //   // if (data.statusMessage == "SUCCESS") {
  //   //
  //   //   setState(() {
  //   //     // _loading = false;
  //   //   });
  //   //
  //   // } catch (e) {
  //   //   print(e.toString());
  //   //   setState(() {
  //   //     // _loading = false;
  //   //   });
  //   // }
  // }

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
                        getPhonpayURL();
                        //_initiateCcAvenuePayment(double.parse(amountController.text));
                        // checkOut();
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
