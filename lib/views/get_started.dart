import 'package:flutter/material.dart';
import 'package:indiajobin/animations/fade_animations.dart';
import 'package:indiajobin/views/PaymentRazorPay/payment_view_mobile.dart';
import 'package:indiajobin/views/login/login_view_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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
                  _buildText(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: Center(
              child: Image.asset(
                'assets/icons/app_logo.png',
                scale: 6,
              ),
            )),
            SizedBox(
          height: MediaQuery.of(context).size.height / 4,
        )
      ],
    );
  }

   Widget _buildText() {
    return Column(
      children: [
        Text(
          'Get Started',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
        Button(),
      ],
    );
  }
}

class Button extends StatefulWidget {
  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  AnimationController _scaleController;
  AnimationController _scale2Controller;
  AnimationController _widthController;
  AnimationController _positionController;

  Animation<double> _scaleAnimation;
  Animation<double> _scale2Animation;
  Animation<double> _widthAnimation;
  Animation<double> _positionAnimation;

  bool hideIcon = false;
  var loginCompleted,
      registrationCompleted,
      educationalDetailsCompleted,
      paymentCompleted,
      userName;
  @override
  void initState() {
    super.initState();

    _scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.8).animate(_scaleController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _widthController.forward();
            }
          });

    _widthController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));

    _widthAnimation =
        Tween<double>(begin: 80.0, end: 300.0).animate(_widthController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _positionController.forward();
            }
          });

    _positionController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    _positionAnimation =
        Tween<double>(begin: 0.0, end: 215.0).animate(_positionController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                hideIcon = true;
              });
              _scale2Controller.forward();
            }
          });

    _scale2Controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));

    _scale2Animation = Tween<double>(begin: 1.0, end: 32.0).animate(
        _scale2Controller)
      ..addStatusListener((status) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        loginCompleted = preferences.getBool("userLogin");
        registrationCompleted = preferences.getBool("userRegistration");
        paymentCompleted = preferences.getBool("userPayment");
        userName = preferences.getString("userName");
        if (status == AnimationStatus.completed) {
          if ((loginCompleted == false || loginCompleted == null) &&
              (registrationCompleted == false ||
                  registrationCompleted == null)) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginView()));
          } else if ((loginCompleted == true &&
                  (paymentCompleted == false || paymentCompleted == null)) ||
              (registrationCompleted == true &&
                  (paymentCompleted == false || paymentCompleted == null))) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => PaymentView()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginView()));
          }
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      2.6,
      AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: AnimatedBuilder(
                animation: _widthController,
                builder: (context, child) => Container(
                  width: _widthAnimation.value,
                  height: 80,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Color(0xFF172b4d).withOpacity(.4)),
                  child: InkWell(
                    onTap: () {
                      _scaleController.forward();
                    },
                    child: Stack(children: <Widget>[
                      AnimatedBuilder(
                        animation: _positionController,
                        builder: (context, child) => Positioned(
                          left: _positionAnimation.value,
                          child: AnimatedBuilder(
                            animation: _scale2Controller,
                            builder: (context, child) => Transform.scale(
                                scale: _scale2Animation.value,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF172b4d)),
                                  child: hideIcon == false
                                      ? Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                )),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
