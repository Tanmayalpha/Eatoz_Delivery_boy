import 'dart:convert';

import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:deliveryboy_multivendor/Model/reviewModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReviewScreen extends StatefulWidget {
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewModel reviewModel = ReviewModel();

  getReviews() async {
    var headers = {
      'Cookie': 'ci_session=fa06c22d38edeb57df9bb1c54d28a4db55f9a391'
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}get_rattings'));
    request.fields.addAll({'user_id': '${CUR_USERID}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = ReviewModel.fromJson(json.decode(finalResult));
      setState(() {
        reviewModel = jsonResponse;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      return getReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar("Reviews", context),
      body: reviewModel == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : reviewModel.data?.isEmpty ?? true
              ? Center(
                  child: Text("No review to show"),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: reviewModel.data!.length,
                  itemBuilder: (c, i) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Order Id"),
                              Text("#${reviewModel.data![i].orderId}")
                            ],
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text("Customer name"),
                          //     Text("${reviewModel.data![i].username}")
                          //   ],
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Ratting"),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("${reviewModel.data![i].ratting}"),
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 18,
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Comment"),
                              Container(
                                alignment: Alignment.centerRight,
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Text(
                                  "${reviewModel.data![i].comment}",
                                  maxLines: 3,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Date"),
                              Text("${DateFormat('dd/MM/yyyy').format(DateTime.parse(reviewModel.data![i].date.toString()))}"),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  }),
    );
  }
}
