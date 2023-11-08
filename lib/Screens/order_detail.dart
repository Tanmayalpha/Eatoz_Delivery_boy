import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/app_btn.dart';
import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:deliveryboy_multivendor/Model/order_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetail extends StatefulWidget {
  final Order_Model? model;
  final Function? updateHome;

  const OrderDetail({
    Key? key,
    this.model,
    this.updateHome,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  List<String> statusList = [
    // PLACED,
   // PROCESSED,
    SHIPED,
    DELIVERD,
    //CANCLED,
   // RETURNED,
   // WAITING
  ];
  bool? _isCancleable, _isReturnable, _isLoading = true;
  bool _isProgress = false;
  String? curStatus;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? otpC;

  File? imageFile;

  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      Navigator.pop(context,true);
    }
  }
  var selectStatus ;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.model!.itemList!.length; i++) {
      widget.model!.itemList![i].curSelected =
          widget.model!.itemList![i].status;
    }

    if (widget.model!.payMethod == "Bank Transfer") {
      statusList.removeWhere((element) => element == PLACED);
    }

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  bool finalDeliver = false;

  uploadSelfi() async {
    var headers = {
      'Cookie': 'ci_session=34dc067cb9d80e809951cb087f1541369032055d'
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}driver_selfie'));
    request.fields.addAll({'order_id': '${widget.model!.id}'});
    imageFile == null
        ? null
        : request.files.add(await http.MultipartFile.fromPath(
            'selfie_driver', imageFile!.path.toString()));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);
      if (jsonResponse['error'] == false) {
        var snackBar = SnackBar(
          content: Text('${jsonResponse['message']}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      setState(() {});
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: TRY_AGAIN_INT_LBL,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    print('___________${widget.model?.itemList?[0].status}__________');

    Order_Model model = widget.model!;
    String? pDate, prDate, sDate, dDate, cDate, rDate;

    if (model.listStatus!.contains(PLACED)) {
      pDate = model.listDate![model.listStatus!.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(PROCESSED)) {
      prDate = model.listDate![model.listStatus!.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(SHIPED)) {
      sDate = model.listDate![model.listStatus!.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(DELIVERD)) {
      dDate = model.listDate![model.listStatus!.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(CANCLED)) {
      cDate = model.listDate![model.listStatus!.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(RETURNED)) {
      rDate = model.listDate![model.listStatus!.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }

    _isCancleable = model.isCancleable == "1" ? true : false;
    _isReturnable = model.isReturnable == "1" ? true : false;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(ORDER_DETAIL, context),
      body: _isNetworkAvail
          ? Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  elevation: 0,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "$ORDER_ID_LBL - ${model.id!}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                        color: lightBlack2),
                                              ),
                                              Text(
                                                model.orderDate!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                        color: lightBlack2),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "$PAYMENT_MTHD - ${model.payMethod!}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(color: lightBlack2),
                                          ),
                                          Text(
                                            "$ORDER_TIME - ${model.orderTime!}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(color: lightBlack2),
                                          ),
                                          // model.deliveryTime != "" ? Text(
                                          //   "Delivered Time - ${model.deliveryTime}",
                                          //   style: Theme.of(context)
                                          //       .textTheme
                                          //       .subtitle2!
                                          //       .copyWith(color: lightBlack2),
                                          // ) : SizedBox(),
                                        ],
                                      ))),
                              model.delDate != null && model.delDate!.isNotEmpty
                                  ? Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "$PREFER_DATE_TIME: ${model.delDate!} - ${model.delTime!}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(color: lightBlack2),
                                        ),
                                      ))
                                  : Container(),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: Text(
                                          "Update order status",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      widget.model!.itemList!.length >= 1
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10),
                                              child: widget.model!.itemList![0]
                                                              .status !=
                                                          DELIVERD &&
                                                      widget.model!.itemList![0]
                                                              .status !=
                                                          "cancelled"
                                                  ? Row(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8.0),
                                                            child:
                                                                DropdownButtonFormField(
                                                              dropdownColor:
                                                                  lightWhite,
                                                              isDense: true,
                                                              iconEnabledColor:
                                                                  fontColor,
                                                              //iconSize: 40,
                                                              hint: Text(
                                                                "Update Status",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .subtitle2!
                                                                    .copyWith(
                                                                        color:
                                                                            fontColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                              ),
                                                              decoration:
                                                                  const InputDecoration(
                                                                filled: true,
                                                                isDense: true,
                                                                fillColor:
                                                                    lightWhite,
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            10),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              fontColor),
                                                                ),
                                                              ),
                                                              value: selectStatus,
                                                              onChanged: (dynamic
                                                                  newValue) {
                                                                setState(() {
                                                                  widget
                                                                          .model!
                                                                          .itemList![
                                                                              0]
                                                                          .curSelected =
                                                                      newValue;
                                                                });
                                                                print('___________${newValue}__________');
                                                              },
                                                              items: statusList
                                                                  .map((String
                                                                      st) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: st,
                                                                  child: st ==
                                                                          "shipped"
                                                                      ? Text(
                                                                          "Picked Up",
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .subtitle2!
                                                                              .copyWith(color: fontColor, fontWeight: FontWeight.bold),
                                                                        )
                                                                      : st == "processed"
                                                                          ? Text(
                                                                              "Preparing",
                                                                              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: fontColor, fontWeight: FontWeight.bold),
                                                                            )
                                                                          : Text(
                                                                              capitalize(st),
                                                                              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: fontColor, fontWeight: FontWeight.bold),
                                                                            ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        ),
                                                        // finalDeliver == true
                                                        //     ? SizedBox()
                                                        //     :
                                                        // widget
                                                        //             .model!
                                                        //             .itemList![
                                                        //                 0]
                                                        //             .curSelected ==
                                                        //         DELIVERD
                                                        //     ? SizedBox()
                                                        //     :
                                                        RawMaterialButton(
                                                          constraints:
                                                              const BoxConstraints
                                                                      .expand(
                                                                  width: 42,
                                                                  height: 42),
                                                          onPressed: () {
                                                            if (widget
                                                                        .model!
                                                                        .itemList![
                                                                            0]
                                                                        .item_otp !=
                                                                    null &&
                                                                widget
                                                                    .model!
                                                                    .itemList![
                                                                        0]
                                                                    .item_otp!
                                                                    .isNotEmpty &&
                                                                widget
                                                                        .model!
                                                                        .itemList![
                                                                            0]
                                                                        .item_otp !=
                                                                    "0" &&
                                                                widget
                                                                        .model!
                                                                        .itemList![
                                                                            0]
                                                                        .curSelected ==
                                                                    DELIVERD) {
                                                              otpDialog(
                                                                  widget
                                                                      .model!
                                                                      .itemList![
                                                                          0]
                                                                      .curSelected,
                                                                  widget.model!
                                                                      .otp,
                                                                  model.id,
                                                                  true,
                                                                  0);
                                                            } else {
                                                              updateOrder(
                                                                  widget
                                                                      .model!
                                                                      .itemList![
                                                                          0]
                                                                      .curSelected,
                                                                  model.id,
                                                                  true,
                                                                  0,
                                                                  widget
                                                                      .model!
                                                                      .itemList![
                                                                          0]
                                                                      .item_otp);
                                                            }
                                                          },
                                                          elevation: 2.0,
                                                          fillColor: fontColor,
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          child: const Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Icon(
                                                              Icons.send,
                                                              size: 20,
                                                              color: white,
                                                            ),
                                                          ),
                                                          shape:
                                                              const CircleBorder(),
                                                        )
                                                      ],
                                                    )
                                                  : widget.model!.itemList![0]
                                                              .status !=
                                                          "cancelled"
                                                      ? Text(
                                                          "DELIVERED",
                                                          style: TextStyle(
                                                              color: primary),
                                                        )
                                                      : Text(
                                                          "CANCELLED",
                                                          style: TextStyle(
                                                              color: primary),
                                                        ),
                                            )
                                      //     : Container(),
                                      // widget.model!.itemList![0].curSelected ==
                                      //             "delivered" ||
                                      //         widget.model!.itemList![0]
                                      //                 .curSelected ==
                                      //             "Delivered"
                                      //     ? imageFile == null
                                      //         ? Padding(
                                      //             padding:
                                      //                 const EdgeInsets.only(
                                      //                     left: 10, bottom: 5),
                                      //             child: MaterialButton(
                                      //               onPressed: () {
                                      //                 _getFromGallery();
                                      //               },
                                      //               child: Text(
                                      //                 "Upload Selfi",
                                      //                 style: TextStyle(
                                      //                     color: Colors.white),
                                      //               ),
                                      //               color: primary,
                                      //             ),
                                      //           )
                                      //         : Row(
                                      //             children: [
                                      //               Container(
                                      //                 height: 40,
                                      //                 width: 50,
                                      //                 child: Image.file(
                                      //                     imageFile!),
                                      //               ),
                                      //               MaterialButton(
                                      //                 onPressed: () {
                                      //                   uploadSelfi();
                                      //                 },
                                      //                 child: Text(
                                      //                   "Upload",
                                      //                   style: TextStyle(
                                      //                       color:
                                      //                           Colors.white),
                                      //                 ),
                                      //                 color: primary,
                                      //               )
                                      //             ],
                                      //           )
                                          : SizedBox()
                                    ],
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: model.itemList!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {
                                  OrderItem orderItem = model.itemList![i];
                                  return productItem(orderItem, model, i);
                                },
                              ),
                              /// addon section
                         model.addonList?.isEmpty ?? true  ?  SizedBox() :  Container(
                           color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height:10),
                                    Text("Addon Item"),
                                    SizedBox(height: 10,),
                                    ListView.separated(
                                      separatorBuilder: (c,i){
                                        return Divider();
                                      },
                                      shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: model.addonList!.length,
                                        itemBuilder: (c,i){
                                      return ListTile(
                                        leading: Container(
                                              height: 50,
                                          width: 50,
                                          child: Image.network("${model.addonList![i].image}",fit: BoxFit.cover,),
                                        ),
                                        title: Text("${model.addonList![i].name}"),
                                        subtitle: Text("\u{20B9} ${model.addonList![i].price}"),
                                        trailing: Text("Qty ${model.addonList![i].quantity}"),
                                      );
                                    })
                                  ],
                                ),
                              ),

                              sellerDetails(),
                              shippingDetails(),
                              priceDetails(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: DropdownButtonFormField(
                    //             dropdownColor: lightWhite,
                    //             isDense: true,
                    //             iconEnabledColor: fontColor,
                    //
                    //             hint: new Text(
                    //               "Update Status",
                    //               style: Theme.of(this.context)
                    //                   .textTheme
                    //                   .subtitle2!
                    //                   .copyWith(
                    //                       color: fontColor,
                    //                       fontWeight: FontWeight.bold),
                    //             ),
                    //            decoration: InputDecoration(
                    //               filled: true,
                    //               isDense: true,
                    //               fillColor: lightWhite,
                    //               contentPadding: EdgeInsets.symmetric(
                    //                   vertical: 10, horizontal: 10),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(color: fontColor),
                    //               ),
                    //             ),
                    //             value: widget.model!.activeStatus,
                    //             onChanged: (dynamic newValue) {
                    //               setState(() {
                    //                 curStatus = newValue;
                    //               });
                    //             },
                    //             items: statusList.map((String st) {
                    //               return DropdownMenuItem<String>(
                    //                 value: st,
                    //                 child: Text(
                    //                   capitalize(st),
                    //                   style: Theme.of(this.context)
                    //                       .textTheme
                    //                       .subtitle2!
                    //                       .copyWith(
                    //                           color: fontColor,
                    //                           fontWeight: FontWeight.bold),
                    //                 ),
                    //               );
                    //             }).toList(),
                    //           ),
                    //         ),
                    //       ),
                    //       RawMaterialButton(
                    //         constraints:
                    //             BoxConstraints.expand(width: 42, height: 42),
                    //         onPressed: () {
                    //           if (model.otp != null &&
                    //               model.otp!.isNotEmpty &&
                    //               model.otp != "0" &&
                    //               curStatus == DELIVERD)
                    //             otpDialog(
                    //                 curStatus, model.otp, model.id, false, 0);
                    //           else
                    //             updateOrder(curStatus, updateOrderApi, model.id,
                    //                 false, 0);
                    //         },
                    //         elevation: 2.0,
                    //         fillColor: fontColor,
                    //         padding: EdgeInsets.only(left: 5),
                    //         child: Align(
                    //           alignment: Alignment.center,
                    //           child: Icon(
                    //             Icons.send,
                    //             size: 20,
                    //             color: white,
                    //           ),
                    //         ),
                    //         shape: CircleBorder(),
                    //       )
                    //     ],
                    //   ),
                    // )
                  ],
                ),
                showCircularProgress(_isProgress, primary),
              ],
            )
          : noInternet(context),
    );
  }

  otpDialog(String? curSelected, String? otp, String? id, bool item,
      int index) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                print('___________${otp}_____fdffd_____');
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              OTP_LBL,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: fontColor),
                            )),
                        const Divider(color: lightBlack),
                        Form(
                            key: _formkey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return FIELD_REQUIRED;
                                        } else if (value.trim() != otp) {
                                          return OTPERROR;
                                        } else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        hintText: OTP_ENTER,
                                        hintStyle: Theme.of(this.context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                                color: lightBlack,
                                                fontWeight: FontWeight.normal),
                                      ),
                                      controller: otpC,
                                    )),
                              ],
                            ))
                      ])),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      CANCEL,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                    child: Text(
                      SEND_LBL,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final form = _formkey.currentState!;
                      if (form.validate()) {
                        form.save();
                        setState(() {
                          Navigator.pop(context);
                        });
                        updateOrder(curSelected, id, item, index, otp);
                      }
                    })
              ],
            );
          });
        });
  }

  _launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url =
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url =
          "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }
    await launch(url);
