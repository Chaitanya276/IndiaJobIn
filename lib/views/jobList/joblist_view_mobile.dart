import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indiajobin/widgets/app_darwer/app_drawer_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:indiajobin/jsonModelClasses/job_govt.dart';
import 'package:indiajobin/jsonModelClasses/job_private.dart';
import 'package:indiajobin/views/detail/govt-detail.dart';
import 'package:indiajobin/views/detail/pvt_detail.dart';
import 'package:http/http.dart' as http;
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indiajobin/views/routes_and_apis/all_apis.dart' as globals;

TextEditingController controllerSearch = TextEditingController();
String privateSearchText = "", govtSearchText = "";
bool privateSearchBool = false, govtSearchBool = false, isSearching = false;
String pSearchBarText = "Search Job, Companies...",
    gSearchBarText = "Search Domain, Role...",
    searchBarText = "";
bool stateSelected = false, citySelected = false;
String stateGlobalId, cityGlobalId;
var globalStateList = [], globalCityList = [];
String stateDDText = 'Loading States...',
    cityDDText = 'Select City',
    finalCityName;
bool isPrivateView = true;

class JobListView extends StatefulWidget {
  @override
  _JobListViewState createState() => _JobListViewState();
}

class _JobListViewState extends State<JobListView>
    with TickerProviderStateMixin {
  bool payStatus = true;
  int paymentStatus;
  checkPaymentStatus() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    paymentStatus = preferences.getInt("paymentStatus");
    paymentStatus == -1 ? _tabController.animateTo(1) : _tabController.animateTo(0);
  }

  TabController _tabController;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // checkPaymentStatus();
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: isPrivateView ? 0 : 1);
    // initialIndex: isPrivateView ? 1 : 0);
    _tabController.addListener(_handleTabIndex);

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      // displayNotification(message);
      // final notification = message['notification'];
    }, onResume: (Map<String, dynamic> message) async {
      // final notification = message['notification'];
      // _setMessage(message);
    }, onLaunch: (Map<String, dynamic> message) async {
      // final notification = message['notification'];
    });
  }

  void _handleTabIndex() {
    setState(() {
      // _currentIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 414, allowFontScaling: true);
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: AppDrawer(),
      appBar: AppBar(
        title: !isSearching
            ? Container(
                child: Text("India JobIn",
                    style: TextStyle(fontWeight: FontWeight.bold)))
            : TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Search Job, Companies...',
                    hintStyle: TextStyle(color: Colors.white)),
                onChanged: (text) {
                  if (privateSearchBool && !govtSearchBool) {
                    privateSearchText = text;
                  } else if (!privateSearchBool && govtSearchBool) {
                    govtSearchText = text;
                  }
                },
              ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  tooltip: 'back',
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      privateSearchText = govtSearchText = "";
                    });
                  })
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  }),
          IconButton(
              icon: Icon(Icons.tune),
              onPressed: () {
                DialogHelper.exit(context);
              }),
        ],
        toolbarHeight: 150.0,
        backgroundColor: mainColor,
        bottom: TabBar(
          labelColor: mainColor,
          unselectedLabelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          controller: _tabController,
          tabs: <Tab>[
            //Private
            Tab(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Private Jobs',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            //Govt
            Tab(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Government Jobs',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Press again to exit app'),
        ),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(child: PrivateSearch()),
            Container(child: GovernmentJobs())
          ],
        ),
      ),
    ));
  }
}

class DialogHelper {
  static exit(context) =>
      showDialog(context: context, builder: (context) => FilterDialog());
}

bool isCitiesFetched = false;

