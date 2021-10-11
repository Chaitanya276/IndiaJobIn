import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:indiajobin/views/PaymentRazorPay/payment_view_mobile.dart';
import 'package:indiajobin/views/login/login_view_mobile.dart';
import 'dart:convert';
import 'package:indiajobin/widgets/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indiajobin/views/routes_and_apis/all_apis.dart' as globals;
import 'package:firebase_auth/firebase_auth.dart';

bool isLoading = false;

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
              isLoading = false;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

String userTokenPassing;
String userEmailPassing;

// ignore: must_be_immutable
class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController firstnameCon = TextEditingController();
  final TextEditingController lastnameCon = TextEditingController();
  final TextEditingController emailCon = TextEditingController();
  final TextEditingController mobileCon = TextEditingController();
  final TextEditingController passwordCon = TextEditingController();
  final TextEditingController confirmPasswordCon = TextEditingController();
  final TextEditingController refferedByCon = TextEditingController();

  bool registrationCompleted = false;
  final _formKey = GlobalKey<FormState>();
  bool _autovalidation = false;

  var connectivityResult;
  bool isPhoneVerified = false;
  Future isInternet() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      if (await DataConnectionChecker().hasConnection) {
      } else {
        Fluttertoast.showToast(msg: 'No internet available');
      }
    } else {
      Fluttertoast.showToast(msg: 'No internet available');
    }
  }

  @override
  void initState() {
    super.initState();
    isInternet();
  }

  String smsOTP;
  var smsVerificationCompleted = false;
  String verificationCode;
  bool wrongOtpEntered = false;
  var attempRemaining = 3;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String deviceId;
  String enteredMobileNo;

  Future verifyPhone(phoneNo) async {
    Future<bool> smsOTPDialog(BuildContext context) {
      setState(() {
        attempRemaining = 3;
        isLoading = false;
        isPhoneVerified = false;
      });

      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter OTP'),
                  SizedBox(height: 5.0),
                ],
              ),
              content: Container(
                height: 85,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide:
                                new BorderSide(color: Colors.blue[800])),
                        hintText: 'Enter OTP',
                        // helperText: 'Attempts remaining : $attempRemaining',
                        labelText: 'Enter correct OTP',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        this.smsOTP = value;
                      },
                    ),
                  ),
                ]),
              ),
              contentPadding: EdgeInsets.all(10),
              actions: <Widget>[
                Center(
                  child: RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: mainColor)),
                    onPressed: () async {
                      if ((smsOTP == "") || (smsOTP == null)) {
                        Fluttertoast.showToast(
                            msg: "ENTER OTP", gravity: ToastGravity.CENTER);
                      } else {
                        _auth.currentUser().then((user) async {
                          try {
                            final AuthCredential credential =
                                PhoneAuthProvider.getCredential(
                              verificationId: verificationCode,
                              smsCode: smsOTP,
                            );
                            AuthResult user =
                                await _auth.signInWithCredential(credential);
                            FirebaseUser currentUser =
                                await _auth.currentUser();
                            assert(user.user.uid == currentUser.uid);
                            deviceId = user.user.uid;
                            setState(() {
                              isLoading = false;
                              isPhoneVerified = true;
                            });
                            Navigator.of(context).pop();
                            enteredMobileNo = phoneNo;
                            registerUser();
                          } catch (e) {
                            setState(() {
                              this.attempRemaining = --attempRemaining;
                            });
                            if (attempRemaining <= 0) {
                              Navigator.of(context).pop();
                              Fluttertoast.showToast(
                                  msg:
                                      'You have exceeded your attempts. \n Please verify your mobile no. again.',
                                  gravity: ToastGravity.CENTER,
                                  toastLength: Toast.LENGTH_LONG);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      'Wrong OTP entered. \n $attempRemaining attempt remaining ',
                                  gravity: ToastGravity.CENTER);
                            }
                          }
                        });
                      }
                    },
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: mainColor,
                        letterSpacing: 1.2,
                        fontSize: MediaQuery.of(context).size.height / 60,
                      ),
                    ),
                  ),
                )
              ],
            );
          });
    }

    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationCode = verId;
      smsOTPDialog(context).then((value) {});
    };

    phoneNo = '+91' + phoneNo;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (AuthCredential phoneAuthCredential) async {},
        verificationFailed: (AuthException exception) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Try entering different mobile no.",
              gravity: ToastGravity.CENTER);
        },
        codeSent: smsOTPSent,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationCode = verId;
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomPadding: true,
          backgroundColor: Color(0xfff2f3f7),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 1.5,
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
                        _buildLogInBtn(),
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "assets/icons/app_logo.png",
          height: MediaQuery.of(context).size.height / 5,
          alignment: Alignment.center,
        )
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
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Form(
              // ignore: deprecated_member_use
              autovalidate: _autovalidation,
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.height / 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildFirstNameRow(),
                    _buildLastNameRow(),
                    _buildMobNoRow(),
                    _buildEmailRow(),
                    _buildPasswordRow(),
                    _buildConfirmPasswordRow(),
                    _buildReffereId(),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstNameRow() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: mainColor,
            ),
            labelText: 'Firstname*'),
        controller: firstnameCon,
        validator: RequiredValidator(errorText: 'Firstname required'),
      ),
    );
  }

  Widget _buildReffereId() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: mainColor,
            ),
            labelText: 'Reffer token'),
        controller: refferedByCon,
      ),
    );
  }

  Widget _buildLastNameRow() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: mainColor,
            ),
            labelText: 'Lastname*'),
        controller: lastnameCon,
        validator: RequiredValidator(errorText: "Lastname required"),
      ),
    );
  }

  Widget _buildMobNoRow() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.mobile_screen_share,
              color: mainColor,
            ),
            labelText: 'Mobile Number*'),
        controller: mobileCon,
        validator: MultiValidator([
          RequiredValidator(errorText: "Mobile no. required"),
          MinLengthValidator(10, errorText: 'Should be 10 digits'),
          MaxLengthValidator(10, errorText: "Should be 10 digits")
        ]),
        onChanged: (changeMobile) {
          changeMobile = "+91" + changeMobile;
          if (changeMobile == enteredMobileNo) {
            setState(() {
              isPhoneVerified = true;
            });
          } else {
            setState(() {
              isPhoneVerified = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))
          ],
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email,
                color: mainColor,
              ),
              labelText: 'E-mail*'),
          controller: emailCon,
          validator: MultiValidator([
            RequiredValidator(errorText: 'Email required'),
            EmailValidator(errorText: 'Enter valid email')
          ])),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: mainColor,
          ),
          labelText: 'Password*',
        ),
        controller: passwordCon,
        validator: MinLengthValidator(6,
            errorText: "Password should be min 6 characters"),
      ),
    );
  }

  Widget _buildConfirmPasswordRow() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: mainColor,
          ),
          labelText: 'Confirm password*',
        ),
        controller: confirmPasswordCon,
        validator: MinLengthValidator(6,
            errorText: "Password should be min 6 characters"),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        isLoading == true
            ? Padding(
                padding: const EdgeInsets.all(42.0),
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: 1.4 * (MediaQuery.of(context).size.height / 21.5),
                  width: isPhoneVerified == false
                      ? 5 * (MediaQuery.of(context).size.width / 13)
                      : 5 * (MediaQuery.of(context).size.width / 10),
                  margin: EdgeInsets.only(bottom: 20, top: 20.0),
                  child: RaisedButton(
                    elevation: 5.0,
                    color: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () async {
                      registerUser();
                    },
                    child: isPhoneVerified
                        ? Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontSize: MediaQuery.of(context).size.height / 32,
                            ),
                          )
                        : Text('Verify',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.3,
                              fontSize: MediaQuery.of(context).size.height / 32,
                            )),
                  ),
                ),
              )
      ],
    );
  }

  registerUser() async {
    if (_formKey.currentState.validate()) {
      final String ffname = firstnameCon.text;
      final String flname = lastnameCon.text;
      final String fmobile = mobileCon.text.trim();
      final String femail = emailCon.text;
      final String fpassword = passwordCon.text;
      final String fcpassword = confirmPasswordCon.text;
      final String fReffereBy = refferedByCon.text;

      if (ffname == null ||
          flname == null ||
          fmobile == null ||
          femail == null ||
          fpassword == null ||
          fcpassword == null) {
        _autovalidation = true;
        showAlertDia(
            context, "Registration Failed", "Please enter all the fields.");
      } else {
        if (fpassword == fcpassword) {
          connectivityResult = await (Connectivity().checkConnectivity());
          if ((connectivityResult == ConnectivityResult.mobile) ||
              (connectivityResult == ConnectivityResult.wifi)) {
            if (await DataConnectionChecker().hasConnection) {
              try {
                setState(() => isLoading = true);
                if (isPhoneVerified == false) {
                  Fluttertoast.showToast(msg: 'OTP sent to mobile no.');
                  verifyPhone(fmobile);
                } else {
                  final String registerApiUrl = globals.register;
                  Map rawBodyData;
                  if ((fReffereBy == null) || (fReffereBy == "")) {
                    rawBodyData = {
                      "firstname": ffname,
                      "lastname": flname,
                      "email": femail,
                      "mobile": fmobile,
                      "password": fpassword,
                      "device_id": deviceId
                    };
                  } else {
                    rawBodyData = {
                      "firstname": ffname,
                      "lastname": flname,
                      "email": femail,
                      "mobile": fmobile,
                      "password": fpassword,
                      "reffered_by": fReffereBy,
                      "device_id": deviceId
                    };
                  }
                  Fluttertoast.showToast(msg: 'Authenticating new user...');
                  var responseJsonFromServer;
                  try {
                    http.Response response = await http.post(
                      registerApiUrl,
                      headers: <String, String>{
                        "Content-Type": "application/json"
                      },
                      body: jsonEncode(rawBodyData),
                    );
                    responseJsonFromServer = response.body;
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Something went wrong");
                  }

                  var responseJsonParse = json.decode(responseJsonFromServer);

                  var registrationSucessMessage = responseJsonParse['msg'];
                  var enterUniqueEmail = responseJsonParse['email'];
                  if (registrationSucessMessage == null &&
                      enterUniqueEmail ==
                          "The email field must contain a unique value.") {
                    setState(() {
                      isLoading = false;
                    });
                    showAlertDia(context, "Registration Failed",
                        "Please enter a unique email");
                  } else if (registrationSucessMessage ==
                          "Seeker Registered Successfully" &&
                      enterUniqueEmail == null) {
                    String completeApi = globals.login;
                    String completeLoginApi = completeApi +
                        "?email=" +
                        femail +
                        "&password=" +
                        fpassword;
                    String loginResponseFromServer;
                    try {
                      http.Response response = await http.get(completeLoginApi);
                      loginResponseFromServer = response.body;
                    } catch (e) {
                      Fluttertoast.showToast(msg: "Something went wrong");
                    }

                    var jsonParseLogin = json.decode(loginResponseFromServer);
                    userTokenPassing = jsonParseLogin['token'];
                    userEmailPassing = jsonParseLogin['email'];
                    var studentId = jsonParseLogin['other_details']['id'];
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    preferences.setString("userToken", userTokenPassing);
                    preferences.setString("userEmail", userEmailPassing);
                    preferences.setString("studentId", studentId);
                    preferences.setString("firstName", ffname);
                    preferences.setString("userMobile", fmobile);
                    registrationCompleted = true;
                    preferences.setBool(
                        "userRegistration", registrationCompleted);
                    // try {
                    //   if (response.statusCode == 200 &&
                    //       response.body != null) {}
                    // } catch (e) {
                    //   Fluttertoast.showToast(msg: 'Something went wrong');
                    // }
                    isLoading = false;
                    preferences.setString("userPassword", fpassword);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentView(),
                        ));
                  }
                }
              } catch (e) {
                setState(() {
                  isPhoneVerified = false;
                  isLoading = false;
                });
                Fluttertoast.showToast(msg: 'Something went wrong');
              }
            } else {
              Fluttertoast.showToast(msg: 'No internet available');
            }
          } else {
            Fluttertoast.showToast(msg: 'No internet available');
          }
        } else {
          showAlertDia(context, "Password Authentication Failed",
              "Please check password and confirm password");
        }
      }
    } else {
      setState(() {
        _autovalidation = true;
      });
      showAlertDia(context, 'Validation Failed', 'Enter valid details');
    }
  }

  Widget _buildLogInBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: FlatButton(
            onPressed: () {
              setState(() {
                isLoading = false;
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginView(),
                  ));
            },
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Login',
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
