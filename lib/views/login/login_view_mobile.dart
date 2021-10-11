import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:indiajobin/views/PaymentRazorPay/payment_view_mobile.dart';
import 'package:indiajobin/views/forgot_password/forgot_password_mobile.dart';
import 'package:indiajobin/views/jobList/joblist_view_mobile.dart';
import 'package:indiajobin/views/register/register_view_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indiajobin/views/routes_and_apis/all_apis.dart' as globals;

void showAlertDia(
    BuildContext context, String dialogueTitle, String dialogueContent) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(dialogueTitle),
        content: Text(dialogueContent),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailPortraitCon = TextEditingController();
  final TextEditingController passwordPortraitCon = TextEditingController();
  String email, password;
  bool loginCompleted = false;
  bool autoValidation = false;
  var paymentSuccessful = false;
  bool isLoading = false;
  var connectivityResult;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  String smsCode;
  String verificationCode;
  String verificationId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Color(0xfff2f3f7),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(70),
                      bottomRight: const Radius.circular(70),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildLogo(),
                  _buildContainer(),
                  _buildSignUpBtn(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Image.asset(
              "assets/icons/app_logo.png",
              height: MediaQuery.of(context).size.height / 4,
              alignment: Alignment.center,
            ))
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Form(
              // ignore: deprecated_member_use
              autovalidate: autoValidation,
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.height / 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEmailRow(),
                    _buildPasswordRow(),
                    _buildForgetPasswordButton(),
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))
          ],
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            email = value;
          },
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email,
                color: mainColor,
              ),
              labelText: 'E-mail'),
          controller: emailPortraitCon,
          validator: MultiValidator([
            RequiredValidator(errorText: 'Email required*'),
            EmailValidator(errorText: 'Enter valid email')
          ])),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        onChanged: (value) {
          password = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: mainColor,
          ),
          labelText: 'Password',
        ),
        controller: passwordPortraitCon,
        validator: RequiredValidator(errorText: "Password required*"),
      ),
    );
  }

  Widget _buildForgetPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          onPressed: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ForgetPasswordView()));
          },
          child: Text("Forgot Password?"),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        isLoading == true
            ? Padding(
                padding: const EdgeInsets.all(25.0),
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Container(
                    height: 1.4 * (MediaQuery.of(context).size.height / 20),
                    width: 5 * (MediaQuery.of(context).size.width / 10),
                    margin: EdgeInsets.only(bottom: 20, top: 20.0),
                    child: RaisedButton(
                      elevation: 5.0,
                      color: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if ((connectivityResult ==
                                  ConnectivityResult.mobile) ||
                              (connectivityResult == ConnectivityResult.wifi)) {
                            if (await DataConnectionChecker().hasConnection) {
                              setState(() => isLoading = true);
                              loginUser();
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'No internet available');
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: 'No internet available');
                          }
                        } else {
                          setState(() => isLoading = false);
                          autoValidation = true;
                          showAlertDia(context, "Authentication Failed",
                              "Please enter email and password");
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: MediaQuery.of(context).size.height / 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 25)
                ],
              )
      ],
    );
  }

  loginUser() async {
    Fluttertoast.showToast(msg: 'Logging in...');
    final String userEmail = emailPortraitCon.text;
    final String userPassword = passwordPortraitCon.text;
    String completeLoginApi =
        globals.login + "?email=" + userEmail + "&password=" + userPassword;
    String loginResponseFromServer;
    http.Response response = await http.get(completeLoginApi);
    loginResponseFromServer = response.body;

    var jsonParseLogin = json.decode(loginResponseFromServer);
    String errorMesage = jsonParseLogin['error'];
    try {
      if (response.statusCode == 200 && response.body != null) {
        // String msgFromServer = jsonParseLogin['email'];
        if (errorMesage == 'true') {
          String invalidEmailMessage = jsonParseLogin['msg'];
          showAlertDia(context, "Authentication Failed", invalidEmailMessage);
          setState(() {
            isLoading = false;
          });
        } else {
          loginCompleted = true;
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setBool("userLogin", loginCompleted);
          var firstName = jsonParseLogin['other_details']['firstname'];
          preferences.setString("userPassword", userPassword);
          var lastName = jsonParseLogin['other_details']['lastname'];
          var fname = firstName.toString().trimRight();
          var lname = lastName.toString().trimRight();
          var userName = fname + " " + lname;
          var studentId = jsonParseLogin['other_details']['id'];
          var paymentCompleted = jsonParseLogin['other_details']['validated'];
          var userMobile = jsonParseLogin['other_details']['mobile'];

          var userToken = jsonParseLogin['token'];
          preferences.setString("userEmail", userEmail);
          preferences.setString("studentId", studentId);
          preferences.setString("userName", userName);
          preferences.setString("userToken", userToken);
          preferences.setString("userMobile", userMobile);
          switch (paymentCompleted) {
            case '1':
              {
                paymentSuccessful = true;
                preferences.setBool("userPayment", paymentSuccessful);
                preferences.setString("userLoginEmail", userEmail);
                preferences.setBool("userRegistration", false);
                preferences.setInt("paymentStatus", 1);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => JobListView()));
              }

              break;
            case '-1':
              {
                checkRemainingDays(userEmail, userToken);
              }
              break;
            default:
              {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PaymentView()));
              }
          }
          // if (paymentCompleted != '0') {
          //   paymentSuccessful = true;
          //   preferences.setBool("userPayment", paymentSuccessful);
          //   preferences.setString("userLoginEmail", userEmail);
          //   preferences.setBool("userRegistration", false);
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (context) => JobListView()));
          // } else {
          //   setState(() {
          //     isLoading = false;
          //   });
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (context) => PaymentView()));
          // }
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  checkRemainingDays(userEmail, userToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String freeTrial = globals.oneMonthFree;
    Map orderBody = {'email': userEmail};
    try {
      final http.Response response = await http.post(freeTrial,
          headers: <String, String>{'token': userToken},
          body: jsonEncode(orderBody));
      final freeTrialDecoded = jsonDecode(response.body);
      var daysRemaining = freeTrialDecoded['days_remaining'];
      
      if (daysRemaining == 0) {
        preferences.setBool("userPayment", false);
        setState(() => isLoading = false);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => PaymentView()));
      } else {
        setState(() => isLoading = false);
        preferences.setBool("userPayment", true);
        preferences.setInt("paymentStatus", -1);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => JobListView()));
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Something went wrong.");
    }
  }

  Widget _buildSignUpBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: FlatButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterView(),
                  ));
            },
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Dont have an account? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