class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController cityCon = TextEditingController();
  final TextEditingController stateCon = TextEditingController();
  final TextEditingController countryCon = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (cityGlobalId == null) {
      cityDDText = "Select City";
    } else {
      cityDDText = cityGlobalId;
    }
    if (cityGlobalId != null) {
      getCityName(stateGlobalId);
    }
    if (globalStateList.isNotEmpty) {
      stateList = globalStateList;
    } else {
      _getStatesList("101");
    }
    if (globalCityList.isNotEmpty) {
      cityList = globalCityList;
    } else if (stateGlobalId != null) {
      _getCityList(stateGlobalId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: MediaQuery.of(context).size.height / 3,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildStateRow(),
              SizedBox(
                height: MediaQuery.of(context).size.height / 70,
              ),
              _buildCityRow(),
              SizedBox(
                height: MediaQuery.of(context).size.height / 70,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 16)),
                      textColor: mainColor),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 30,
                  ),
                  RaisedButton(
                    child:
                        Text('Apply filters', style: TextStyle(fontSize: 16)),
                    color: isCitiesFetched ? mainColor : Colors.grey[600],
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    onPressed: isCitiesFetched
                        ? () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => JobListView()),
                                (route) => false);
                          }
                        : () {},
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 70,
              ),
              Center(
                child: InkWell(
                  child: Text(
                    "Reset Filters",
                    style: TextStyle(color: Colors.black45, fontSize: 16),
                  ),
                  onTap: () {
                    setState(() {
                      stateGlobalId = null;
                      cityGlobalId = null;
                      globalStateList = [];
                      globalCityList = [];
                    });
                    stateDDText = 'Loading States...';
                    cityDDText = 'Select City';
                    citySelected = false;
                    stateSelected = false;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobListView(),
                        ),
                        (route) => false);
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 70,
              ),
            ],
          ),
        ),
      );

  Widget _buildStateRow() {
    return Stack(children: <Widget>[
      Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 23.0),
          child: Icon(
            Icons.map,
            color: mainColor,
          ),
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 15.0, top: 10),
          child: Padding(
            padding: EdgeInsets.only(bottom: 1.0),
            child: SearchableDropdown.single(
              items: stateList?.map((item) {
                    return new DropdownMenuItem(
                      child: new Text(item['name']),
                      value: item['name'].toString(),
                    );
                  })?.toList() ??
                  [],
              value: myStateName,
              hint: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text('$stateDDText'),
              ),
              searchHint: "Search State",
              onChanged: (newValue) {
                myStateName = newValue;
                for (var i = 0; i < stateList.length; i++) {
                  if (myStateName == stateList[i]['name']) {
                    stateGlobalId = stateList[i]['id'];
                    break;
                  }
                }
                setState(() {
                  stateGlobalId = stateGlobalId;
                  myCity = null;
                  stateDDText = newValue;
                  cityGlobalId = null;
                  cityDDText = 'Loading Cities...';
                  citySelected = false;
                  stateSelected = true;
                  isCitiesFetched = false;
                  cityList = [];
                  if (cityGlobalId == null) {
                    _getCityList(stateGlobalId);
                  }
                });
              },
              isExpanded: true,
              isCaseSensitiveSearch: false,
              displayClearIcon: false,
            ),
          )),
    ]);
  }

  Widget _buildCityRow() {
    return Stack(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 23.0),
            child: Icon(
              Icons.location_city,
              color: mainColor,
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 15.0, top: 10),
            child: Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: SearchableDropdown.single(
                items: cityList?.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(item['name']),
                        value: item['name'].toString(),
                      );
                    })?.toList() ??
                    [],
                value: myCityName,
                displayClearIcon: false,
                hint: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text('$cityDDText')),
                searchHint: "Select City",
                onChanged: (newValue) {
                  myCityName = newValue;
                  for (var i = 0; i < cityList.length; i++) {
                    if (myCityName == cityList[i]['name']) {
                      myCity = cityList[i]['id'];
                      break;
                    }
                  }
                  setState(() {
                    cityGlobalId = myCity;
                    citySelected = true;
                  });
                },
                isExpanded: true,
                isCaseSensitiveSearch: false,
              ),
            )),
      ],
    );
  }

  List stateList;
  String myState;
  var myStateName;
  Future _getStatesList(String stateId) async {
    stateId = "101";
    stateDDText = 'Loading States...';
    String myStateUrl = globals.state + stateId;
    http.Response response = await http.get(myStateUrl);
    final dataFirst = jsonDecode(response.body);
    await http.get(myStateUrl).then((response) {
      setState(() {
        stateList = dataFirst;
        globalStateList = dataFirst;
        if (stateDDText == 'Loading States...') {
          stateDDText = 'Select State';
        }
      });
    });
  }

  getCityName(String cityId) async {
    String myCityUrl = globals.city + cityId;
    cityDDText = 'Loading city name...';
    http.Response response = await http.get(myCityUrl);
    final cityNameList = jsonDecode(response.body);
    var cityHintText; //= 'Loading Cities...';
    if (response.statusCode == 200) {
      await http.get(myCityUrl).then((response) {
        for (var i = 0; i < cityNameList.length; i++) {
          if (cityGlobalId == cityNameList[i]['id']) {
            cityHintText = cityNameList[i]['name'];
          }
        }
        setState(() {
          finalCityName = cityHintText;
          cityDDText = cityHintText;
        });
      });
    }
  }

  List cityList;
  String myCity, myCityName;
  Future _getCityList(String cityId) async {
    String myCityUrl = globals.city + cityId;
    if (cityDDText != null) {}
    http.Response response = await http.get(myCityUrl);
    final dataFirst = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await http.get(myCityUrl).then((response) {
        setState(() {
          isCitiesFetched = true;
          cityList = dataFirst;
          globalCityList = dataFirst;
          cityDDText = 'Select City';
        });
      });
    }
  }
}

