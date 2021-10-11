import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indiajobin/views/profile_detail/profile_view_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:indiajobin/views/routes_and_apis/all_apis.dart' as apis;
import 'package:http/http.dart' as http;


class PaymentView extends StatefulWidget {
  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  var connectivityResult;
  var userEmail;
  var userToken;
  bool freeTrialLoading = false;
  bool isInternetAvailable = false;

  Future<void> checkInternet() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      if (await DataConnectionChecker().hasConnection) {
        isInternetAvailable = true;
        setState(() => freeTrialLoading = true);
        applyFreeTrial();
      } else {
        isInternetAvailable = false;
        Fluttertoast.showToast(msg: 'No internet available');
      }
    } else {
      isInternetAvailable = false;
      Fluttertoast.showToast(msg: 'No internet available');
    }
  }

  applyFreeTrial() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userEmail = preferences.getString("userEmail");
    userToken = preferences.getString("userToken");
    String freeTrial = apis.oneMonthFree;
    Map orderBody = {'email': userEmail};
    try {
      final http.Response response = await http.post(freeTrial,
          headers: <String, String>{'token': userToken},
          body: jsonEncode(orderBody));
      final freeTrialDecoded = jsonDecode(response.body);
      var freeTrialMsg = freeTrialDecoded['msg'];
      // var error = freeTrialDecoded['error'];
      Fluttertoast.showToast(msg: freeTrialMsg);
      setState(() => freeTrialLoading = false);
      preferences.setBool("userPayment", true);
      preferences.setInt("paymentStatus", -1);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => ProfileView()));
    } catch (e) {
      setState(() => freeTrialLoading = false);
      Fluttertoast.showToast(msg: "Something went wrong.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [mainColor, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.5, 0.4],
        )),
        child: Scaffold(
            resizeToAvoidBottomPadding: true,
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Payment',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50.0,
                              ),
                              Center(
                                child: Text(
                                  'Pick up the best choice for you !',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              HomePagePortrait(),
                              SizedBox(
                                height: 20,
                              ),
                              _buildTryForFreeButton()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildTryForFreeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.2 * (MediaQuery.of(context).size.height / 20),
          //width: 4.5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 20, top: 20.0),

          child: freeTrialLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : RaisedButton(
                  elevation: 4.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: mainColor)),
                  onPressed: () {
                    checkInternet();
                    // userInfo.deleteUserInfo(context);

                    //this is the trial period...
                  },
                  child: Text(
                    "Try free for a month",
                    style: TextStyle(
                        color: mainColor,
                        letterSpacing: 0.6,
                        fontSize: MediaQuery.of(context).size.height / 40,
                        fontWeight: FontWeight.w700),
                  ),
                ),
        )
      ],
    );
  }
}

class HomePagePortrait extends StatefulWidget {
  @override
  _HomePagePortraitState createState() => _HomePagePortraitState();
}

class _HomePagePortraitState extends State<HomePagePortrait> {
  final double _borderRadius = 24;
  bool paymentSuccess = false;
  int totalAmount = 0;
  var connectivityResult;
  Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = new Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  var orderId, slabId;
  bool isLoadingOne = false, isLoadingTwo = false, isLoadingThree = false;

  generateOrderId() async {
    var amount = totalAmount;
    var token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString("userToken");
    String orderIdUrl = apis.createOrderId;

    var orderBody = new Map<String, dynamic>();
    orderBody['amount'] = amount.toString();
    String finalOrderId;
    try {
      final http.Response response = await http.post(orderIdUrl,
          headers: <String, String>{'token': token}, body: orderBody);
      final decoded = jsonDecode(response.body);
      orderId = decoded['order_id'];
      slabId = decoded['slab_id'];
      finalOrderId = orderId;
      openCheckout(finalOrderId);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong.');
    }

    return finalOrderId;
  }

