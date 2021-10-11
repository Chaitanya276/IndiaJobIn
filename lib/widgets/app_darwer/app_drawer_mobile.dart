import 'package:flutter/material.dart';
import 'package:indiajobin/views/profile_detail/profile_view_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:indiajobin/views/routes_and_apis/route_generator.dart'
    as userInfo;

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.7,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset('assets/icons/app_logo.png'),
              decoration: BoxDecoration(color: mainColor),
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text(
                'Profile',
                style: TextStyle(fontSize: 15),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileView()))
              },
            ),
            /*
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 15),
              ),
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrivacyPolicyView()))
              },
            ),
            ListTile(
              leading: Icon(Icons.supervised_user_circle),
              title: Text(
                'Terms of Service',
                style: TextStyle(fontSize: 15),
              ),
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TermsOfServiceView()))
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_support),
              title: Text(
                'Contact Us',
                style: TextStyle(fontSize: 15),
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ContactUsView()))
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text(
                'Share',
                style: TextStyle(fontSize: 15),
              ),
              onTap: () => {},
            ),
            */
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Logout',
                style: TextStyle(fontSize: 15),
              ),
              onTap: () => {
                userInfo.deleteUserInfo(context),
              },
            ),
          ],
        ),
      ),
    );
  }
}
