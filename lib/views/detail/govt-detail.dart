import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:indiajobin/widgets/separator.dart';
import 'package:url_launcher/url_launcher.dart';

class GovtDetailScreen extends StatefulWidget {
  final dynamic details;

  const GovtDetailScreen({Key key, this.details}) : super(key: key);

  @override
  _GovtDetailScreenState createState() => _GovtDetailScreenState();
}

class _GovtDetailScreenState extends State<GovtDetailScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 414, allowFontScaling: true);
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
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Column(
                children: [
                  DetailHeader(data: widget.details),
                  DetailContent(data: widget.details),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailHeader extends StatefulWidget {
  const DetailHeader({
    Key key,
    @required this.data,
  }) : super(key: key);

  final dynamic data;

  @override
  _DetailHeaderState createState() => _DetailHeaderState();
}

class _DetailHeaderState extends State<DetailHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/chevron_left_icon.svg',
              height: 30.sp,
              width: 30.sp,
              color: Colors.white,
            ),
          ),
          Text(
            'Job Details',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}

class DetailContent extends StatefulWidget {
  const DetailContent({
    Key key,
    @required this.data,
  }) : super(key: key);

  final dynamic data;

  @override
  _DetailContentState createState() => _DetailContentState();
}

class _DetailContentState extends State<DetailContent> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 50.0,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(70.0),
              topRight: Radius.circular(70.0),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      child: Image.asset("assets/icons/indian_govt.png"),
                      width: MediaQuery.of(context).size.width / 4.5,
                      height: MediaQuery.of(context).size.height / 8.5,
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.data["sector"].toString(),
                      style: TextStyle(
                        color: Color(0xFF211D42),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 67),
              Text(
                'Role',
                style: TextStyle(
                  color: Color(0xFF211D42),
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Separator(),
              SizedBox(height: 15),
              Text(
                widget.data["role"].toString(),
                style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
              ),
              SizedBox(height: 20),
              Text(
                'Location',
                style: TextStyle(
                  color: Color(0xFF211D42),
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Separator(),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    widget.data["city"].toString(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(','),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    widget.data["state"].toString(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Job Link ( Apply Here )',
                style: TextStyle(
                  color: Color(0xFF211D42),
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Separator(),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40.0,
                  child: RaisedButton(
                      color: mainColor,
                      child: Text(
                        'Apply Now',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),

                      onPressed: () {
                        openUrl();
                      }),
                ),
              )
              ,
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  openUrl() {
    String jobUrl = widget.data["job_link"];
    launch(jobUrl);
  }
}

