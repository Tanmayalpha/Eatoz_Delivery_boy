import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:deliveryboy_multivendor/Screens/Delivery_Charge_Record.dart';
import 'package:deliveryboy_multivendor/Screens/ReviewScreen.dart';
import 'package:deliveryboy_multivendor/Screens/bankDetail.dart';
import 'package:deliveryboy_multivendor/Screens/cashCollection.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/app_btn.dart';
import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/push_notification_service.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:deliveryboy_multivendor/Model/order_model.dart';
import 'package:deliveryboy_multivendor/Screens/Authentication/login.dart';
import 'package:deliveryboy_multivendor/Screens/daily_collection.dart';
import 'package:deliveryboy_multivendor/Screens/transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notification_lIst.dart';
import 'order_detail.dart';
import 'privacy_policy.dart';
import 'profile.dart';
import 'wallet_history.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

int? total, offset;
List<Order_Model> orderList = [];
bool _isLoading = true;
bool isLoadingmore = true;
bool isLoadingItems = true;

class StateHome extends State<Home> with TickerProviderStateMixin {
  int curDrwSel = 0;

  bool _isNetworkAvail = true;
  List<Order_Model> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String? profile;
  ScrollController controller = ScrollController();
  List<String> statusList = [
    ALL,
    //  PLACED,
    //  PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
    RETURNED,
    awaitingPayment
  ];
  String? activeStatus;

  bool isCod = false;
  var onOf = false;

  String? cashCollection;

  XFile? imageValue;
  var picker = ImagePicker();
  Future pickImage() async {
    try {
      final image =
          await picker.pickImage(source: ImageSource.camera, maxHeight: 480,maxWidth: 480);
      if (image == null) return;
      setState(() {
        imageValue = image;
      });
      uploadDailVaku();
      print("checking attendence detail here now ${imageValue}");
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  String? latitude, longitude;

  TextEditingController pinController = TextEditingController();
  String? currentAdress;

  Future<void> getCurrentLoc() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("checking permission here ${permission}");
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    List<Placemark> placemark = await placemarkFromCoordinates(
        double.parse(latitude!), double.parse(longitude!),
        localeIdentifier: "en");
    print("sfsfsfsfsfsfs ${placemark}");
    pinController.text = placemark[0].postalCode!;
    if (mounted) {
      setState(() {
        //  pinController.text = placemark[0].postalCode!;
        currentAdress =
            "${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].locality}";
        print("here is address now ${currentAdress}");
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        // loc.lng = position.longitude.toString();
        // loc.lat = position.latitude.toString();
        // callApi();
        setLatLongApi(lat: latitude.toString(), long: longitude.toString(),city: placemark[0].locality.toString(), address:  currentAdress  );
      });
    }
  }

  uploadDailVaku() async {
    var headers = {
      'Cookie': 'ci_session=e473a8f272bc3c7f7b7ee0134640fccc71106ebb'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}driver_selfie_daily'));

    request.fields.addAll({
    'driver_id': CUR_USERID ?? ''
    });


    if(imageValue!= null) {
      request.files.add(await http.MultipartFile.fromPath(
          'selfie_driver', imageValue?.path ?? ''));
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResponse = await response.stream.bytesToString();
      print('___________${finalResponse}__________');
      final jsonResponse = json.decode(finalResponse);
      setState(() {});
     getUserDetail();
      setSnackbar("${jsonResponse['message']}");
      _refresh();
    } else {
      print(response.reasonPhrase);
    }
  }

  Timer? timer;

  @override
  void initState() {
    offset = 0;
    total = 0;
    Future.delayed(Duration(milliseconds: 200), () {
      return getUserDetail();
    });
    orderList.clear();
    Future.delayed(Duration(milliseconds: 200), () {
      return getCurrentLoc();
    });
    getSetting();
    getOrder();
    deliStatus();

    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();

    buttonController = AnimationController(
        duration: Duration(seconds: 30), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));
    controller.addListener(_scrollListener);

    super.initState();
   timer = Timer.periodic(Duration(minutes: 5), (Timer t) => _refresh());
  }

