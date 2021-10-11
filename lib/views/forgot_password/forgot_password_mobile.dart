import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:indiajobin/views/login/login_view_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:indiajobin/views/routes_and_apis/all_apis.dart' as apis;
import 'package:shared_preferences/shared_preferences.dart';

String emailres;

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
              if (dialogueContent ==
                  "Sorry no account registered with this email address") {
                Navigator.of(context).pop();
              } else if (dialogueContent ==
                  "Your request was processed please check your mail for further details") {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginView()));
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

class ForgetPasswordView extends StatefulWidget {
  @override
  _ForgetPasswordViewState createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final TextEditingController emailForgotCon = TextEditingController();
  String email, forgotApi;
  bool loginCompleted = false;
  bool autoValidation = false;
  bool isLoading = false;
  var forgotBody;
  var connectivityResult;
  var forgotResponse, jsonDecoded;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

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
                height: MediaQuery.of(context).size.height * 0.6,
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
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Forgot Password ?",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEmailRow(),
                    _buildVerifyEmailButton(),
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
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20),
      child: TextFormField(
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
          controller: emailForgotCon,
          validator: MultiValidator([
            RequiredValidator(errorText: 'Email required*'),
            EmailValidator(errorText: 'Enter valid email')
          ])),
    );
  }

  Widget _buildVerifyEmailButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        isLoading == true
            ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: CircularProgressIndicator(),
              )
            : Column(
              children: [
                Container(
                    height: 1.4 * (MediaQuery.of(context).size.height / 20),
                    width: 5 * (MediaQuery.of(context).size.width / 10),
                    margin: EdgeInsets.only(bottom: 20, top: 60.0),
                    child: RaisedButton(
                      elevation: 5.0,
                      color: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPressed: () async {
                        var connectivityResult;

                        connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if ((connectivityResult == ConnectivityResult.mobile) ||
                            (connectivityResult == ConnectivityResult.wifi)) {
                          if (await DataConnectionChecker().hasConnection) {
                            if (formKey.currentState.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                forgotApi = apis.forgotPassword;
                                email = emailForgotCon.text;
                                forgotBody = {"email": email};
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                var token = preferences.getString("userToken");
                                http.Response response = await http.post(forgotApi,
                                    headers: <String, String>{"token": token},
                                    body: jsonEncode(forgotBody));
                                forgotResponse = response.body;
                                jsonDecoded = jsonDecode(forgotResponse);
                                
                                if (response.statusCode == 200) {
                                  forgotResponse = response.body;
                                  var error = jsonDecoded['error'];
                                  var msg = jsonDecoded['msg'];
                                  if (error == true) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    showAlertDia(
                                        context, "Authentication Failed", msg);
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    showAlertDia(
                                        context, "Authentication Successful", msg);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Something went wrong.');
                                }
                              }catch (e) {
                                Fluttertoast.showToast(msg: 'something went wrong');
                                setState(() => isLoading = false);
                              }
                            } else {
                              autoValidation = true;
                              showAlertDia(context, "Authentication Failed",
                                  "Please enter email");
                            }
                          } else {
                            Fluttertoast.showToast(msg: 'No internet available');
                          }
                        } else {
                          Fluttertoast.showToast(msg: 'No internet available');
                        }
                      },
                      child: Text(
                        "Verify Email",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: MediaQuery.of(context).size.height / 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  )
              ],
            )
      ],
    );
  }
}