/*    if (await canLaunch(url)) {

    } else {
      throw 'Could not launch $url';
    }*/
  }

  Widget priceDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text("Bill Detail",
                      //PRICE_DETAIL,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: fontColor, fontWeight: FontWeight.bold))),
              const Divider(
                color: lightBlack,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$PRICE_LBL :",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("${CUR_CURRENCY!} ${double.parse(widget.model!.subTotal.toString()).toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$DELIVERY_CHARGE :",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("+ ${CUR_CURRENCY!} ${double.parse(widget.model!.delCharge.toString()).toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(" Total GST (${widget.model!.taxPer!}) :",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("+ ${CUR_CURRENCY!} ${double.parse(widget.model!.total_gst.toString()).toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$PROMO_CODE_DIS_LBL :",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("- ${CUR_CURRENCY!} ${double.parse(widget.model!.promoDis.toString()).toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$WALLET_BAL :",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("- ${CUR_CURRENCY!} ${double.parse(widget.model!.walBal.toString()).toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$TOTAL_PRICE :",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: lightBlack, fontWeight: FontWeight.bold)),
                    Text("${CUR_CURRENCY!} ${double.parse(widget.model!.total.toString()).toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: lightBlack, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ])));
  }

  Widget shippingDetails() {
    return Card( 
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(
                    children: [
                      Text("Delivery Detail",
                          //SHIPPING_DETAIL,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                  color: fontColor,
                                  fontWeight: FontWeight.bold)),
                      const Spacer(),
                      widget.model!.latitude != "" &&
                              widget.model!.longitude != ""
                          ? Container(
                              height: 30,
                              child: IconButton(
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: fontColor,
                                  ),
                                  onPressed: () {
                                    _launchMap(widget.model!.latitude,
                                        widget.model!.longitude);
                                  }),
                            )
                          : Container()
                    ],
                  )),
              const Divider(
                color: lightBlack,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    widget.model!.name != null && widget.model!.name!.isNotEmpty
                        ? " ${capitalize(widget.model!.name!)}"
                        : " ",
                  )),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                  child: Text(capitalize(widget.model!.address!),
                      style: const TextStyle(color: lightBlack2))),
                  widget.model?.itemList?[0].status == 'delivered' ? SizedBox(): InkWell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 5),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.call,
                            size: 15,
                            color: fontColor,
                          ),
                          Text(" ${widget.model!.mobile!}",
                              style: const TextStyle(
                                  color: fontColor,
                                  decoration: TextDecoration.underline)),
                        ],
                      )),
                  onTap: () {
                    _launchCaller(widget.model!.mobile!);
                  }),
            ])));
  }

  Widget sellerDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(
                    children: [
                      Text("Restaurant Details",
                          //SELLER_DETAILS,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                  color: fontColor,
                                  fontWeight: FontWeight.bold)),
                      const Spacer(),
                      widget.model!.itemList![0].storeLatitude != "" &&
                              widget.model!.itemList![0].storeLongitude != ""
                          ? Container(
                              height: 30,
                              child: IconButton(
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: fontColor,
                                  ),
                                  onPressed: () {
                                    _launchMap(
                                        widget
                                            .model!.itemList![0].storeLatitude,
                                        widget.model!.itemList![0]
                                            .storeLongitude);
                                  }),
                            )
                          : Container(),
                    ],
                  )),
              Padding( padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(widget.model!.itemList![0].storeName ?? '', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(widget.model!.itemList![0].sellerAddress ?? ''),

                ],),
              ),
              const Divider(
                color: lightBlack,
              ),
              // Row(
              //   children: [
              //     ClipRRect(
              //         borderRadius: BorderRadius.circular(10.0),
              //         child: FadeInImage(
              //           fadeInDuration: const Duration(milliseconds: 150),
              //           image: NetworkImage(
              //               widget.model!.itemList![0].storeImage!),
              //           height: 90.0,
              //           width: 90.0,
              //           placeholder: placeHolder(90),
              //         )),
              //     Expanded(
              //         child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Padding(
              //             padding:
              //                 const EdgeInsets.only(left: 15.0, right: 15.0),
              //             child: Text(
              //               widget.model!.itemList![0].storeName != null &&
              //                       widget.model!.itemList![0].storeName!
              //                           .isNotEmpty
              //                   ? " ${capitalize(widget.model!.itemList![0].storeName!)}"
              //                   : " ",
              //               style: TextStyle(fontWeight: FontWeight.bold),
              //             )),
              //         Padding(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 15.0, vertical: 3),
              //             child: Text(
              //                 capitalize(
              //                     widget.model!.itemList![0].sellerAddress!),
              //                 style: const TextStyle(color: lightBlack2))),
              //         InkWell(
              //             child: Padding(
              //                 padding: const EdgeInsets.symmetric(
              //                     horizontal: 15.0, vertical: 5),
              //                 child: Row(
              //                   children: [
              //                     const Icon(
              //                       Icons.call,
              //                       size: 15,
              //                       color: fontColor,
              //                     ),
              //                     Text(
              //                         " ${widget.model!.itemList![0].sellerMobileNumber!}",
              //                         style: const TextStyle(
              //                             color: fontColor,
              //                             decoration:
              //                                 TextDecoration.underline)),
              //                   ],
              //                 )),
              //             onTap: () {
              //               _launchCaller(
              //                   widget.model!.itemList![0].sellerMobileNumber!);
              //             }),
              //       ],
              //     ))
              //   ],
              // ),
            ])));
  }

  Widget productItem(OrderItem orderItem, Order_Model model, int i) {
    List att = [], val = [];
    if (orderItem.attr_name!.isNotEmpty) {
      att = orderItem.attr_name!.split(',');
      val = orderItem.varient_values!.split(',');
    }

    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: NetworkImage(orderItem.image!),
                          height: 90.0,
                          width: 90.0,
                          placeholder: placeHolder(90),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItem.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                      color: lightBlack,
                                      fontWeight: FontWeight.normal),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            orderItem.attr_name!.isNotEmpty
                                ? ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: att.length,
                                    itemBuilder: (context, index) {
                                      return Row(children: [
                                        Flexible(
                                          child: Text(
                                            att[index].trim() + ":",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(color: lightBlack2),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            val[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(color: lightBlack),
                                          ),
                                        )
                                      ]);
                                    })
                                : Container(),
                            Row(children: [
                              Text(
                                "$QUANTITY_LBL:",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(color: lightBlack2),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  orderItem.qty!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(color: lightBlack),
                                ),
                              )
                            ]),
                            Text(
                              "${CUR_CURRENCY!} ${orderItem.price!}",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: fontColor),
                            ),
                            // widget.model!.itemList!.length >= 1
                            //     ? Padding(
                            //         padding: const EdgeInsets.symmetric(
                            //             vertical: 10.0),
                            //         child: orderItem.status != DELIVERD &&
                            //                 orderItem.status != "cancelled"
                            //             ? Row(
                            //                 children: [
                            //                   Expanded(
                            //                     child: Padding(
                            //                       padding:
                            //                           const EdgeInsets.only(
                            //                               right: 8.0),
                            //                       child:
                            //                           DropdownButtonFormField(
                            //                         dropdownColor: lightWhite,
                            //                         isDense: true,
                            //                         iconEnabledColor: fontColor,
                            //                         //iconSize: 40,
                            //                         hint: Text(
                            //                           "Update Status",
                            //                           style: Theme.of(context)
                            //                               .textTheme
                            //                               .subtitle2!
                            //                               .copyWith(
                            //                                   color: fontColor,
                            //                                   fontWeight:
                            //                                       FontWeight
                            //                                           .bold),
                            //                         ),
                            //                         decoration:
                            //                             const InputDecoration(
                            //                           filled: true,
                            //                           isDense: true,
                            //                           fillColor: lightWhite,
                            //                           contentPadding:
                            //                               EdgeInsets.symmetric(
                            //                                   vertical: 10,
                            //                                   horizontal: 10),
                            //                           enabledBorder:
                            //                               OutlineInputBorder(
                            //                             borderSide: BorderSide(
                            //                                 color: fontColor),
                            //                           ),
                            //                         ),
                            //                         value: orderItem.status,
                            //                         onChanged:
                            //                             (dynamic newValue) {
                            //                           setState(() {
                            //                             orderItem.curSelected =
                            //                                 newValue;
                            //                           });
                            //                         },
                            //                         items: statusList
                            //                             .map((String st) {
                            //                           return DropdownMenuItem<
                            //                               String>(
                            //                             value: st,
                            //                             child: st == "shipped"
                            //                                 ? Text(
                            //                                     "Picked Up",
                            //                                     style: Theme.of(
                            //                                             context)
                            //                                         .textTheme
                            //                                         .subtitle2!
                            //                                         .copyWith(
                            //                                             color:
                            //                                                 fontColor,
                            //                                             fontWeight:
                            //                                                 FontWeight.bold),
                            //                                   )
                            //                                 : st == "processed"
                            //                                     ? Text(
                            //                                         "Preparing",
                            //                                         style: Theme.of(
                            //                                                 context)
                            //                                             .textTheme
                            //                                             .subtitle2!
                            //                                             .copyWith(
                            //                                                 color:
                            //                                                     fontColor,
                            //                                                 fontWeight:
                            //                                                     FontWeight.bold),
                            //                                       )
                            //                                     : Text(
                            //                                         capitalize(
                            //                                             st),
                            //                                         style: Theme.of(
                            //                                                 context)
                            //                                             .textTheme
                            //                                             .subtitle2!
                            //                                             .copyWith(
                            //                                                 color:
                            //                                                     fontColor,
                            //                                                 fontWeight:
                            //                                                     FontWeight.bold),
                            //                                       ),
                            //                           );
                            //                         }).toList(),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   RawMaterialButton(
                            //                     constraints:
                            //                         const BoxConstraints.expand(
                            //                             width: 42, height: 42),
                            //                     onPressed: () {
                            //                       if (orderItem.item_otp !=
                            //                               null &&
                            //                           orderItem.item_otp!
                            //                               .isNotEmpty &&
                            //                           orderItem.item_otp !=
                            //                               "0" &&
                            //                           orderItem.curSelected ==
                            //                               DELIVERD) {
                            //                         otpDialog(
                            //                             orderItem.curSelected,
                            //                             orderItem.item_otp,
                            //                             model.id,
                            //                             true,
                            //                             i);
                            //                       } else {
                            //                         updateOrder(
                            //                             orderItem.curSelected,
                            //                             model.id,
                            //                             true,
                            //                             i,
                            //                             orderItem.item_otp);
                            //                       }
                            //                     },
                            //                     elevation: 2.0,
                            //                     fillColor: fontColor,
                            //                     padding: const EdgeInsets.only(
                            //                         left: 5),
                            //                     child: const Align(
                            //                       alignment: Alignment.center,
                            //                       child: Icon(
                            //                         Icons.send,
                            //                         size: 20,
                            //                         color: white,
                            //                       ),
                            //                     ),
                            //                     shape: const CircleBorder(),
                            //                   )
                            //                 ],
                            //               )
                            //             : orderItem.status != "cancelled"
                            //                 ? Text(
                            //                     "DELIVERED",
                            //                     style:
                            //                         TextStyle(color: primary),
                            //                   )
                            //                 : Text(
                            //                     "CANCELLED",
                            //                     style:
                            //                         TextStyle(color: primary),
                            //                   ),
                            //       )
                            //     : Container(),
                            // orderItem.curSelected == "delivered" ||
                            //         orderItem.curSelected == "Delivered"
                            //     ? imageFile == null
                            //         ? MaterialButton(
                            //             onPressed: () {
                            //               _getFromGallery();
                            //             },
                            //             child: Text(
                            //               "Upload Selfi",
                            //               style: TextStyle(color: Colors.white),
                            //             ),
                            //             color: primary,
                            //           )
                            //         : Row(
                            //             children: [
                            //               Container(
                            //                 height: 40,
                            //                 width: 50,
                            //                 child: Image.file(imageFile!),
                            //               ),
                            //               MaterialButton(
                            //                 onPressed: () {
                            //                   uploadSelfi();
                            //                 },
                            //                 child: Text(
                            //                   "Upload",
                            //                   style: TextStyle(
                            //                       color: Colors.white),
                            //                 ),
                            //                 color: primary,
                            //               )
                            //             ],
                            //           )
                            //     : SizedBox()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
               // orderItem.addonList == null ? SizedBox.shrink() :   SizedBox(height: 10,),
              //   orderItem.addonList?.isEmpty ?? true  ? SizedBox.shrink() :  Align(
              //     alignment: Alignment.topLeft,
              //     child: Text("Add-on")),
              // SizedBox(height: 10,),
              // orderItem.addonList == null ? SizedBox.shrink() : Container(
              //    child: ListView.separated(
              //      separatorBuilder: (c,i){
              //        return Divider();
              //      },
              //        shrinkWrap: true,
              //        itemCount: orderItem.addonList!.length,
              //        physics: NeverScrollableScrollPhysics(),
              //        itemBuilder: (context,i){
              //          return ListTile(
              //            leading: Container(
              //              height: 55,
              //              width: 55,
              //              child: Image.network("${orderItem.addonList![i].image}",fit: BoxFit.fill,),
              //            ),
              //            title: Text("${orderItem.addonList![i].name}"),
              //            subtitle: Text("\u{20B9} ${orderItem.addonList![i].price}"),
              //            trailing: Text("Qty ${orderItem.addonList![i].quantity}"),
              //          );
              //        }),
              //  ),
              ],
            )));
  }

  Future<void> updateOrder(
      String? status, String? id, bool item, int index, String? otp) async {
    var headers = {
      'Cookie': 'ci_session=6e22d3d3dcc0b0b41fa79c9d24f5d4b6609ce74a'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseUrl}updat_order_status'));
    request.fields.addAll({
      'order_id': '${id}',
      'status': '${status}',
      'delivery_boy_id': '${CUR_USERID}',
      'otp': '${otp}'
    });
    print(
        "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm ${request.fields} nad ${baseUrl}updat_order_status");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);
      setState(() {
        setSnackbar(jsonResponse['message']);
        finalDeliver = true;
      });
    } else {
      print(response.reasonPhrase);
    }

    // _isNetworkAvail = await isNetworkAvailable();
    // if (_isNetworkAvail) {
    //   try {
    //     setState(() {
    //       _isProgress = true;
    //     });

    //     var parameter = {
    //       ORDERID: widget.model!.id,
    //       STATUS: status,
    //       DEL_BOY_ID: CUR_USERID,
    //       OTP: otp
    //     };
    //     // if (item) parameter[ORDERITEMID] = widget.model!.itemList![index].id;

    //     print(
    //         "parametera are here" + parameter.toString() + "${updateOrderApi}");
    //     Response response =
    //         await post(updateOrderApi, body: parameter, headers: headers)
    //             .timeout(Duration(seconds: timeOut));

    //     var getdata = json.decode(response.body);
    //     bool error = getdata["error"];
    //     String msg = getdata["message"];
    //     setSnackbar(msg);
    //     if (!error) {
    //       if (item) {
    //         widget.model!.itemList![index].status = status;
    //       } else {
    //         widget.model!.activeStatus = status;
    //       }
    //     }

    //     setState(() {
    //       _isProgress = false;
    //     });
    //   } on TimeoutException catch (_) {
    //     setSnackbar(somethingMSg);
    //   }
    // } else {
    //   setState(() {
    //     _isNetworkAvail = false;
    //   });
    // }
  }

  void _launchCaller(String phoneNumber) async {
    var url = "tel:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      setSnackbar('Could not launch $url');
      throw 'Could not launch $url';
    }
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
}