  logoutButton() async {
    var headers = {
      'Cookie': 'ci_session=37978006e2bfc2cd7e58dcd7b6b29262c297fcd2'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}logout'));
    request.fields.addAll({'seller_id': '${CUR_USERID}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);
    } else {
      print(response.reasonPhrase);
    }
  }

  updateOrderStatus(String status, String orderId) async {
    var headers = {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2ODE5ODc5OTEsImlhdCI6MTY4MTk4NzY5MSwiaXNzIjoiZXNob3AifQ.LMTo_qkmmZqSov7GAJa-X-J8SgWb4WWPg0r9wa94byY',
      'Cookie': 'ci_session=3ef557a8765d76b156c203fba06a0e0f42aa335a'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseUrl}accept_reject_order'));
    request.fields.addAll({
      'accept_reject': '${status}',
      'order_id': '${orderId}',
      'delivery_boy_id': '${CUR_USERID}'
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);
      if (jsonResponse['error'] == false) {
        setState(() {
          setSnackbar("${jsonResponse['message']}");
        });
        getOrder();
        _refresh();
      } else {}
    } else {
      print(response.reasonPhrase);
    }
  }

  _getLocation() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              "AIzaSyCqQW9tN814NYD_MdsLIb35HRY65hHomco",
              // "AIzaSyCK3y1HjzAS3RGDTwGE6EITRzmimOBGGoQ",
            )));
    // print("checking adderss detail ${result.la}");
    setState(() {
      currentAdress = result.formattedAddress.toString();
      print(
          "checking current address ${result.formattedAddress} and ${result.city!.name.toString()}");
      //cityC.text = result.locality.toString();
      // _cityController.text = result.city!.name.toString();
      // stateC!.text = result.administrativeAreaLevel1!.name.toString();
      // countryC!.text = result.country!.name.toString();
      latitude = result.latLng!.latitude.toString();
      longitude = result.latLng!.longitude.toString();
      // pincodeC!.text = result.postalCode.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: AppBar(
        title: Text(
          appName,
          style: TextStyle(
            color: grad2Color,
          ),
        ),
        iconTheme: IconThemeData(color: grad2Color),
        backgroundColor: white,
        actions: [
          InkWell(
              onTap: filterDialog,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: primary,
                  )))
        ],
      ),
      drawer: _getDrawer(),
      body:
      // _isNetworkAvail
      //     ? _isLoading
      //         ? shimmer()
      //         :
      RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    getCurrentLoc();
                                    // _getLocation();
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(9),
                                        color: Colors.white),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.my_location_rounded,
                                            size: 15,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            currentAdress == null
                                                ? "Loading address.."
                                                : "${currentAdress}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                onOf
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1,
                                        color: Colors.green,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "Online",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ))
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.5,
                                              color: Colors.red,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      "Offline",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          InkWell(
                                            onTap: () {
                                              pickImage();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.green),
                                              height: 35,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.5,
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Upload Attendence",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                SizedBox(
                                  height: 10,
                                ),
                                _detailHeader(),
                                _detailHeader2(),
                                SizedBox(
                                  height: 10,
                                ),
                                orderList.isEmpty
                                    ? isLoadingItems
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : const Center(child: Text(noItem))
                                    : Container(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  getOrder();
                                                  setState(() {
                                                    isCod = false;
                                                  });
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: isCod == false
                                                              ? primary
                                                              : Colors
                                                                  .transparent)),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "All Orders",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  getOrder();
                                                  setState(() {
                                                    isCod = true;
                                                  });
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: isCod == true
                                                              ? primary
                                                              : Colors
                                                                  .transparent)),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "COD Orders",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: (offset! < total!)
                                      ? orderList.length + 1
                                      : orderList.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {

                                    if (isCod == true) {

                                      return (index == orderList.length &&
                                              isLoadingmore)
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : orderList[index].itemList!.length >
                                                      0 &&
                                                  orderList[index].payMethod ==
                                                      "COD"
                                              ? orderItem(index)
                                              : Center(child: Padding(
                                                padding: EdgeInsets.only(top: 20),
                                                child: SizedBox.shrink()
                                              ),);
                                    } else {
                                      (index == orderList.length &&
                                              isLoadingmore)
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : orderList[index].itemList!.length >
                                                  0
                                              ? orderItem(index)
                                              : SizedBox();
                                    }
                                    return (index == orderList.length &&
                                            isLoadingmore)
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : orderList[index].itemList!.length > 0
                                            ? orderItem(index)
                                            : SizedBox();
                                  },
                                )
                              ]))))
          // : noInternet(context),
    );
  }

  void filterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: const ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: AlertDialog(
                elevation: 2.0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          'Filter By',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: fontColor),
                        )),
                    Divider(color: lightBlack),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: getStatusList()),
                      ),
                    ),
                  ]),
                )),
          );
        });
  }

  List<Widget> getStatusList() {
    return statusList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            Column(
              children: [
                Container(
                  width: double.maxFinite,
                  child: TextButton(
                      child: statusList[index] == "shipped"
                          ? Text(
                              "Picked Up",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: lightBlack),
                            )
                          : statusList[index] == "received"
                              ? Text(
                                  "Preparing",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(color: lightBlack),
                                )
                              : Text(capitalize(statusList[index]),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(color: lightBlack)),
                      onPressed: () {
                        setState(() {
                          activeStatus = index == 0 ? null : statusList[index];
                          isLoadingmore = true;
                          offset = 0;
                          isLoadingItems = true;
                        });

                        getOrder();

                        Navigator.pop(context, 'option $index');
                      }),
                ),
                const Divider(
                  color: lightBlack,
                  height: 1,
                ),
              ],
            ),
          ),
        )
        .values
        .toList();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset! < total!) getOrder();
        });
      }
    }
  }

  Drawer _getDrawer() {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: white,
          child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              _getHeader(),
              Divider(),
              _getDrawerItem(0, HOME_LBL, Icons.home_outlined),
              _getDrawerItem(3, "Bank Detail", Icons.currency_rupee),
              _getDrawerItem(4, "Delivery Charges", Icons.delivery_dining),
              _getDrawerItem(7, WALLET, Icons.account_balance_wallet_outlined),
              _getDrawerItem(7, "Rider Review", Icons.delivery_dining),
              // _getDrawerItem(10, DAILY_COLLECTION, Icons.account_balance_wallet_outlined),
              _getDrawerItem(12, TRANSACTION, Icons.compare_arrows_sharp),
              // _getDrawerItem(5, NOTIFICATION, Icons.notifications_outlined),
              onOf == true
                  ? ListTile(
                      leading: Icon(Icons.send),
                      title: Text("Off / On"),
                      trailing: Switch(
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          inactiveTrackColor: Colors.red,
                          value: onOf,
                          onChanged: (val) {
                            setState(() {
                              onOf = val;
                              //deliStatus();
                              openClose();
                            });
                          }),
                    )
                  : SizedBox(),

              _getDivider(),
              _getDrawerItem(8, PRIVACY, Icons.lock_outline),
              _getDrawerItem(9, TERM, Icons.speaker_notes_outlined),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDivider(),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDrawerItem(11, LOGOUT, Icons.input),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getHeader() {
    return InkWell(
      child: Container(
        decoration: back(),
        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CUR_USERNAME!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: white, fontWeight: FontWeight.bold),
                    ),
                    Text("$WALLET_BAL: ${CUR_CURRENCY!}$CUR_BALANCE",
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: white)),
                    Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(EDIT_PROFILE_LBL,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: white)),
                            const Icon(
                              Icons.arrow_right_outlined,
                              color: white,
                              size: 20,
                            ),
                          ],
                        ))
                  ],
                )),
            Spacer(),
            // Container(
            //   margin: const EdgeInsets.only(top: 20, right: 20),
            //   height: 64,
            //   width: 64,
            //   decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       border: Border.all(width: 1.0, color: white)),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(100.0),
            //     child: imagePlaceHolder(62),
            //   ),
            // ),
          ],
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(),
            ));

        setState(() {});
      },
    );
  }

  Widget _getDivider() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Divider(
        height: 1,
      ),
    );
  }

  Widget _getDrawerItem(int index, String title, IconData icn) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          gradient: curDrwSel == index
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                      secondary.withOpacity(0.2),
                      primary.withOpacity(0.2)
                    ],
                  stops: [
                      0,
                      1
                    ])
              : null,
          // color: curDrwSel == index ? primary.withOpacity(0.2) : Colors.transparent,

          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          )),
      child: ListTile(
        dense: true,
        leading: Icon(
          icn,
          color: curDrwSel == index ? primary : lightBlack2,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: curDrwSel == index ? primary : lightBlack2, fontSize: 15),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (title == HOME_LBL) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
          } else if (title == NOTIFICATION) {
            setState(() {
              curDrwSel = index;
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationList(),
                ));
          } else if (title == LOGOUT) {
            logOutDailog();
          } else if (title == PRIVACY) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy(
                    title: PRIVACY,
                  ),
                ));
          } else if (title == "Rider Review") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ReviewScreen()));
          } else if (title == "Delivery Charges") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AllDeliveryCharge()));
          } else if (title == "Bank Detail") {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => BankDetail()));
          } else if (title == TERM) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy(
                    title: TERM,
                  ),
                ));
          } else if (title == DAILY_COLLECTION) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DailyCollection()));
          } else if (title == TRANSACTION) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TransactionDetails()));
          } else if (title == WALLET) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletHistory(),
                ));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _refresh() {
    print('_____________________');
    offset = 0;
    total = 0;
    orderList.clear();
    getUserDetail();
    getCurrentLoc();
    setState(() {
      _isLoading = true;
      isLoadingItems = false;
    });
    orderList.clear();
    return getOrder();
  }

  logOutDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Text(
                LOGOUTTXT,
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      LOGOUTNO,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                    child: Text(
                      LOGOUTYES,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      clearUserSession();
                      logoutButton();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Login()),
                          (Route<dynamic> route) => false);
                    })
              ],
            );
          });
        });
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
                  getOrder();
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

  Future<Null> getOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (offset == 0) {
        orderList = [];
      }
      try {
        CUR_USERID = await getPrefrence(ID);
        CUR_USERNAME = await getPrefrence(USERNAME);

        var parameter = {
          USER_ID: CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString()
        };
        if (activeStatus != null) {
          if (activeStatus == awaitingPayment) activeStatus = "awaiting";
          parameter[ACTIVE_STATUS] = activeStatus;
        }
        print("working here now ${getOrdersApi} and ${parameter}");
        Response response =
            await post(getOrdersApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        total = int.parse(getdata["total"]);
        if (!error) {
          if (offset! < total!) {
            tempList.clear();
            var data = getdata["data"];
            tempList = (data as List)
                .map((data) => Order_Model.fromJson(data))
                .toList();
            orderList.addAll(tempList);
            offset = offset! + perPage;
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
            isLoadingItems = false;
          });
      } on TimeoutException catch (_) {
        // setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
          isLoadingItems = false;
        });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
          isLoadingItems = false;
        });
    }

    return null;
  }

  Future<Null> getUserDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {ID: CUR_USERID};

        print("checking here now sfss  ${parameter} and ${getBoyDetailApi}");
        Response response =
            await post(getBoyDetailApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"][0];
          onOf = data["online"] == "1" ? true : false;
          print(data);
          cashCollection = data['cash_received'];
          print("checking cash collection data here  ${cashCollection}");
          CUR_BALANCE = double.parse(data[BALANCE]).toStringAsFixed(2);
          CUR_BONUS = data[BONUS];
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        // setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
    }

    return null;
  }

  Future<Null> deliStatus() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {ID: CUR_USERID, "online": onOf ? "0" : "1"};

        Response response =
            await post(getUpdateUserApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          print("success");
          var data = getdata["data"][0];
          onOf = data["online"] == "1" ? true : false;
          print(data);
          CUR_BALANCE = double.parse(data[BALANCE]).toStringAsFixed(2);
          CUR_BONUS = data[BONUS];
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        //   setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
    }

    return null;
  }

  openClose() async {
    var headers = {
      'Cookie': 'ci_session=f02741f77bb53eeaf1a6be0a045cb6f11b68f1a6'
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}update_online'));
    request.fields
        .addAll({'id': '${CUR_USERID}', 'open_close_status': onOf ? "1" : "0"});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  setLatLongApi({String? lat, String? long, String? city, String? address} ) async{
    var headers = {
      'Cookie': 'ci_session=f02741f77bb53eeaf1a6be0a045cb6f11b68f1a6'
    };
    var request =
    http.MultipartRequest('POST', Uri.parse('${baseUrl}update_location'));
    request.fields
        .addAll({'address': address ?? '', 'city': city ??'', 'latitude': lat ?? '', 'longitude': long ?? '', 'user_id': '${CUR_USERID}'});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    print('___________${request.fields}__________');
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
    print(response.reasonPhrase);
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

  Widget orderItem(int index) {
    Order_Model model = orderList[index];
    print('___________${model.itemList![0].status}__________');
    Color back;

    if ((model.itemList![0].status!) == DELIVERD)
      back = Colors.green;
    else if ((model.itemList![0].status!) == SHIPED)
      back = Colors.orange;
    else if ((model.itemList![0].status!) == CANCLED ||
        model.itemList![0].status! == RETURNED)
      back = Colors.red;
    else if ((model.itemList![0].status!) == PROCESSED)
      back = Colors.indigo;
    else if (model.itemList![0].status! == WAITING)
      back = Colors.black;
    else
      back = Colors.cyan;

    return model.itemList!.isNotEmpty
        ? Card(
            elevation: 0,
            margin: const EdgeInsets.all(5.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Order No.${model.id!}"),
                              const Spacer(),
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    color: back,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4.0))),
                                child: model.itemList![0].status == "shipped"
                                    ? Text(
                                        "Picked Up",
                                        style: const TextStyle(color: white),
                                      )
                                    : model.itemList![0].status == "processed"
                                        ? Text("Preparing")
                                        : model.itemList![0].status == "" ? SizedBox() : Text(
                                            capitalize(model.itemList![0].status.toString()),
                                            style: const TextStyle(color: white),
                                          ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, size: 14),
                                    Expanded(
                                      child: Text(
                                        model.name != null && model.name!.isNotEmpty
                                            ? " ${capitalize(model.name!)}"
                                            : " ",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              model.itemList?[0].status == 'delivered' ? SizedBox():  InkWell(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.call,
                                      size: 14,
                                      color: fontColor,
                                    ),
                                Text(
                                      " ${model.mobile!}",
                                      style: const TextStyle(
                                          color: fontColor,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _launchCaller(index);
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.money, size: 14),
                                  Text("Payable: ${CUR_CURRENCY!} ${model.payable!}"),
                                ],
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.payment, size: 14),
                                  Text(" ${model.payMethod!}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range, size: 14),
                              Text(" Order on: ${model.orderDate!}"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.watch_later_outlined, size: 14),
                              Text(" Order Time: ${model.orderTime!}"),
                            ],
                          ),
                        ),
                        model.itemList?[0].status == 'canceled' ? SizedBox()  :   model.itemList![0].accept_reject_driver == "0" && model.itemList?[0].status != 'canceled' && model.itemList?[0].status != 'delivered'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MaterialButton(
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2.5,
                                    shape: RoundedRectangleBorder(),
                                    onPressed: () {
                                      updateOrderStatus("1", "${model.id}");
                                    },
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    color: Colors.green,
                                  ),
                                  MaterialButton(
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2.5,
                                    onPressed: () {
                                      updateOrderStatus("2", "${model.id}");
                                    },
                                    child: Text(
                                      "Reject",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    color: Colors.red,
                                  ),
                                ],
                              )
                            :model.itemList?[0].status == 'delivered' ? SizedBox() :
                        model.itemList![0].accept_reject_driver == "1"
                                ? MaterialButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Accepted",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    color: Colors.green,
                                    minWidth: MediaQuery.of(context).size.width,
                                  )
                                : model.itemList![0].accept_reject_driver == "2" ? MaterialButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Rejected",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    color: Colors.red,
                                    minWidth: MediaQuery.of(context).size.width,
                                  ) : MaterialButton(
                          onPressed: () {},
                          child: Text(
                            "Delivered",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                          color: Colors.green,
                          minWidth: MediaQuery.of(context).size.width,
                        )

                        // model.deliveryTime != "" ? Padding(
                        //   padding:
                        //   const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                        //   child: Row(
                        //     children: [
                        //       const Icon(Icons.assignment_turned_in, size: 14),
                        //       Text(" Delivered Time: ${model.deliveryTime}"),
                        //     ],
                        //   ),
                        // ) : SizedBox(),
                      ])),
              onTap: model.itemList![0].accept_reject_driver == "1" ?  () async {
              var isResult =   await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrderDetail(model: orderList[index])),
                );
                setState(() {
                  /* _isLoading = true;
             total=0;
             offset=0;
orderList.clear();*/
                  getUserDetail();
                  getOrder();
                });
                // getOrder();
              } : () {},
            ),
          )
        : Container();
  }

  _launchCaller(index) async {
    var url = "tel:${orderList[index].mobile}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _detailHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () {
              // getOrder();
              _refresh();
            },
            child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        color: fontColor,
                      ),
                      Text(ORDER),
                      Text(
                        total.toString(),
                        style: const TextStyle(
                            color: fontColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )),
          ),
        ),


      ],
    );
  }

  _detailHeader2() {
    return Row(
      children: [
        // Expanded(
        //   flex: 2,
        //   child: Card(
        //     elevation: 0,
        //     child: Padding(
        //       padding: const EdgeInsets.all(18.0),
        //       child: Column(
        //         children: [
        //           const Icon(
        //             Icons.wallet_giftcard,
        //             color: fontColor,
        //           ),
        //           const Text(BONUS_LBL),
        //           Text(
        //             CUR_BONUS!,
        //             style: const TextStyle(
        //                 color: fontColor, fontWeight: FontWeight.bold),
        //           )
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () async {
              bool result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CashCollection(
                            cashValue: cashCollection,
                          )));

              if (result == true) {
                _refresh();
              }
            },
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.wallet_giftcard,
                      color: fontColor,
                    ),
                    const Text("Cash Collection"),
                    cashCollection == "" || cashCollection == null
                        ? Text("0")
                        : Text(
                            "${cashCollection}",
                            style: const TextStyle(
                                color: fontColor, fontWeight: FontWeight.bold),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter = {TYPE: CURRENCY};

      Response response =
          await post(getSettingApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          CUR_CURRENCY = getdata["currency"];
        } else {
          setSnackbar(msg!);
        }
      }
    } on TimeoutException catch (_) {
      // setSnackbar(somethingMSg);
    }
  }
}
