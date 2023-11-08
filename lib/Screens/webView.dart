// // Copyright 2013 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
//
// import 'dart:convert';
//
// import 'package:deliveryboy_multivendor/Screens/home.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart'as http;
// import '../Helper/Color.dart';
// import '../Helper/constant.dart';
// import '../Helper/string.dart';
//
// class WebViewExample extends StatefulWidget {
//   final String url;
//    String? amount;
//    WebViewExample({ required this.url,required this.amount});
//
//   @override
//   State<WebViewExample> createState() => _WebViewExampleState();
// }
//
// class _WebViewExampleState extends State<WebViewExample> {
//   late final WebViewController _controller;
// //   String kNavigationExamplePage = '''<!DOCTYPE html>
// //   <html>
// //   <head>
// //     <title>WebView Test</title>
// //   </head>
// //   <body>
//
// //     <script>
// //       // Function to send a message to the Flutter app using the 'Toaster' JavaScript channel.
// //       function showMessage() {
// //         var message = {"code":"PAYMENT_SUCCESS","merchantId":"VOICECLUBONLINE","transactionId":"TXN1689950412867","amount":"100","providerReferenceId":"T2307212011529206276305","param1":"na","param2":"na","param3":"na","param4":"na","param5":"na","param6":"na","param7":"na","param8":"na","param9":"na","param10":"na","param11":"na","param12":"na","param13":"na","param14":"na","param15":"na","param16":"na","param17":"na","param18":"na","param19":"na","param20":"na","checksum":"f7ed2861b078d704c0f512fe96d8fe2ec761ccbb5a8aa4f71c0f2b8c02a01fd1###1"};
// //                 Toaster.postMessage(JSON.stringify(message));
//
// //       }
// //       showMessage()
// //     </script>
// //   </body>
// //   </html>
// // ''';
//   @override
//   void initState() {
//     super.initState();
//     // final String contentBase64 = base64Encode(
//     //   const Utf8Encoder().convert(kNavigationExamplePage),
//     // );
//     // #docregion platform_features
//     late final PlatformWebViewControllerCreationParams params;
//
//     params = const PlatformWebViewControllerCreationParams();
//
//     final WebViewController controller =
//     WebViewController.fromPlatformCreationParams(params);
//     // #enddocregion platform_features
//
//     controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             debugPrint('WebView is loading (progress : $progress%)');
//           },
//           onPageStarted: (String url) {
//             debugPrint('Page started loading: $url');
//           },
//           onPageFinished: (String url) {
//             debugPrint('Page finished loading: $url');
//             if(url.contains("ccevenue_response")){
//               Future.delayed(Duration(seconds: 3),() {
//                 uploadMoney(context);
//
//               },);
//             }
//           },
// //           onWebResourceError: (WebResourceError error) {
// //             debugPrint('''
// // Page resource error:
// //   code: ${error.errorCode}
// //   description: ${error.description}
// //   errorType: ${error.errorType}
// //   isForMainFrame: ${error.isForMainFrame}
// //           ''');
// //           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('https://www.youtube.com/')) {
//               debugPrint('blocking navigation to ${request.url}');
//               return NavigationDecision.prevent;
//             }
//             debugPrint('allowing navigation to ${request.url}');
//             return NavigationDecision.navigate;
//           },
//           onUrlChange: (UrlChange change) {
//             debugPrint('url change to ${change.url}');
//           },
//         ),
//       )
//       ..addJavaScriptChannel(
//         'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(content: Text(message.message)),
//           // );
//           print("Payment Data${message.message}");
//           Navigator.pop(context, message.message);
//         },
//       )
//       ..enableZoom(true)
//       ..loadRequest(Uri.parse(widget.url));
//     // ..loadRequest(Uri.parse("data:text/html;base64,$contentBase64"));
//
//     _controller = controller;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Payment'),
//         ),
//         backgroundColor: Colors.white,
//         body: WebViewWidget(controller: _controller),
//       ),
//     );
//   }
//
//   uploadMoney(BuildContext context,) async {
//     DateTime dateTime = DateTime.now();
//     print("checking date time here ${dateTime}");
//     var headers = {
//       'Cookie': 'ci_session=4c08e6643825ccb4cb6c79d834e9510080ee90f3'
//     };
//     var request = http.MultipartRequest(
//         'POST', Uri.parse(baseUrl + 'manage_cash_collection'));
//     request.fields.addAll({
//       'delivery_boy_id': '${CUR_USERID}',
//       'amount':widget.amount.toString(),
//       'date': dateTime.toString(),
//       'message': 'test'
//     });
//
//     request.headers.addAll(headers);
//     http.StreamedResponse response = await request.send();
//     if (response.statusCode == 200) {
//       var fianlResult = await response.stream.bytesToString();
//       final jsonResponse = json.decode(fianlResult);
//       // setSnackbar("");
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(),));
//       // BuildContext context;
//       // Navigator.pop(context, true);
//     } else {
//       print(response.reasonPhrase);
//     }
//   }
// }
//
// setSnackbar(String msg ,context) {
//   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//     content: Text(
//       msg,
//       textAlign: TextAlign.center,
//       style: TextStyle(color: black),
//     ),
//     backgroundColor: white,
//     elevation: 1.0,
//   ));
// }