class PrivateSearch extends StatefulWidget {
  @override
  _PrivateSearch createState() => _PrivateSearch();
}

class _PrivateSearch extends State<PrivateSearch> {
  List<dynamic> privateJobListSearch = List<dynamic>();
  ScrollController _scrollController = ScrollController();
  Future _futureGetPrivateJob;

  @override
  void initState() {
    super.initState();
    fetchThree();
    setState(() {
      isPrivateView = true;
    });
    _futureGetPrivateJob = getJob();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchThree();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getJob,
      child: Scaffold(
        body: FutureBuilder(
            future: _futureGetPrivateJob,
            // ignore: missing_return
            builder: (context, projectSnap) {
              if (projectSnap.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator());
              } else if (projectSnap.data == null) {
                return Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: Image.asset("assets/icons/no_record.png")));
              } else if (projectSnap.hasData == true) {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: _scrollController,
                  itemCount: privateJobListSearch.length,
                  itemBuilder: (BuildContext context, int index) {
                    privateSearchBool = true;
                    govtSearchBool = false;
                    if (privateSearchText.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 30, right: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                blurRadius: 20.w,
                                offset: Offset(10.w, 10.w),
                              )
                            ],
                          ),
                          child: OpenContainer(
                            transitionType: ContainerTransitionType.fade,
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            openColor: Colors.grey[100],
                            openElevation: 0,
                            openBuilder: (context, action) {
                              return (PvtDetailScreen(
                                  details: privateJobListSearch[index]));
                            },
                            closedColor: Colors.transparent,
                            closedElevation: 0,
                            closedBuilder: (context, action) {
                              return Container(
                                height: MediaQuery.of(context).size.height / 6,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadiusDirectional.circular(30),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Image.network(
                                            "${privateJobListSearch[index]["company_logo"].toString()}",
                                            height: 40.sp,
                                            width: 40.sp,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Text(
                                          '${privateJobListSearch[index]["company"].toString()}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${privateJobListSearch[index]["role"].toString()}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                50),
                                    Row(
                                      children: [
                                        Text(
                                          '${privateJobListSearch[index]["salary"].toString()}',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black
                                                  .withOpacity(0.5)),
                                        ),
                                        Spacer(),
                                        Container(
                                          child: Text(
                                            (() {
                                              var isApplied =
                                                  privateJobListSearch[index]
                                                          ["applied"]
                                                      .toString();
                                              if (isApplied == 'true') {
                                                return "\u{2713} Applied";
                                              } else {
                                                return "";
                                              }
                                            })(),
                                            style: TextStyle(
                                                color: Colors.lightGreen),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                10),
                                    Row(
                                      children: [
                                        Text(
                                          '${privateJobListSearch[index]["city"].toString()}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 12.0),
                                        ),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Text(','),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Text(
                                          '${privateJobListSearch[index]["state"].toString()}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 12.0),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      if ((((privateJobListSearch[index]["company"].toString())
                                      .toLowerCase())
                                  .contains(privateSearchText) ||
                              ((privateJobListSearch[index]["role"].toString())
                                      .toLowerCase())
                                  .contains(privateSearchText)) &&
                          privateSearchBool) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, left: 30, right: 30),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                  blurRadius: 20.w,
                                  offset: Offset(10.w, 10.w),
                                )
                              ],
                            ),
                            child: OpenContainer(
                              transitionType: ContainerTransitionType.fade,
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              openColor: Colors.grey[100],
                              openElevation: 0,
                              openBuilder: (context, action) {
                                return (PvtDetailScreen(
                                    details: privateJobListSearch[index]));
                              },
                              closedColor: Colors.transparent,
                              closedElevation: 0,
                              closedBuilder: (context, action) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height / 6,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(30),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Image.network(
                                              "${privateJobListSearch[index]["company_logo"].toString()}",
                                              height: 40.sp,
                                              width: 40.sp,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Text(
                                            '${privateJobListSearch[index]["company"].toString()}',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${privateJobListSearch[index]["role"].toString()}',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              50),
                                      Row(
                                        children: [
                                          Text(
                                            '${privateJobListSearch[index]["salary"].toString()}',
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black
                                                    .withOpacity(0.5)),
                                          ),
                                          Spacer(),
                                          Container(
                                            child: Text(
                                              (() {
                                                var isApplied =
                                                    privateJobListSearch[index]
                                                            ["applied"]
                                                        .toString();
                                                if (isApplied == 'true') {
                                                  return "\u{2713} Applied";
                                                } else {
                                                  return "";
                                                }
                                              })(),
                                              style: TextStyle(
                                                  color: Colors.lightGreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            '${privateJobListSearch[index]["city"].toString()}',
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12.0),
                                          ),
                                          SizedBox(
                                            width: 2.0,
                                          ),
                                          Text(','),
                                          SizedBox(
                                            width: 2.0,
                                          ),
                                          Text(
                                            '${privateJobListSearch[index]["state"].toString()}',
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12.0),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                  },
                );
              }
            }),
      ),
    );
  }

  bool showT;

  void showSomeMessage() {
    if (showT == true) {
      Fluttertoast.showToast(msg: "Sorry! No jobs found.");
    }
  }

  Future getPrivateJobs() async {
    getJob();
    await new Future.delayed(Duration(seconds: 1));
  }

  fetchThree() {
    for (int i = 0; i < 3; i++) {
      getJob();
    }
  }

  // ignore: missing_return
  Future<List<PrivateJobList>> getJob() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var baseUrl;
      var userToken = preferences.getString("userToken");
      String email = preferences.getString("userEmail");
      email = preferences.getString("userEmail");
      if ((stateSelected == true) && (citySelected == false)) {
        baseUrl = globals.pvtJobListing +
            email +
            '&country=101&state=' +
            stateGlobalId;
      } else if ((stateSelected == true) && (citySelected == true)) {
        baseUrl = globals.pvtJobListing +
            email +
            '&country=101&state=' +
            stateGlobalId +
            '&city=' +
            cityGlobalId;
      } else {
        baseUrl = globals.pvtJobListing + email;
        baseUrl =
            "https://indiajobin.com/admin/joblisting/private?student_email=" +
                email;
      }

      final response = await http
          .get(baseUrl, headers: <String, String>{'token': userToken});
      if (response.statusCode == 201) {
        var jsonResponse = response.body;
        var jsonString = jsonResponse.toString();
        var jsonDecoded = jsonDecode(jsonString);
        var privateJobLength = jsonDecoded.length;
        var appliedJobList = <Map>[];
        var notAppliedJobList = <Map>[];
        var applied = 0;
        var notApplied = 0;

        if (jsonDecoded[0] == null) {
          if (jsonDecoded['msg'] == 'Sorry no Jobs Found!') {}
          return null;
        } else {
          for (var i = 0; i < privateJobLength; i++) {
            if ((jsonDecoded[i]['applied']).toString() == 'true') {
              appliedJobList.insert(applied, jsonDecoded[i]);
              applied++;
            } else if ((jsonDecoded[i]['applied']).toString() == 'false') {
              notAppliedJobList.insert(notApplied, jsonDecoded[i]);
              notApplied++;
            }
          }
          jsonDecoded = [];
          jsonDecoded = notAppliedJobList + appliedJobList;

          var finalPrivateJobList = List<PrivateJobList>();
          for (var notesjson in jsonDecoded) {
            finalPrivateJobList.add(PrivateJobList.fromJson(notesjson));
          }
          setState(() {
            privateJobListSearch = List.from(jsonDecoded);
          });
          return finalPrivateJobList;
        }
      } else {
        Fluttertoast.showToast(msg: "Something went wrong.");
      }
    } catch (Exception) {
      throw Exception('this is exception--->No data found :::  $Exception');
    }
  }
}

