import 'package:flutter/material.dart';
import 'package:indiajobin/views/get_started.dart';
import 'package:indiajobin/views/jobList/joblist_view_mobile.dart';
import 'package:indiajobin/views/routes_and_apis/route_generator.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, home: SplashScreenShivay()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, routes: {
      '/': (context) => UserStatus(),
      '/home': (context) => JobListView(),
      '/splashPage': (context) => SplashPage(),
    });
  }
}

class SplashScreenShivay extends StatefulWidget {
  SplashScreenShivay({Key key}) : super(key: key);

  @override
  _SplashScreenShivayState createState() => _SplashScreenShivayState();
}

class _SplashScreenShivayState extends State<SplashScreenShivay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Powered by',
              style: new TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Image.asset(              
              "assets/icons/shivay.png",
              height: MediaQuery.of(context).size.height / 3.5,
              width: MediaQuery.of(context).size.width / 2,
            ),            
          ],
        ),
      ),
    );
  }
}
