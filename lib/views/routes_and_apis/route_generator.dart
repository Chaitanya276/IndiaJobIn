library my_prj.globals;

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:indiajobin/views/login/login_view_mobile.dart';
import 'package:indiajobin/views/routes_and_apis/all_apis.dart' as apis;
import 'package:shared_preferences/shared_preferences.dart';

deleteUserInfo(BuildContext context) async {
  var connectivityResult;

  connectivityResult = await (Connectivity().checkConnectivity());
  if ((connectivityResult == ConnectivityResult.mobile) ||
      (connectivityResult == ConnectivityResult.wifi)) {
    if (await DataConnectionChecker().hasConnection) {
      FirebaseAuth _auth = FirebaseAuth.instance;
      _auth.signOut();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString("userToken");
      String logoutUser = apis.logout;
      http.Response response = await http
          .post(logoutUser, headers: <String, String>{"token": token});
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "logging out...");
        await preferences.remove("userLogin");
        await preferences.remove("userRegistration");
        await preferences.remove("userPayment");
        await preferences.remove("paymentStatus");
        await preferences.remove("userEmail");
        await preferences.remove("userToken");
        await preferences.remove("userMobile");
        await preferences.remove("studentId");
        await preferences.remove("userName");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginView(),
          ),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: "Something went wrong.");
      }
    } else {
      Fluttertoast.showToast(msg: 'No internet available');
    }
  } else {
    Fluttertoast.showToast(msg: 'No internet available');
  }
}

class UserStatus extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<UserStatus> {
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  loadUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var registrationCompleted, paymentCompleted;
    // ignore: unused_local_variable
    var loginCompleted = preferences.getBool("userLogin");
    registrationCompleted = preferences.getBool("userRegistration");
    paymentCompleted = preferences.getBool("userPayment");
    // var studentId = preferences.getString("studentId");

    if ((registrationCompleted == true && paymentCompleted == true) ||
        (loginCompleted = true && paymentCompleted == true)) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/splashPage', ModalRoute.withName('/splashPage'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