class GovernmentJobs extends StatefulWidget {
  @override
  _GovernmentJobsState createState() => _GovernmentJobsState();
}

class _GovernmentJobsState extends State<GovernmentJobs> {
  List<dynamic> govtJobList = List<dynamic>();
  ScrollController _scrollController = ScrollController();
  Future _futureGetGovernmentJob;
  var govtJob = false;

  @override
  void initState() {
    super.initState();
    fetchThree();
    isPrivateView = false;
    _futureGetGovernmentJob = getGovtJob();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchThree();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getGovtJob,
      child: Scaffold(
        body: FutureBuilder(
            future: _futureGetGovernmentJob,
            // ignore: missing_return
            builder: (context, projectSnap) {
              if (projectSnap.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator());
              } else if (govtJob) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: govtJobList.length,
                  itemBuilder: (BuildContext context, int index) {
                    govtSearchBool = true;
                    privateSearchBool = false;
                    if (govtSearchText.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 30, right: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                blurRadius: 20.w,
                                offset: Offset(10.w, 10.w),
                              )
                            ],
                          ),
                          child: OpenContainer(
                            transitionType: ContainerTransitionType.fade,
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            openColor: Colors.grey[100],
                            openElevation: 0,
                            openBuilder: (context, action) {
                              return GovtDetailScreen(
                                  details: govtJobList[index]);
                            },
                            closedColor: Colors.transparent,
                            closedElevation: 0,
                            closedBuilder: (context, action) {
                              return Container(
                                height: MediaQuery.of(context).size.height / 6,
                                padding: EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(30)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          child: Image.asset(
                                              "assets/icons/indian_govt.png"),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              20,
                                        ),
                                        Text(
                                          '${govtJobList[index]["sector"].toString()}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black
                                                  .withOpacity(0.7)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                50),
                                    Text(
                                      '${govtJobList[index]["role"].toString()}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                55),
                                    Text(
                                      '${govtJobList[index]["state"].toString()}',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else if ((((govtJobList[index]["domain"].toString())
                                    .toLowerCase())
                                .contains(govtSearchText) ||
                            ((govtJobList[index]["role"].toString())
                                    .toLowerCase())
                                .contains(govtSearchText)) &&
                        govtSearchBool) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 30, right: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                blurRadius: 20.w,
                                offset: Offset(10.w, 10.w),
                              )
                            ],
                          ),
                          child: OpenContainer(
                            transitionType: ContainerTransitionType.fade,
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            openColor: Colors.grey[100],
                            openElevation: 0,
                            openBuilder: (context, action) {
                              return GovtDetailScreen(
                                  details: govtJobList[index]);
                            },
                            closedColor: Colors.transparent,
                            closedElevation: 0,
                            closedBuilder: (context, action) {
                              return Container(
                                height: MediaQuery.of(context).size.height / 6,
                                padding: EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(30)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          child: Image.asset(
                                              "assets/icons/indian_govt.png"),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              20,
                                        ),
                                        Text(
                                          '${govtJobList[index]["sector"].toString()}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black
                                                  .withOpacity(0.7)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                50),
                                    Text(
                                      '${govtJobList[index]["role"].toString()}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                55),
                                    Text(
                                      '${govtJobList[index]["state"].toString()}',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(),
                      );
                    }
                  },
                );
              } else if (projectSnap.hasError) {
                return Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: Image.asset("assets/icons/no_record.png")));
              }
            }),
      ),
    );
  }

  Future getGovernmentJobs() async {
    getGovtJob();
    await new Future.delayed(Duration(seconds: 5));
  }

  var govtData;
  // ignore: missing_return
  Future<GovernmentJobList> getGovtJob() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var userToken = preferences.getString("userToken");
    String email;
    email = preferences.getString("userEmail");
    var govtGaseUrl;

    if ((stateSelected == true) && (citySelected == false)) {
      govtGaseUrl = globals.govtJobListing +
          email +
          '&country=101&state=' +
          stateGlobalId;
    } else if ((stateSelected == true) && (citySelected == true)) {
      govtGaseUrl = globals.govtJobListing +
          email +
          '&country=101&state=' +
          stateGlobalId +
          '&city=' +
          cityGlobalId;
    } else {
      govtGaseUrl = globals.govtJobListing + email;
    }
    var response = await http.get(govtGaseUrl, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'token': userToken
    });

    if (response.statusCode == 201) {
      var jsonResponse = response.body;
      var jsonString = jsonResponse.toString();
      var jsonDecoded = jsonDecode(jsonString);
      if ((jsonDecoded[0]) == null) {
        setState(() {
          govtJob = false;
        });
      } else {
        setState(() {
          govtJob = true;
          govtJobList = List.from(jsonDecoded);
        });
      }
    } else {
      throw Exception('No data found');
    }
  }

  fetchThree() {
    for (int i = 0; i < 3; i++) {
      getGovtJob();
    }
  }
}
