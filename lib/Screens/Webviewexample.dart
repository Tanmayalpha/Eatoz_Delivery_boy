
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  final String url;
  const WebViewExample({ required this.url});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;
//   String kNavigationExamplePage = '''<!DOCTYPE html>
//   <html>
//   <head>
//     <title>WebView Test</title>
//   </head>
//   <body>

//     <script>
//       // Function to send a message to the Flutter app using the 'Toaster' JavaScript channel.
//       function showMessage() {
//         var message = {"code":"PAYMENT_SUCCESS","merchantId":"VOICECLUBONLINE","transactionId":"TXN1689950412867","amount":"100","providerReferenceId":"T2307212011529206276305","param1":"na","param2":"na","param3":"na","param4":"na","param5":"na","param6":"na","param7":"na","param8":"na","param9":"na","param10":"na","param11":"na","param12":"na","param13":"na","param14":"na","param15":"na","param16":"na","param17":"na","param18":"na","param19":"na","param20":"na","checksum":"f7ed2861b078d704c0f512fe96d8fe2ec761ccbb5a8aa4f71c0f2b8c02a01fd1###1"};
//                 Toaster.postMessage(JSON.stringify(message));

//       }
//       showMessage()
//     </script>
//   </body>
//   </html>
// ''';
  @override
  void initState() {
    super.initState();
    // final String contentBase64 = base64Encode(
    //   const Utf8Encoder().convert(kNavigationExamplePage),
    // );
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            if(url.contains("phonepay_success")){
              Navigator.pop(context, url);
            }
          },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   isForMainFrame: ${error.isForMainFrame}
//           ''');
//           },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(message.message)),
          // );
          print("Payment Data${message.message}");
          Navigator.pop(context, message.message);
        },
      )
      ..enableZoom(true)
      ..loadRequest(Uri.parse(widget.url));
    // ..loadRequest(Uri.parse("data:text/html;base64,$contentBase64"));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('PhonePe Payment'),
        ),
        backgroundColor: Colors.white,
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