  void openCheckout(String createdOrderId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String email = preferences.getString("userEmail");
    String mobile = preferences.getString("userMobile");
    var options = {
      'key': 'rzp_test_Q59IYlKr35mxgu',
      'amount': totalAmount * 100,
      'name': 'India JobIn',
      'order_id': createdOrderId,
      'description': 'India JobIn membership payment',
      'prefill': {'contact': mobile, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(
      PaymentSuccessResponse paymentSucessResponse) async {
    Fluttertoast.showToast(msg: 'Processing payment');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String seekerId = preferences.getString("studentId");
    var token = preferences.getString("userToken");
    paymentSuccess = true;

    var razorPaymentId = paymentSucessResponse.paymentId,
        razorOrderId = paymentSucessResponse.orderId,
        razorSignature = paymentSucessResponse.signature;
    var rid = razorOrderId.trimRight(),
        rpid = razorPaymentId.trimRight(),
        rsign = razorSignature.trimRight();

    String saveOrderUrl = apis.saveOrder;
    Map saveOrderBody = new Map<String, dynamic>();
    saveOrderBody['seeker_id'] = seekerId;
    saveOrderBody['slab_id'] = slabId;
    saveOrderBody['razorpay_order_id'] = rid;
    saveOrderBody['razorpay_payment_id'] = rpid;
    saveOrderBody['razorpay_signature'] = rsign;
    saveOrderBody['order_id'] = rid;
    var errorfromSaveOrder;
    try {
      final http.Response saveOrderResponse = await http.post(saveOrderUrl,
          headers: <String, String>{'token': token}, body: saveOrderBody);
      var jsondecoded = json.decode(saveOrderResponse.body);
      errorfromSaveOrder = jsondecoded['error'];
    } catch (e) {
      setState(() {
        isLoadingOne = false;
        isLoadingTwo = false;
        isLoadingThree = false;
      });
      Fluttertoast.showToast(msg: "something went wrong");
    }
    if (errorfromSaveOrder == false) {
      preferences.setBool("userPayment", paymentSuccess);
      preferences.setInt("paymentStatus", 1);
      setState(() {
        isLoadingOne = false;
        isLoadingTwo = false;
        isLoadingThree = false;
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => ProfileView()));
      Fluttertoast.showToast(msg: 'Payment Successful');
    } else {
      Fluttertoast.showToast(msg: 'Payment Unsuccessful');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isLoadingOne = false;
      isLoadingTwo = false;
      isLoadingThree = false;
    });
    Fluttertoast.showToast(msg: 'ERROR :  ' + response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: 'EXTERNAL WALLET' + response.walletName);
  }

  Future<void> checkInternet(totalAmount) async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      if (await DataConnectionChecker().hasConnection) {
        generateOrderId();
      } else {
        setState(() {
          isLoadingOne = false;
          isLoadingTwo = false;
          isLoadingThree = false;
        });
        Fluttertoast.showToast(msg: 'No internet available');
      }
    } else {
      setState(() {
        isLoadingOne = false;
        isLoadingTwo = false;
        isLoadingThree = false;
      });
      Fluttertoast.showToast(msg: 'No internet available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_borderRadius),
                    gradient: LinearGradient(
                        colors: [mainColor, Color(0xff1B3BA0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: CustomPaint(
                    size: Size(100, 150),
                    painter: CustomCardShapePainter(
                        _borderRadius,
                        mainColor.withOpacity(0.4),
                        Color(0xff1B3BA0).withOpacity(0.4)),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'For 1 Year',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 16),
                            Flexible(
                              child: Text(
                                '\u{20B9}${200}',
                                style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.white,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            isLoadingOne == true
                                ? CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white))
                                : CircleAvatar(
                                    backgroundColor: Colors.grey[100],
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          color: Colors.black),
                                      onPressed: () {
                                        totalAmount = 200;
                                        setState(() => isLoadingOne = true);
                                        checkInternet(totalAmount);
                                      },
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_borderRadius),
                    gradient: LinearGradient(
                        colors: [mainColor, Color(0xff19208C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff19208C),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: CustomPaint(
                    size: Size(100, 150),
                    painter: CustomCardShapePainter(
                        _borderRadius,
                        mainColor.withOpacity(0.4),
                        Color(0xff19208C).withOpacity(0.4)),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'For 2 Years',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 16),
                            Flexible(
                              child: Text(
                                '\u{20B9}${350}',
                                style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white,
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            isLoadingTwo == true
                                ? CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white))
                                : CircleAvatar(
                                    backgroundColor: Colors.grey[100],
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          color: Colors.black),
                                      onPressed: () {
                                        setState(() => isLoadingTwo = true);
                                        totalAmount = 350;
                                        checkInternet(totalAmount);
                                      },
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_borderRadius),
                    gradient: LinearGradient(
                        colors: [mainColor, Color(0xff150578)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff150578),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: CustomPaint(
                    size: Size(100, 150),
                    painter: CustomCardShapePainter(
                        _borderRadius,
                        mainColor.withOpacity(0.4),
                        Color(0xff150578).withOpacity(0.4)),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'For 3 Years',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 16),
                            Flexible(
                              child: Text(
                                '\u{20B9}${500}',
                                style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.white,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            isLoadingThree == true
                                ? CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white))
                                : CircleAvatar(
                                    backgroundColor: Colors.grey[100],
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          color: Colors.black),
                                      onPressed: () {
                                        setState(() => isLoadingThree = true);
                                        totalAmount = 500;
                                        checkInternet(totalAmount);
                                        // generateOrderId();
                                      },
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomCardShapePainter extends CustomPainter {
  final double radius;
  final Color startColor;
  final Color endColor;

  CustomCardShapePainter(this.radius, this.startColor, this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    var radius = 24.0;

    var paint = Paint();
    paint.shader = ui.Gradient.linear(
        Offset(0, 0), Offset(size.width, size.height), [
      HSLColor.fromColor(startColor).withLightness(0.8).toColor(),
      endColor
    ]);

    var path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, radius)
      ..quadraticBezierTo(size.width, 0, size.width - radius, 0)
      ..lineTo(size.width - 1.5 * radius, 0)
      ..quadraticBezierTo(-radius, 2 * radius, 0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
