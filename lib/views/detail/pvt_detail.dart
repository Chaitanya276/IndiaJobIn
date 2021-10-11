import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indiajobin/views/jobList/joblist_view_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:indiajobin/widgets/separator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indiajobin/views/routes_and_apis/all_apis.dart'
    as globals;
import 'package:http/http.dart' as http;

class PvtDetailScreen extends StatefulWidget {
  final dynamic details;

  const PvtDetailScreen({Key key, this.details}) : super(key: key);

  @override
  _PvtDetailScreenState createState() => _PvtDetailScreenState();
}

class _PvtDetailScreenState extends State<PvtDetailScreen> {
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
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              DetailHeader(data: widget.details),
              DetailContent(data: widget.details),
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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          "${widget.data["company_logo"].toString()}",
                          height: 60.sp,
                          width: 60.sp,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        widget.data["company"],
                        style: TextStyle(
                          color: Color(0xFF211D42),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              widget.data["role"],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 67),
                Text(
                  'Job Domain',
                  style: TextStyle(
                    color: Color(0xFF211D42),
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Separator(),
                SizedBox(height: 5),
                Text(
                  widget.data["domain"].toString(),
                  style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
                ),
                SizedBox(height: 25),
                Text(
                  'Job Description',
                  style: TextStyle(
                    color: Color(0xFF211D42),
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Separator(),
                SizedBox(height: 5),
                Text(
                  widget.data["job_description"].toString(),
                  style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
                ),
                SizedBox(height: 25),
                Text(
                  'Salary',
                  style: TextStyle(
                    color: Color(0xFF211D42),
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Separator(),
                SizedBox(height: 8),
                Text(
                  widget.data["salary"],
                  style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
                ),
                SizedBox(height: 25),
                Text(
                  'Location',
                  style: TextStyle(
                    color: Color(0xFF211D42),
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Separator(),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      widget.data["city"],
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
                      widget.data["state"],
                      style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
                    )
                  ],
                ),
                SizedBox(height: 25),
                Text(
                  'Valid Till',
                  style: TextStyle(
                    color: Color(0xFF211D42),
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Separator(),
                SizedBox(height: 5),
                Text(
                  widget.data["valid_till"],
                  style: TextStyle(color: Colors.grey[700], fontSize: 17.0),
                ),
                SizedBox(height: 25),
                isLoading == true
                    ? Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
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
                            onPressed: () async {
                              setState(() => isLoading = true);
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              var studentId =
                                  preferences.getString("studentId");
                              var userToken =
                                  preferences.getString("userToken");
                              var jobId = widget.data["id"];
                              final jobApplyUrl = globals.privateJobApply;
                              Map jobApplyData = {
                                "student_id": studentId,
                                "job_id": jobId
                              };
                              final http.Response response = await http.post(
                                jobApplyUrl,
                                headers: <String, String>{'token': userToken},
                                body: jsonEncode(jobApplyData),
                              );
                              var responseFromServer = response.body;
                              var jsonDecoded = jsonDecode(responseFromServer);
                              var msgFromServer = jsonDecoded['msg'];

                              if (msgFromServer == null) {
                                Fluttertoast.showToast(
                                    msg: "Something went wrong");
                              } else {
                                Fluttertoast.showToast(msg: msgFromServer);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobListView(),
                                  ),
                                  (route) => false,
                                );
                                setState(() => isLoading = false);
                              }
                            }),
                      ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailFooter extends StatelessWidget {
  const DetailFooter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.10),
              blurRadius: 50.w,
              offset: Offset(0, -10.w),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 300,
              child: RaisedButton(
                onPressed: () {},
                child: Text(
                  'Apply Now',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                color: Color(0xFF172b4d).withOpacity(0.8),
              ),
            )
          ],
        ),
      ),
    );
  }
}
