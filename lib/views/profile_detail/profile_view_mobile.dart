import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indiajobin/jsonModelClasses/edit_profile.dart';
import 'package:indiajobin/views/jobList/joblist_view_mobile.dart';
import 'package:indiajobin/widgets/constants.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indiajobin/views/routes_and_apis/all_apis.dart' as allApis;
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

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

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hscvisible = false;
  bool _itivisible = false;
  bool _diplomavisible = false;
  bool _undergvisible = false;
  bool _postgvisible = false;
  bool _skillsvisible = false;
  var sscEduFieldsOld,
      hscEduFieldsOld,
      diplomaEduFieldsOld,
      itiEduFieldsOld,
      graduateEduFieldsOld,
      postGraduateEduFieldsOld,
      exid;
  var sscEduFieldsNew,
      hscEduFieldsNew,
      diplomaEduFieldsNew,
      itiEduFieldsNew,
      graduateEduFieldsNew,
      postGraduateEduFieldsNew;
  List<dynamic> currenSelectedSkills = [];
  Map skillObj = {};
  List sendSkills = [];
  List oldSkill = [];
  var seekerSkillsList;
  var seekerExperience;
  String eFirstname,
      eLastname,
      eEmail,
      eMobile,
      eCountry,
      eState,
      eCity,
      eAddress,
      ePostal,
      eBackground,
      eReferredby,
      workBackground,
      userBackground,
      countryDDText = 'Loading Countries... ',
      stateDDText = 'Select State',
      cityDDText = 'Select City',
      backgroundDDText = 'Select Background',
      referredByDDText = 'Referred By';
  var fetchedCountryId, fetchedStatetId, fetchedCityId;
  bool registrationCompleted = false;

  TextEditingController firstnameCon = TextEditingController();
  TextEditingController lastnameCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  TextEditingController mobileCon = TextEditingController();
  TextEditingController cityCon = TextEditingController();
  TextEditingController stateCon = TextEditingController();
  TextEditingController countryCon = TextEditingController();
  TextEditingController addressCon = TextEditingController();
  TextEditingController postalCon = TextEditingController();
  TextEditingController backgroundCon = TextEditingController();
  TextEditingController refferedByCon = TextEditingController();
  String sharedEmail, sharedToken;
  File _image;
  TextEditingController sscBoard = new TextEditingController();
  TextEditingController sscInstituteName = new TextEditingController();
  TextEditingController sscPercentage = new TextEditingController();
  TextEditingController sscYearOfPassing = new TextEditingController();
  String sBoard, sInstituteName, sPercentage, sYearOfPassing;
  TextEditingController hscBoard = new TextEditingController();
  TextEditingController hscInstituteName = new TextEditingController();
  TextEditingController hscPercentage = new TextEditingController();
  TextEditingController hscYearOfPassing = new TextEditingController();
  String hBoard, hInstituteName, hPercentage, hYearOfPassing;
  String itiDegreeDD, itiDegreeDDText = 'Degree*';
  TextEditingController itiCourseName = new TextEditingController();
  TextEditingController itiInstituteName = new TextEditingController();
  TextEditingController itiYearOfPassing = new TextEditingController();
  TextEditingController itiCGPA = new TextEditingController();
  String iDegree, iCourseName, iInstituteName, iYearOfPassing, iCGPA;
  String diplomaDegreeDD, diplomaDegreeDDText = 'Degree*';
  TextEditingController diplomaCourseName = new TextEditingController();
  TextEditingController diplomaInstituteName = new TextEditingController();
  TextEditingController diplomaYearOfPassing = new TextEditingController();
  TextEditingController diplomaCGPA = new TextEditingController();
  String dDegree, dCourseName, dInstituteName, dYearOfPassing, dCGPA;
  String graduationDegreeDD, graduationDegreeDDText = 'Degree*';
  TextEditingController graduationCourseName = new TextEditingController();
  TextEditingController graduationInstituteName = new TextEditingController();
  TextEditingController graduationYearOfPassing = new TextEditingController();
  TextEditingController graduationCGPA = new TextEditingController();
  String gDegree, gCourseName, gInstituteName, gYearOfPassing, gCGPA;
  String postGraduationDegreeDD, postGraduationDegreeDDText = 'Degree*';
  TextEditingController postGraduationCourseName = new TextEditingController();
  TextEditingController postGraduationInstituteName =
      new TextEditingController();
  TextEditingController postGraduationYearOfPassing =
      new TextEditingController();
  TextEditingController postGraduationCGPA = new TextEditingController();
  String pgDegree, pgCourseName, pgInstituteName, pgYearOfPassing, pgCGPA;

  bool secEdu = true;
  List showSkills;
  TextEditingController newSkillText = new TextEditingController();
  List<String> newSkillList = List();

  // ignore: non_constant_identifier_names
  bool high_edu = false;
  bool autoValidation = false;
  bool itidegreeBool = false;
  bool diplomadegreeBool = false;
  bool graduatedegreeBool = false;
  bool postgraduatedegreeBool = false;
  bool educationalDetailsBool = false;
  String selectedITIDegree;
  bool skills = false;
  String itiDegree,
      diplomaDegree,
      graduationDegree,
      postGraduationDegree,
      industry,
      workExperience,
      workExperienceDDText = 'Work Experience',
      skillsOfIndustry;
  bool profileCompleted = false;
  bool alreadyHaveSkills = false;
  bool hasProfilePic = false;
  var profilePicUrl;
  bool loadingProfilePic = false;
  bool profilePicChanged = false;
  bool isProfileLoaded = false;
  String userEmail, userToken, studentId;
  var userPassword;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  List<int> selectedTechnicalSkills = [];
  List<dynamic> skillsName = [];
  List<dynamic> fetchSkillName = [];
  List<dynamic> postSkills;
  final List<DropdownMenuItem> items = [];
  var imageLoaction;
  String skillsText = 'loading skills...';
  bool isLoading = false, finalLoader = false;
  List exp;
  var connectivityResult;
  bool isConnected = false,
      isCountryFetched = false,
      isStateFetched = false,
      isCityFetched = false;
  Future isInternet() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      if (await DataConnectionChecker().hasConnection) {
        isConnected = true;
      } else {
        isConnected = false;
        Fluttertoast.showToast(msg: 'No internet available');
      }
    } else {
      isConnected = false;
      Fluttertoast.showToast(msg: 'No internet available');
    }
  }

  fetchUserCredential() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userEmail = preferences.getString("userEmail");
    userToken = preferences.getString("userToken");
    studentId = preferences.getString("studentId");
    userPassword = preferences.getString("userPassword");
    if ((userEmail != null) && (userToken != null) && (studentId != null)) {
      getUserProfile();
    } else {
      Fluttertoast.showToast(
          msg: "Something went wrong. Try reinstalling the app");
    }
  }

  var imageSelected;
  var result;

  Future getImage() async {
    // ignore: deprecated_member_use
    imageSelected = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 700, maxWidth: 700);
    if (imageSelected != null) {
      var filePath = imageSelected.absolute.path;
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      final originalProfileSize = imageSelected.lengthSync();
      int compressionValue = 90;
      if ((originalProfileSize >= 2500000) && (originalProfileSize < 3000000)) {
        compressionValue = 60;
      } else if ((originalProfileSize > 1500000) &&
          (originalProfileSize < 2500000)) {
        compressionValue = 70;
      } else if (originalProfileSize < 1500000) {
        compressionValue = 75;
      }
      result = await FlutterImageCompress.compressAndGetFile(
        imageSelected.absolute.path,
        outPath,
        quality: compressionValue,
      );
    }
    setState(() {
      if (imageSelected != null) {
        hasProfilePic = false;
        _image = result;
        imageLoaction = imageSelected.path;
        profilePicChanged = true;
      } else {
        hasProfilePic = true;
      }
    });
  }

  @override
  void initState() {
    isInternet();
    fetchUserCredential();
    finalLoader = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50))),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  child: Center(
                                      child: IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => JobListView(),
                                          ),
                                          (route) => false);
                                    },
                                  )),
                                  backgroundColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Stack(
                              children: [
                                Container(
                                  height: 130,
                                  width: 130,
                                  child: hasProfilePic
                                      ? Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: profilePicUrl == ""
                                                      ? AssetImage(
                                                          'assets/icons/2470c7.png')
                                                      : NetworkImage(
                                                          profilePicUrl),
                                                  fit: BoxFit.cover)))
                                      : Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: _image == null
                                                      ? AssetImage(
                                                          'assets/icons/2470c7.png')
                                                      : FileImage(_image),
                                                  fit: BoxFit.cover))),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 90,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: IconButton(
                                      icon: Icon(Icons.camera_alt,
                                          color: Colors.teal),
                                      onPressed: getImage,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Form(
                      autovalidateMode: autovalidateMode,
                      key: _formKey,
                      child: Column(
                        //mainAxisSize: MainAxisSize.max,
                        children: [
                          //Personal Information
                          Container(
                            child: Column(
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Column(
                                      children: <Widget>[
                                        _buildFirstNameRow(),
                                        _buildLastNameRow(),
                                        _buildMobNoRow(),
                                        _buildEmailRow(),
                                        _buildCountryRow(),
                                        countrySelected
                                            ? _buildStateRow()
                                            : _buildHiddenContainerState(),
                                        stateSelected
                                            ? _buildCityRow()
                                            : _buildHiddenContainerCity(),
                                        _buildAddressRow(),
                                        _buildPostalRow(),
                                        _buildBackgroundRow(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0),
                          //sec
                          Container(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    height: 50,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        color: Colors.grey[100]),
                                    child: CheckboxListTile(
                                      title:
                                          Text("Secondary Education ( 10th )"),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: secEdu,
                                      onChanged: (bool secondaryEdu) {
                                        setState(() {
                                          secEdu = secondaryEdu;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                if (secEdu)
                                  SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 15.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0, right: 30.0),
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                labelText: 'Institute Name',
                                              ),
                                              controller: sscInstituteName,
                                              validator: (String value) {
                                                String text;
                                                if (value.isEmpty) {
                                                  text = 'Enter Institute Name';
                                                }
                                                return text;
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0, right: 30.0),
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                labelText: 'SSC Board',
                                              ),
                                              controller: sscBoard,
                                              validator: (String value) {
                                                String text;
                                                if (value.isEmpty) {
                                                  text = 'Enter Board Name';
                                                }
                                                return text;
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0, right: 30.0),
                                            child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Percentage / CGPA',
                                                ),
                                                controller: sscPercentage,
                                                validator: (value) {
                                                  String text;
                                                  var intvalue =
                                                      double.tryParse(value);
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Percentage/CGPA';
                                                  } else {
                                                    if ((intvalue > 0) &&
                                                        (intvalue <= 100)) {
                                                    } else {
                                                      text =
                                                          'Enter valid Percentage/CGPA';
                                                    }
                                                  }
                                                  return text;
                                                }),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0, right: 30.0),
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Year of Passing',
                                              ),
                                              controller: sscYearOfPassing,
                                              validator: (String value) {
                                                String text;
                                                if (value.isEmpty) {
                                                  text =
                                                      'Enter Year of Passing';
                                                }
                                                return text;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          //high
                          Visibility(
                            visible: _hscvisible,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Colors.grey[100]),
                                      child: CheckboxListTile(
                                        title:
                                            Text("Higher Education ( 12th )"),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: high_edu,
                                        onChanged: (bool highEdu) {
                                          setState(() {
                                            high_edu = highEdu;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (high_edu)
                                    SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 15.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Institute Name',
                                                ),
                                                controller: hscInstituteName,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Institute Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Hssc Board',
                                                ),
                                                controller: hscBoard,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text = 'Enter Board Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Percentage / CGPA',
                                                ),
                                                controller: hscPercentage,
                                                validator: (value) {
                                                  String text;
                                                  var intvalue =
                                                      double.tryParse(value);
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Percentage/CGPA';
                                                  } else {
                                                    if ((intvalue > 0) &&
                                                        (intvalue <= 100)) {
                                                    } else {
                                                      text =
                                                          'Enter valid Percentage/CGPA';
                                                    }
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Year of Passing',
                                                ),
                                                controller: hscYearOfPassing,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text = 'Enter Year Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          //diploma
                          Visibility(
                            visible: _diplomavisible,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Colors.grey[100]),
                                      child: CheckboxListTile(
                                        title: Text("Diploma"),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: diplomadegreeBool,
                                        onChanged: (bool degreediploma) {
                                          setState(() {
                                            diplomadegreeBool = degreediploma;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (diplomadegreeBool)
                                    SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 15.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0,
                                                  left: 30.0,
                                                  right: 30.0),
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    bottom: 1.0),
                                                child:
                                                    SearchableDropdown.single(
                                                  isCaseSensitiveSearch: false,
                                                  items: [
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Architectural Assistantship'),
                                                        value:
                                                            'Architectural Assistantship'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Automobile Engineering'),
                                                        value:
                                                            'Automobile Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Chemical Engineering'),
                                                        value:
                                                            'Chemical Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Civil Engineering'),
                                                        value:
                                                            'Civil Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Computer Engineering'),
                                                        value:
                                                            'Computer Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Computer Science and Engineering'),
                                                        value:
                                                            'Computer Science and Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electrical Engineering'),
                                                        value:
                                                            'Electrical Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electronics and Communication Engineering'),
                                                        value:
                                                            'Electronics and Communication Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electronics and Communication Engineering - Industry Integrate'),
                                                        value:
                                                            'Electronics and Communication Engineering - Industry Integrate'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electrical and Electronics Engineering'),
                                                        value:
                                                            'Electrical and Electronics Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electronics (Microprocessor)'),
                                                        value:
                                                            'Electronics (Microprocessor)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electronics and Telecommunication Engineering '),
                                                        value:
                                                            'Electronics and Telecommunication Engineering '),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Fashion Design'),
                                                        value:
                                                            'Fashion Design'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Food Technology'),
                                                        value:
                                                            'Food Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Garment Technology'),
                                                        value:
                                                            'Garment Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Information Technology'),
                                                        value:
                                                            'Information Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Instrumentation Technology'),
                                                        value:
                                                            'Instrumentation Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Interior Design and Decoration '),
                                                        value:
                                                            'Interior Design and Decoration '),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Leather Technology'),
                                                        value:
                                                            'Leather Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Leather Technology (Footwear)'),
                                                        value:
                                                            'Leather Technology (Footwear)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Library and Information Sciences'),
                                                        value:
                                                            'Library and Information Sciences'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanical Engineering'),
                                                        value:
                                                            'Mechanical Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanical Engineering (Refrigeration and Air Conditioning)'),
                                                        value:
                                                            'Mechanical Engineering (Refrigeration and Air Conditioning)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanical Engineering (Tool and Die)'),
                                                        value:
                                                            'Mechanical Engineering (Tool and Die)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Marine Engineering'),
                                                        value:
                                                            'Marine Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Medical Laboratory Technology'),
                                                        value:
                                                            'Medical Laboratory Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Plastic Technology'),
                                                        value:
                                                            'Plastic Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Production and Industrial Engineering'),
                                                        value:
                                                            'Production and Industrial Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Textile Design'),
                                                        value:
                                                            'Textile Design'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Textile Processing'),
                                                        value:
                                                            'Textile Processing'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Textile Technology (Spinning)'),
                                                        value:
                                                            'Textile Technology (Spinning)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Textile Technology (Weaving)'),
                                                        value:
                                                            'Textile Technology (Weaving)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Textile Technology (Knitting)'),
                                                        value:
                                                            'Textile Technology (Knitting)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Diploma in Pharmacy'),
                                                        value:
                                                            'Diploma in Pharmacy'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Modern Office Practice'),
                                                        value:
                                                            'Modern Office Practice'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Civil Engineering (PTD)'),
                                                        value:
                                                            'Civil Engineering (PTD)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electrical Engineering (PTD)'),
                                                        value:
                                                            'Electrical Engineering (PTD)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanical Engineering (PTD)'),
                                                        value:
                                                            'Mechanical Engineering (PTD)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Post Diploma in Auto and Tractors'),
                                                        value:
                                                            'Post Diploma in Auto and Tractors'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Post Diploma in CAD/CAM'),
                                                        value:
                                                            'Post Diploma in CAD/CAM'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Skilled Technician (Machinist)'),
                                                        value:
                                                            'Skilled Technician (Machinist)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Skilled Technician (Machine Maintenance)'),
                                                        value:
                                                            'Skilled Technician (Machine Maintenance)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Quality Assurance Inspector'),
                                                        value:
                                                            'Quality Assurance Inspector'),
                                                  ],
                                                  value: diplomaDegree,
                                                  hint: Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 15),
                                                      child: Text(
                                                          '$diplomaDegreeDDText')),
                                                  searchHint: "Search Degree",
                                                  onChanged: (value) {
                                                    setState(() {
                                                      diplomaDegree = value;
                                                      dDegree = value;
                                                      diplomaDegreeDDText =
                                                          value;
                                                    });
                                                  },
                                                  dialogBox: false,
                                                  isExpanded: true,
                                                  menuConstraints:
                                                      BoxConstraints.tight(
                                                          Size.fromHeight(350)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Course Name',
                                                ),
                                                controller: diplomaCourseName,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text = 'Enter Course Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.name,
                                                decoration: InputDecoration(
                                                  labelText: 'Institute Name',
                                                ),
                                                controller:
                                                    diplomaInstituteName,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Institute Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Year of Passing',
                                                ),
                                                controller:
                                                    diplomaYearOfPassing,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Passing Year or Graduation Year';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'CGPA',
                                                ),
                                                controller: diplomaCGPA,
                                                validator: (String value) {
                                                  String text;
                                                  var intvalue =
                                                      double.tryParse(value);
                                                  if (value.isEmpty) {
                                                    text = 'Enter CGPA';
                                                  } else {
                                                    if ((intvalue > 0) &&
                                                        (intvalue <= 10)) {
                                                    } else {
                                                      text = 'Enter valid CGPA';
                                                    }
                                                  }
                                                  return text;
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          //iti
                          Visibility(
                            visible: _itivisible,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Colors.grey[100]),
                                      child: CheckboxListTile(
                                        title: Text("ITI"),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: itidegreeBool,
                                        onChanged: (bool degreeiti) {
                                          setState(() {
                                            itidegreeBool = degreeiti;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (itidegreeBool)
                                    SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 15.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0,
                                                  left: 30.0,
                                                  right: 30.0),
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    bottom: 1.0),
                                                child:
                                                    SearchableDropdown.single(
                                                  isCaseSensitiveSearch: false,
                                                  items: [
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('No Degree'),
                                                        value: 'No Degree'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Draughtsman Civil'),
                                                        value:
                                                            'Draughtsman Civil'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Draughtsman Mechanical'),
                                                        value:
                                                            'Draughtsman Mechanical'),
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('Electrician'),
                                                        value: 'Electrician'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electronics Mechanic'),
                                                        value:
                                                            'Electronics Mechanic'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'IT and Electronics System Maintenance'),
                                                        value:
                                                            'IT and Electronics System Maintenance'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Instrument Mechanic'),
                                                        value:
                                                            'Instrument Mechanic'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Machinist Grinder'),
                                                        value:
                                                            'Machinist Grinder'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Motor Vehicle'),
                                                        value:
                                                            'Mechanic Motor Vehicle'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Radio and TV Mechanic'),
                                                        value:
                                                            'Radio and TV Mechanic'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Radiology Technician'),
                                                        value:
                                                            'Radiology Technician'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Insurance Agent'),
                                                        value:
                                                            'Insurance Agent'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Refrigeration and Air Conditioner Mechanic'),
                                                        value:
                                                            'Refrigeration and Air Conditioner Mechanic'),
                                                    DropdownMenuItem(
                                                        child: Text('Surveyor'),
                                                        value: 'Surveyor'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Library and Information Science'),
                                                        value:
                                                            'Library and Information Science'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Tool and Die Maker'),
                                                        value:
                                                            'Tool and Die Maker'),
                                                    DropdownMenuItem(
                                                        child: Text('Fitter'),
                                                        value: 'Fitter'),
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('Machinist'),
                                                        value: 'Machinist'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Painter (Domestic)'),
                                                        value:
                                                            'Painter (Domestic)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Painter (Industrial)'),
                                                        value:
                                                            'Painter (Industrial)'),
                                                    DropdownMenuItem(
                                                        child: Text('Turner'),
                                                        value: 'Turner'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Weaving Technician'),
                                                        value:
                                                            'Weaving Technician'),
                                                    DropdownMenuItem(
                                                        child: Text('Wireman'),
                                                        value: 'Wireman'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Foundryman Technician'),
                                                        value:
                                                            'Foundryman Technician'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Creche Management'),
                                                        value:
                                                            'Creche Management'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Spinning Technician'),
                                                        value:
                                                            'Spinning Technician'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Architectural Assistant'),
                                                        value:
                                                            'Architectural Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Auto Electrician'),
                                                        value:
                                                            'Auto Electrician'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Vessel Navigator'),
                                                        value:
                                                            'Vessel Navigator'),
                                                    DropdownMenuItem(
                                                        child: Text('Firemen'),
                                                        value: 'Firemen'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Automotive Body Repair'),
                                                        value:
                                                            'Automotive Body Repair'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Automotive Paint Repair'),
                                                        value:
                                                            'Automotive Paint Repair'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Cabin or Room Attendant'),
                                                        value:
                                                            'Cabin or Room Attendant'),
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('Spa Therapy'),
                                                        value: 'Spa Therapy'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Para Legal Assistant'),
                                                        value:
                                                            'Para Legal Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Leather Goods Maker'),
                                                        value:
                                                            'Leather Goods Maker'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Hospital Waste Management'),
                                                        value:
                                                            'Hospital Waste Management'),
                                                    DropdownMenuItem(
                                                        child: Text('Dairying'),
                                                        value: 'Dairying'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Food and Vegetable Processing'),
                                                        value:
                                                            'Food and Vegetable Processing'),
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('Carpenter'),
                                                        value: 'Carpenter'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Finance Executive'),
                                                        value:
                                                            'Finance Executive'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Computer Hardware and Networking'),
                                                        value:
                                                            'Computer Hardware and Networking'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Catering and Hospitality Assistant'),
                                                        value:
                                                            'Catering and Hospitality Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Fire Safety and Industrial Safety Management'),
                                                        value:
                                                            'Fire Safety and Industrial Safety Management'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Counseling Skills'),
                                                        value:
                                                            'Counseling Skills'),
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('GoldSmith'),
                                                        value: 'GoldSmith'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Drive Cum Mechanic (Light Motor Vehicle)'),
                                                        value:
                                                            'Drive Cum Mechanic (Light Motor Vehicle)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Preparatory School Management (Assistant)'),
                                                        value:
                                                            'Preparatory School Management (Assistant)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Surface Ornamentation Techniques'),
                                                        value:
                                                            'Surface Ornamentation Techniques'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Institution House Keeping'),
                                                        value:
                                                            'Institution House Keeping'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Dent Beating and Spray Painting'),
                                                        value:
                                                            'Dent Beating and Spray Painting'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Cane Willow and Bamboo Worker'),
                                                        value:
                                                            'Cane Willow and Bamboo Worker'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Diesel'),
                                                        value:
                                                            'Mechanic Diesel'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Marine Engine Fitter'),
                                                        value:
                                                            'Marine Engine Fitter'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Tractor'),
                                                        value:
                                                            'Mechanic Tractor'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Interior Decoration and Designing'),
                                                        value:
                                                            'Interior Decoration and Designing'),
                                                    DropdownMenuItem(
                                                        child: Text('Mason'),
                                                        value: 'Mason'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Plastic Processing Operator'),
                                                        value:
                                                            'Plastic Processing Operator'),
                                                    DropdownMenuItem(
                                                        child: Text('Plumber'),
                                                        value: 'Plumber'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Scooter and Auto Cycle Mechanic'),
                                                        value:
                                                            'Scooter and Auto Cycle Mechanic'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Sheet Metal Worker'),
                                                        value:
                                                            'Sheet Metal Worker'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Steel Fabricator'),
                                                        value:
                                                            'Steel Fabricator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Welder (Gas and Electric)'),
                                                        value:
                                                            'Welder (Gas and Electric)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Baker and Confectionery'),
                                                        value:
                                                            'Baker and Confectionery'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Commercial Art'),
                                                        value:
                                                            'Commercial Art'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Architectural Draughtsmanship'),
                                                        value:
                                                            'Architectural Draughtsmanship'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Computer Operator and Programming Assistant'),
                                                        value:
                                                            'Computer Operator and Programming Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Craftsman Food Production'),
                                                        value:
                                                            'Craftsman Food Production'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Cutting and Sewing'),
                                                        value:
                                                            'Cutting and Sewing'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Desktop Publishing Operator'),
                                                        value:
                                                            'Desktop Publishing Operator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Communication Equipment Maintenance'),
                                                        value:
                                                            'Mechanic Communication Equipment Maintenance'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Lens or Prism Grinding'),
                                                        value:
                                                            'Mechanic Lens or Prism Grinding'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Digital Photography'),
                                                        value:
                                                            'Digital Photography'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Footwear Maker'),
                                                        value:
                                                            'Footwear Maker'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Dress Making'),
                                                        value: 'Dress Making'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Resource Person'),
                                                        value:
                                                            'Resource Person'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Dress Designing'),
                                                        value:
                                                            'Dress Designing'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Dental Laboratory Equipment Technician'),
                                                        value:
                                                            'Dental Laboratory Equipment Technician'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Embroidery and Needle Work'),
                                                        value:
                                                            'Embroidery and Needle Work'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Floriculture and Landscaping'),
                                                        value:
                                                            'Floriculture and Landscaping'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Fashion Technology'),
                                                        value:
                                                            'Fashion Technology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Health and Sanitary Inspector'),
                                                        value:
                                                            'Health and Sanitary Inspector'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Stone Mining Machine Operator'),
                                                        value:
                                                            'Stone Mining Machine Operator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Hair and Skin Care'),
                                                        value:
                                                            'Hair and Skin Care'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Building Maintenance'),
                                                        value:
                                                            'Building Maintenance'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Hospital House Keeping'),
                                                        value:
                                                            'Hospital House Keeping'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Excavator Operator'),
                                                        value:
                                                            'Excavator Operator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Litho Offset Machine Minder'),
                                                        value:
                                                            'Litho Offset Machine Minder'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Physiotherapy Technician'),
                                                        value:
                                                            'Physiotherapy Technician'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Auto Electrical and Electronics'),
                                                        value:
                                                            'Mechanic Auto Electrical and Electronics'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Marine Fitter'),
                                                        value: 'Marine Fitter'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electroplater'),
                                                        value: 'Electroplater'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Office Assistant Cum Computer Operator'),
                                                        value:
                                                            'Office Assistant Cum Computer Operator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Food Beverage'),
                                                        value: 'Food Beverage'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Pump Operator Cum Mechanic'),
                                                        value:
                                                            'Pump Operator Cum Mechanic'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Basic Cosmetology'),
                                                        value:
                                                            'Basic Cosmetology'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Business Management'),
                                                        value:
                                                            'Business Management'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Agricultural Machinery'),
                                                        value:
                                                            'Mechanic Agricultural Machinery'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Secretarial Practice'),
                                                        value:
                                                            'Secretarial Practice'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Lift and Escalator Mechanic'),
                                                        value:
                                                            'Lift and Escalator Mechanic'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Health Safety and Environment'),
                                                        value:
                                                            'Health Safety and Environment'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Agro Processing'),
                                                        value:
                                                            'Agro Processing'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Mechatronics'),
                                                        value:
                                                            'Mechanic Mechatronics'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Steno English'),
                                                        value: 'Steno English'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'IT and Communication System Maintenance'),
                                                        value:
                                                            'IT and Communication System Maintenance'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Travel and Tour Assistant'),
                                                        value:
                                                            'Travel and Tour Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Human Resource Executive'),
                                                        value:
                                                            'Human Resource Executive'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Sanitary Hardware Fitter'),
                                                        value:
                                                            'Sanitary Hardware Fitter'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Mining Machinery'),
                                                        value:
                                                            'Mechanic Mining Machinery'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Rubber Technician'),
                                                        value:
                                                            'Rubber Technician'),
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('Steno Hindi'),
                                                        value: 'Steno Hindi'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Weaving (Silk and Woollen Fabric)'),
                                                        value:
                                                            'Weaving (Silk and Woollen Fabric)'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Laboratory Assistant'),
                                                        value:
                                                            'Laboratory Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text('Steward'),
                                                        value: 'Steward'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Call Centre Assistant'),
                                                        value:
                                                            'Call Centre Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Horticulture'),
                                                        value: 'Horticulture'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Old Age Care Assistant'),
                                                        value:
                                                            'Old Age Care Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Multimedia Animation and Special Effects'),
                                                        value:
                                                            'Multimedia Animation and Special Effects'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Corporate House Keeping'),
                                                        value:
                                                            'Corporate House Keeping'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Data Entry Operator'),
                                                        value:
                                                            'Data Entry Operator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Medical Transcription'),
                                                        value:
                                                            'Medical Transcription'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Domestic House Keeping'),
                                                        value:
                                                            'Domestic House Keeping'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Plate Maker Cum Impositor'),
                                                        value:
                                                            'Plate Maker Cum Impositor'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Front Office Assistant'),
                                                        value:
                                                            'Front Office Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Event Management Assistant'),
                                                        value:
                                                            'Event Management Assistant'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Office Machine Operator'),
                                                        value:
                                                            'Office Machine Operator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Tourist Guide'),
                                                        value: 'Tourist Guide'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Marketing Executive'),
                                                        value:
                                                            'Marketing Executive'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Tool & Die Maker Engineering'),
                                                        value:
                                                            'Tool & Die Maker Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Draughtsman (Mechanical) Engineering'),
                                                        value:
                                                            'Draughtsman (Mechanical) Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Diesel Mechanic Engineering'),
                                                        value:
                                                            'Diesel Mechanic Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Draughtsman (Civil) Engineering'),
                                                        value:
                                                            'Draughtsman (Civil) Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Pump Operator'),
                                                        value: 'Pump Operator'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Fitter Engineering'),
                                                        value:
                                                            'Fitter Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Motor Driving-cum-Mechanic Engineering'),
                                                        value:
                                                            'Motor Driving-cum-Mechanic Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Turner Engineering'),
                                                        value:
                                                            'Turner Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Dress Making'),
                                                        value: 'Dress Making'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Manufacture Foot Wear'),
                                                        value:
                                                            'Manufacture Foot Wear'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Information Technology & E.S.M. Engineering'),
                                                        value:
                                                            'Information Technology & E.S.M. Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Secretarial Practice'),
                                                        value:
                                                            'Secretarial Practice'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Machinist Engineering'),
                                                        value:
                                                            'Machinist Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Hair & Skin Care'),
                                                        value:
                                                            'Hair & Skin Care'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Refrigeration Engineering'),
                                                        value:
                                                            'Refrigeration Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Fruit & Vegetable Processing'),
                                                        value:
                                                            'Fruit & Vegetable Processing'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mech. Instrument Engineering'),
                                                        value:
                                                            'Mech. Instrument Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Bleaching & Dyeing Calico Print'),
                                                        value:
                                                            'Bleaching & Dyeing Calico Print'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Electrician Engineering'),
                                                        value:
                                                            'Electrician Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Letter Press Machine Minder'),
                                                        value:
                                                            'Letter Press Machine Minder'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Commercial Art'),
                                                        value:
                                                            'Commercial Art'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Leather Goods Maker'),
                                                        value:
                                                            'Leather Goods Maker'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Motor Vehicle Engineering'),
                                                        value:
                                                            'Mechanic Motor Vehicle Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Hand Compositor'),
                                                        value:
                                                            'Hand Compositor'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Radio & T.V. Engineering'),
                                                        value:
                                                            'Mechanic Radio & T.V. Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Electronics Engineering'),
                                                        value:
                                                            'Mechanic Electronics Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Surveyor Engineering'),
                                                        value:
                                                            'Surveyor Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Foundry Man Engineering'),
                                                        value:
                                                            'Foundry Man Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Sheet Metal Worker Engineering'),
                                                        value:
                                                            'Sheet Metal Worker Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'The weaving of Fancy Fabric'),
                                                        value:
                                                            'The weaving of Fancy Fabric'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Wireman Engineering'),
                                                        value:
                                                            'Wireman Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Cutting & Sewing'),
                                                        value:
                                                            'Cutting & Sewing'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Pattern Maker Engineering'),
                                                        value:
                                                            'Pattern Maker Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Plumber Engineering'),
                                                        value:
                                                            'Plumber Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Welder (Gas & Electric) Engineering'),
                                                        value:
                                                            'Welder (Gas & Electric) Engineering'),
                                                    DropdownMenuItem(
                                                        child:
                                                            Text('Book Binder'),
                                                        value: 'Book Binder'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Carpenter Engineering'),
                                                        value:
                                                            'Carpenter Engineering'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Embroidery & Needle Worker'),
                                                        value:
                                                            'Embroidery & Needle Worker'),
                                                    DropdownMenuItem(
                                                        child: Text(
                                                            'Mechanic Tractor'),
                                                        value:
                                                            'Mechanic Tractor'),
                                                  ],
                                                  value: itiDegree,
                                                  hint: Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 15),
                                                      child: Text(
                                                          '$itiDegreeDDText')),
                                                  searchHint: "Search Degree",
                                                  // doneButton: "Save",
                                                  // closeButton:
                                                  //     SizedBox.shrink(),
                                                  onChanged:
                                                      (String valueItiDegree) {
                                                    itiDegreeDDText =
                                                        valueItiDegree;
                                                    setState(() {
                                                      itiDegree =
                                                          valueItiDegree;
                                                    });
                                                  },
                                                  dialogBox: false,
                                                  isExpanded: true,
                                                  menuConstraints:
                                                      BoxConstraints.tight(
                                                          Size.fromHeight(350)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Course Name',
                                                ),
                                                controller: itiCourseName,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text = 'Enter Course Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.name,
                                                decoration: InputDecoration(
                                                  labelText: 'Institute Name',
                                                ),
                                                controller: itiInstituteName,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Institute Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Year of Passing',
                                                ),
                                                controller: itiYearOfPassing,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Passing Year or Graduation Year';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'CGPA',
                                                ),
                                                controller: itiCGPA,
                                                validator: (value) {
                                                  String text;
                                                  var intvalue =
                                                      double.tryParse(value);
                                                  if (value.isEmpty) {
                                                    text = 'Enter CGPA';
                                                  } else {
                                                    if ((intvalue > 0) &&
                                                        (intvalue <= 10)) {
                                                    } else {
                                                      text = 'Enter valid CGPA';
                                                    }
                                                  }
                                                  return text;
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          //graduate
                          Visibility(
                            visible: _undergvisible,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Colors.grey[100]),
                                      child: CheckboxListTile(
                                        title: Text("Under Graduate/ Graduate"),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: graduatedegreeBool,
                                        onChanged: (bool degreeEdu) {
                                          setState(() {
                                            graduatedegreeBool = degreeEdu;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (graduatedegreeBool)
                                    SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 15.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0,
                                                  left: 30.0,
                                                  right: 30.0),
                                              child: DropdownButtonFormField(
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 15.0)),
                                                isExpanded: true,
                                                value: graduationDegree,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 16,
                                                ),
                                                hint: Text(
                                                    '$graduationDegreeDDText'),
                                                onChanged: (String
                                                    valueGraduationDegree) {
                                                  setState(() {
                                                    graduationDegreeDDText =
                                                        valueGraduationDegree;
                                                    graduationDegree =
                                                        valueGraduationDegree;
                                                  });
                                                },
                                                items: [
                                                  DropdownMenuItem(
                                                      child: Text('No Degree'),
                                                      value: 'No Degree'),
                                                  DropdownMenuItem(
                                                      child:
                                                          Text('B.E./B.Tech'),
                                                      value: 'B.E./B.Tech'),
                                                  DropdownMenuItem(
                                                      child: Text(
                                                          'B.Com/B.Com(Hons.)'),
                                                      value:
                                                          'B.Com/B.Com(Hons.)'),
                                                  DropdownMenuItem(
                                                      child: Text(
                                                          'B.Sc./B.Sc.(Hons.)'),
                                                      value:
                                                          'B.Sc./B.Sc.(Hons.)'),
                                                  DropdownMenuItem(
                                                      child: Text(
                                                          'B.C.A/B.C.A(Hons.)'),
                                                      value:
                                                          'B.C.A/B.C.A(Hons.)'),
                                                  DropdownMenuItem(
                                                      child: Text(
                                                          'B.A./B.A.(Hons.)'),
                                                      value:
                                                          'B.A./B.A.(Hons.)'),
                                                  DropdownMenuItem(
                                                      child:
                                                          Text('BBA/BBM/BMS'),
                                                      value: 'BBA/BBM/BMS'),
                                                  DropdownMenuItem(
                                                      child: Text('B.Pharm'),
                                                      value: 'B.Pharm'),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Course Name',
                                                ),
                                                controller:
                                                    graduationCourseName,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text = 'Enter Course Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.name,
                                                decoration: InputDecoration(
                                                  labelText: 'Institute Name',
                                                ),
                                                controller:
                                                    graduationInstituteName,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Institute Name';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Graduation Year / Year of Passing',
                                                ),
                                                controller:
                                                    graduationYearOfPassing,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Passing Year or Graduation Year';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'CGPA',
                                                ),
                                                controller: graduationCGPA,
                                                validator: (String value) {
                                                  String text;
                                                  var intvalue =
                                                      double.tryParse(value);
                                                  if (value.isEmpty) {
                                                    text = 'Enter CGPA';
                                                  } else {
                                                    if ((intvalue > 0) &&
                                                        (intvalue <= 10)) {
                                                    } else {
                                                      text = 'Enter valid CGPA';
                                                    }
                                                  }
                                                  return text;
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          //post graduate
                          Visibility(
                            visible: _postgvisible,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Colors.grey[100]),
                                      child: CheckboxListTile(
                                        title: Text("Post Graduate"),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: postgraduatedegreeBool,
                                        onChanged: (bool degreeEdu) {
                                          setState(() {
                                            postgraduatedegreeBool = degreeEdu;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (postgraduatedegreeBool)
                                    SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 15.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0,
                                                  left: 30.0,
                                                  right: 30.0),
                                              child: DropdownButtonFormField(
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 15.0)),
                                                isExpanded: true,
                                                value: postGraduationDegree,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 16,
                                                ),
                                                hint: Text(
                                                    '$postGraduationDegreeDDText'),
                                                onChanged: (String
                                                    valuePostGraduationDegree) {
                                                  setState(() {
                                                    postGraduationDegreeDDText =
                                                        valuePostGraduationDegree;
                                                    postGraduationDegree =
                                                        valuePostGraduationDegree;
                                                  });
                                                },
                                                items: [
                                                  DropdownMenuItem(
                                                      child:
                                                          Text('M.E./M.Tech.'),
                                                      value: 'M.E./M.Tech.'),
                                                  DropdownMenuItem(
                                                      child: Text('M.Com.'),
                                                      value: 'M.Com.'),
                                                  DropdownMenuItem(
                                                      child: Text('M.Sc./MS'),
                                                      value: 'M.Sc./MS'),
                                                  DropdownMenuItem(
                                                      child:
                                                          Text('M.C.A/PGDCA'),
                                                      value: 'M.C.A/PGDCA'),
                                                  DropdownMenuItem(
                                                      child: Text('M.A.'),
                                                      value: 'M.A.'),
                                                  DropdownMenuItem(
                                                      child: Text(
                                                          'MBA/PGDM/PGPM/PGDBM/PGDBA'),
                                                      value:
                                                          'MBA/PGDM/PGPM/PGDBM/PGDBA'),
                                                  DropdownMenuItem(
                                                      child: Text('M.Pharm'),
                                                      value: 'M.Pharm'),
                                                  DropdownMenuItem(
                                                      child: Text('CA/CMA/CFA'),
                                                      value: 'CA/CMA/CFA'),
                                                  DropdownMenuItem(
                                                      child: Text('Other'),
                                                      value: 'other'),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Course Name',
                                                ),
                                                controller:
                                                    postGraduationCourseName,
                                                validator: (value) =>
                                                    value.isEmpty
                                                        ? 'Enter course name'
                                                        : null,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.name,
                                                decoration: InputDecoration(
                                                  labelText: 'Institute Name',
                                                ),
                                                controller:
                                                    postGraduationInstituteName,
                                                validator: (value) =>
                                                    value.isEmpty
                                                        ? 'Enter Institute Name'
                                                        : null,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Year of Passing',
                                                ),
                                                controller:
                                                    postGraduationYearOfPassing,
                                                validator: (String value) {
                                                  String text;
                                                  if (value.isEmpty) {
                                                    text =
                                                        'Enter Graduation Year';
                                                  }
                                                  return text;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'CGPA',
                                                ),
                                                controller: postGraduationCGPA,
                                                validator: (String value) {
                                                  String text;
                                                  var intvalue =
                                                      double.tryParse(value);
                                                  if (value.isEmpty) {
                                                    text = 'Enter CGPA';
                                                  } else {
                                                    if ((intvalue > 0) &&
                                                        (intvalue <= 10)) {
                                                    } else {
                                                      text = 'Enter valid CGPA';
                                                    }
                                                  }
                                                  return text;
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          //skills
                          Visibility(
                            visible: _skillsvisible,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Colors.grey[100]),
                                      child: CheckboxListTile(
                                        title: Text("Professional Information"),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: skills,
                                        onChanged: (bool skillsTech) {
                                          setState(() {
                                            skills = skillsTech;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (skills)
                                    SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            bottom: 15.0, left: 30, right: 30),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  right: 30.0,
                                                  top: 10.0),
                                            ),
                                            alreadyHaveSkills
                                                ? Wrap(
                                                    children: [
                                                      for (var i = 0;
                                                          i <
                                                              newSkillList
                                                                  .length;
                                                          i++)
                                                        Card(
                                                            elevation: 3.0,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            color: Colors
                                                                .blue[300],
                                                            child: Container(
                                                              child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 4.0,
                                                                      bottom:
                                                                          11.0,
                                                                      left: 7.0,
                                                                      right:
                                                                          7.0),
                                                                  child:
                                                                      RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                            text:
                                                                                '${newSkillList[i]}',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 15.0,
                                                                                color: Colors.black.withOpacity(0.6))),
                                                                        WidgetSpan(
                                                                          child:
                                                                              IconButton(
                                                                            constraints:
                                                                                BoxConstraints(),
                                                                            alignment:
                                                                                Alignment.bottomRight,
                                                                            padding:
                                                                                EdgeInsets.only(left: 7.0, top: 5.0),
                                                                            iconSize:
                                                                                18,
                                                                            icon:
                                                                                Icon(Icons.close),
                                                                            color:
                                                                                Color(0xffF1F1F1),
                                                                            onPressed:
                                                                                () {
                                                                              newSkillList.removeAt(i);
                                                                              setState(() {
                                                                                newSkillList = newSkillList;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                            ))
                                                    ],
                                                  )
                                                : Container(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  right: 30.0,
                                                  top: 10.0),
                                              child: Container(
                                                  padding: EdgeInsets.only(
                                                      bottom: 1.0),
                                                  child: TextField(
                                                    controller: newSkillText,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Enter your skills here',
                                                      suffixIcon: IconButton(
                                                        icon: Icon(
                                                            Icons.add_outlined),
                                                        onPressed: () {
                                                          var newSkill =
                                                              newSkillText.text;
                                                          if (newSkill == "") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Enter your skill",
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER);
                                                          } else {
                                                            if (alreadyHaveSkills ==
                                                                false) {
                                                              setState(() =>
                                                                  alreadyHaveSkills =
                                                                      true);
                                                            }
                                                            newSkill =
                                                                newSkill.trim();
                                                            newSkillList
                                                                .add(newSkill);
                                                            setState(() {
                                                              newSkillText
                                                                  .text = "";
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            //work experience
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  right: 30.0,
                                                  top: 10.0),
                                              child: DropdownButtonFormField(
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 15.0)),
                                                isExpanded: true,
                                                value: workBackground,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 16,
                                                ),
                                                hint: Text(
                                                    '$workExperienceDDText'),
                                                items: [
                                                  DropdownMenuItem(
                                                      child:
                                                          Text('No Expierence'),
                                                      value: 'No Expierence'),
                                                  DropdownMenuItem(
                                                      child: Text(
                                                          'Less than 1 Year'),
                                                      value:
                                                          'Less than 1 Year'),
                                                  DropdownMenuItem(
                                                      child: Text('1-3 Years'),
                                                      value: '1-3 Years'),
                                                  DropdownMenuItem(
                                                      child: Text('3-5 Years'),
                                                      value: '3-5 Years'),
                                                  DropdownMenuItem(
                                                      child: Text('5-8 Years'),
                                                      value: '5-8 Years'),
                                                  DropdownMenuItem(
                                                      child: Text('8-15 Years'),
                                                      value: '8-15 Years'),
                                                  DropdownMenuItem(
                                                      child: Text(
                                                          'More than 15 Years'),
                                                      value:
                                                          'More than 15 Years'),
                                                ],
                                                onChanged: (String
                                                    selectedBackground) {
                                                  setState(() {
                                                    workExperience =
                                                        selectedBackground;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          _buildAddButton(),
                          _buildSaveButton(),
                          // _modal()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            finalLoader
                ? Container()
                : Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.2 * (MediaQuery.of(context).size.height / 20),
          //width: 4.5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 20, top: 20.0),
          child: RaisedButton(
            elevation: 6.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: mainColor)),
            onPressed: () {
              _settingModalBottomSheet(context);
            },
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: mainColor,
                ),
                Text(
                  "Add Education",
                  style: TextStyle(
                    color: mainColor,
                    letterSpacing: 1.2,
                    fontSize: MediaQuery.of(context).size.height / 55,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: new ListTile(
                        title: new Text('HSSC'),
                        onTap: () {
                          if (hscAvailable == false) {
                            setState(() {
                              _hscvisible = !_hscvisible;
                              high_edu = _hscvisible;
                            });
                          } else {
                            setState(() {
                              _hscvisible = !_hscvisible;
                              high_edu = _hscvisible;
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: new ListTile(
                        title: new Text('ITI'),
                        onTap: () {
                          if (iAvailable == false) {
                            setState(() {
                              _itivisible = !_itivisible;
                              itidegreeBool = _itivisible;
                            });
                          } else {
                            setState(() {
                              _itivisible = !_itivisible;
                              itidegreeBool = _itivisible;
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: new ListTile(
                        title: new Text('Diploma'),
                        onTap: () {
                          if (dAvailable == false) {
                            setState(() {
                              _diplomavisible = !_diplomavisible;
                              diplomadegreeBool = _diplomavisible;
                            });
                          } else {
                            setState(() {
                              _diplomavisible = !_diplomavisible;
                              diplomadegreeBool = _diplomavisible;
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: new ListTile(
                        title: new Text('Under Graduate /  Graduate'),
                        onTap: () {
                          if (gAvailable == false) {
                            setState(() {
                              _undergvisible = !_undergvisible;
                              graduatedegreeBool = _undergvisible;
                            });
                          } else {
                            setState(() {
                              _undergvisible = !_undergvisible;
                              graduatedegreeBool = _undergvisible;
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: new ListTile(
                        title: new Text('Post Graduate'),
                        onTap: () {
                          if (pgAvailable == false) {
                            setState(() {
                              _postgvisible = !_postgvisible;
                              postgraduatedegreeBool = _postgvisible;
                            });
                          } else {
                            setState(() {
                              _postgvisible = !_postgvisible;
                              postgraduatedegreeBool = _postgvisible;
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: new ListTile(
                        title: new Text('Skills and Work Experience'),
                        onTap: () {
                          if (proAvailable == false) {
                            setState(() {
                              _skillsvisible = !_skillsvisible;
                              skills = true;
                            });
                          } else {
                            setState(() {
                              _skillsvisible = !_skillsvisible;
                              skills = true;
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        isLoading == true
            ? Padding(
                padding: const EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              )
            : Container(
                height: 1.2 * (MediaQuery.of(context).size.height / 20),
                width: 5 * (MediaQuery.of(context).size.width / 10),
                margin: EdgeInsets.only(bottom: 20, top: 20.0),
                child: RaisedButton(
                  elevation: 5.0,
                  color: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      postUserProfile();
                    } else {
                      autovalidateMode = AutovalidateMode.always;
                      showAlertDia(context, 'Incomplete Form',
                          'Complete all the fields of selected Educational Details');
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontSize: MediaQuery.of(context).size.height / 30,
                    ),
                  ),
                ),
              )
      ],
    );
  }

  var seekerDetailsJson;
  SeekerDetails seekerDetails;
  var jsonGetProfile;
  var oSkills = [];
  List<String> someskills = [];
  var sharedProfile = false;
  var sscAvailable = true,
      hscAvailable = true,
      iAvailable = true,
      dAvailable = true,
      gAvailable = true,
      pgAvailable = true,
      proAvailable = true;
  var oldSkills;
  var seekerId;
  getUserProfile() async {
    sharedEmail = userEmail;
    sharedToken = userToken;
    String getProfileUrl = allApis.getUserProfile + sharedEmail;

    try {
      http.Response response = await http
          .get(getProfileUrl, headers: <String, String>{'token': sharedToken});
      var getResponseFromServer = response.body;
      jsonGetProfile = json.decode(getResponseFromServer);
      seekerDetailsJson = jsonGetProfile['seeker_details'];
      var educationalDetailJson = jsonGetProfile['educational_details'];
      seekerExperience = jsonGetProfile['seeker_exp'];
      seekerSkillsList = jsonGetProfile['seeker_skills'];
      oldSkills = jsonGetProfile['seeker_skills'];
      seekerId = seekerDetailsJson['id'];
      if (seekerDetailsJson != null) {
        seekerDetails = new SeekerDetails.fromJson(seekerDetailsJson);
        firstnameCon..text = seekerDetails.firstname;
        lastnameCon..text = seekerDetails.lastname;
        mobileCon..text = seekerDetails.mobile;
        emailCon..text = seekerDetails.email;
        if (seekerDetails.address != "null") {
          addressCon..text = seekerDetails.address;
        }
        if (seekerDetails.postal != "null") {
          postalCon..text = seekerDetails.postal;
        }
        if (seekerDetails.image != "") {
          profilePicUrl = seekerDetails.image;
          setState(() {
            hasProfilePic = true;
            profilePicUrl = seekerDetails.image;
          });
        } else {
          setState(() => hasProfilePic = false);
        }
        if (seekerDetails.background != '') {
          backgroundDDText = seekerDetails.background;
        } else {
          backgroundDDText = 'Select Background';
        }
        if (seekerDetails.country != null) {
          getCountryName(seekerDetails.country);
          if (seekerDetails.state != null) {
            setState(() {
              countrySelected = true;
            });
            getStateName(seekerDetails.country, seekerDetails.state);
            fetchedStatetId = seekerDetails.state;
            setState(() {
              stateSelected = true;
            });

            if (seekerDetails.city != null) {
              setState(() {
                stateSelected = true;
              });
              fetchedCityId = seekerDetails.city;
              getCityName(seekerDetails.state, seekerDetails.city);
            } else {
              if (seekerDetails.state != null) {
                setState(() {
                  stateSelected = false;
                });
                _getCityList(seekerDetails.state);
              }
            }
          } else {
            setState(() {
              countrySelected = true;
            });
            _getStatesList(seekerDetails.country);
          }
        } else {
          getCountryList();
          setState(() {
            countrySelected = false;
            stateSelected = false;
          });
        }
      }

      if (educationalDetailJson.length != 0) {
        var sscData = educationalDetailJson['ssc'];
        if (sscData != null) {
          secEdu = false;
          sscAvailable = true;
          sscEduFieldsOld = sscData['edu_fields'];
          var inst = sscData['institute_name'];
          var board = sscData['course'];
          var percentage = sscData['marks'];
          var yop = sscData['passing_year'];
          setState(() {
            sscInstituteName..text = inst;
            sscBoard..text = board;
            sscPercentage..text = percentage;
            sscYearOfPassing..text = yop;
          });
        } else {
          sscAvailable = false;
        }
        var hscData = educationalDetailJson['hsc'];
        if (hscData != null) {
          hscAvailable = true;
          _hscvisible = true;
          hscEduFieldsOld = hscData['edu_fields'];
          var inst = hscData['institute_name'];
          var board = hscData['course'];
          var percentage = hscData['marks'];
          var yop = hscData['passing_year'];
          setState(() {
            hscInstituteName..text = inst;
            hscBoard..text = board;
            hscPercentage..text = percentage;
            hscYearOfPassing..text = yop;
          });
        } else {
          hscAvailable = false;
        }

        var diplomaData = educationalDetailJson['diploma'];
        if (diplomaData != null) {
          dAvailable = true;
          _diplomavisible = true;
          diplomaEduFieldsOld = diplomaData['edu_fields'];
          var inst = diplomaData['institute_name'];
          var degree = diplomaData['degree'];
          var course = diplomaData['course'];
          var percentage = diplomaData['marks'];
          var yop = diplomaData['passing_year'];
          setState(() {
            diplomaDegreeDDText = degree;
            diplomaCourseName..text = course;
            diplomaInstituteName..text = inst;
            diplomaCGPA..text = percentage;
            diplomaYearOfPassing..text = yop;
          });
        } else {
          dAvailable = false;
        }
        var itiData = educationalDetailJson['iti'];
        if (itiData != null) {
          iAvailable = true;
          _itivisible = true;
          itiEduFieldsOld = itiData['edu_fields'];
          var inst = itiData['institute_name'];
          var degree = itiData['degree'];
          var course = itiData['course'];
          var percentage = itiData['marks'];
          var yop = itiData['passing_year'];
          setState(() {
            itiDegreeDDText = degree;
            itiCourseName..text = course;
            itiInstituteName..text = inst;
            itiCGPA..text = percentage;
            itiYearOfPassing..text = yop;
          });
        } else {
          iAvailable = false;
        }
        var graduateData = educationalDetailJson['graduation'];
        if (graduateData != null) {
          gAvailable = true;
          _undergvisible = true;
          graduateEduFieldsOld = graduateData['edu_fields'];
          var inst = graduateData['institute_name'];
          var degree = graduateData['degree'];
          var course = graduateData['course'];
          var percentage = graduateData['marks'];
          var yop = graduateData['passing_year'];
          setState(() {
            graduationDegreeDDText = degree;
            graduationCourseName..text = course;
            graduationInstituteName..text = inst;
            graduationCGPA..text = percentage;
            graduationYearOfPassing..text = yop;
          });
        } else {
          gAvailable = false;
        }
        var postGraduateData = educationalDetailJson['post_graduation'];
        if (postGraduateData != null) {
          pgAvailable = true;
          _postgvisible = true;
          postGraduateEduFieldsOld = postGraduateData['edu_fields'];
          var inst = postGraduateData['institute_name'];
          var degree = postGraduateData['degree'];
          var course = postGraduateData['course'];
          var percentage = postGraduateData['marks'];
          var yop = postGraduateData['passing_year'];
          setState(() {
            postGraduationDegreeDDText = degree;
            postGraduationCourseName..text = course;
            postGraduationInstituteName..text = inst;
            postGraduationCGPA..text = percentage;
            postGraduationYearOfPassing..text = yop;
          });
        } else {
          pgAvailable = false;
        }
      } else {}

      if ((seekerSkillsList.length != 0) || (seekerExperience.length != 0)) {
        proAvailable = true;
        _skillsvisible = true;
        if (seekerSkillsList.length != 0) {
          if (seekerSkillsList[0]['skills'] != "") {
            newSkillList = (seekerSkillsList[0]['skills']).split(",");
          }
          setState(() => alreadyHaveSkills = true);
        }
        if (seekerExperience != null) {
          setState(() {
            workExperienceDDText = seekerExperience[0]['exp'];
            exid = seekerExperience[0]['id'];
          });
          if ((seekerExperience[0]['exp'] == 'Work Experience') &&
              (seekerSkillsList[0]['skills'] == "")) {
              proAvailable = false;
              _skillsvisible = false;
              workExperienceDDText = 'Select Experience';
          }
        } else {
          workExperienceDDText = 'Select Experience';
        }
      } else {
        proAvailable = false;
      }
      setState(() => finalLoader = true);
    } catch (e) {
      setState(() => finalLoader = true);
      Fluttertoast.showToast(
          msg: "Something went wrong. Please try again later.");
    }
  }

  postUserProfile() async {
    setState(() {
      isLoading = true;
    });
    bool pg = true, g = true, i = true, d = true;
    var iDegreeDD, dDegreeDD, gDegreeDD, pgDegreeDD;
    if (itidegreeBool == true) {
      if ((itiDegreeDDText == "Degree*") && (itiDegree == null)) {
        i = false;
      } else if ((itiDegreeDDText != "Degree*") || (itiDegree != null)) {
        i = true;
        if (itiDegreeDDText != "Degree*") {
          iDegreeDD = itiDegreeDDText;
        } else {
          iDegreeDD = itiDegree;
        }
      }
    }
    if (diplomadegreeBool == true) {
      if ((diplomaDegreeDDText == "Degree*") && (dDegree == null)) {
        d = false;
      } else if ((diplomaDegreeDDText != "Degree*") || (dDegree != null)) {
        d = true;
        if (diplomaDegreeDDText != "Degree*") {
          dDegreeDD = diplomaDegreeDDText;
        } else {
          dDegreeDD = dDegree;
        }
      }
    }
    if (graduatedegreeBool == true) {
      if ((graduationDegreeDDText == "Degree*") && (gDegree == null)) {
        g = false;
      } else if ((graduationDegreeDDText != "Degree*") || (gDegree != null)) {
        g = true;
        if (graduationDegreeDDText != "Degree*") {
          gDegreeDD = graduationDegreeDDText;
        } else {
          gDegreeDD = gDegree;
        }
      }
    }
    if (postgraduatedegreeBool == true) {
      if ((postGraduationDegreeDDText == "Degree*") && (pgDegree == null)) {
        pg = false;
      } else if ((postGraduationDegreeDDText != "Degree*") ||
          (pgDegree != null)) {
        pg = true;
        if (postGraduationDegreeDDText != "Degree*") {
          pgDegreeDD = postGraduationDegreeDDText;
        } else {
          pgDegreeDD = pgDegree;
        }
      }
    }
    Fluttertoast.showToast(msg: 'Saving Your Profile');

    try {
      String completeLoginApi =
          allApis.login + "?email=" + userEmail + "&password=" + userPassword;
      http.Response response = await http.get(completeLoginApi);
      String loginResponseFromServer = response.body;
      var jsonParseLogin = json.decode(loginResponseFromServer);
      var eduFieldsLogin = new List<int>();
      var idFromLogin = new List<int>();
      var education = jsonParseLogin['education'];
      if (education.length != 0) {
        for (var i = 0; i < education.length; i++) {
          eduFieldsLogin.add(jsonDecode((education[i]['edu_fields'])));
          idFromLogin.add(jsonDecode((education[i]['id'])));
        }
      }
      for (var j = 0; j < education.length; j++) {
        var sscId;
        if (sscEduFieldsOld != null) {
          sscId = int.parse(sscEduFieldsOld);
        }
        var hscId;
        if (hscEduFieldsOld != null) {
          hscId = int.parse(hscEduFieldsOld);
        }
        var itiId;
        if (itiEduFieldsOld != null) {
          itiId = int.parse(itiEduFieldsOld);
        }
        var dId;
        if (diplomaEduFieldsOld != null) {
          dId = int.parse(diplomaEduFieldsOld);
        }
        var gId;
        if (graduateEduFieldsOld != null) {
          gId = int.parse(graduateEduFieldsOld);
        }
        var pgId;
        if (postGraduateEduFieldsOld != null) {
          pgId = int.parse(postGraduateEduFieldsOld);
        }
        if (sscId == eduFieldsLogin[j]) {
          sscEduFieldsNew = idFromLogin[j];
        } else if (hscId == eduFieldsLogin[j]) {
          hscEduFieldsNew = idFromLogin[j];
        } else if (itiId == eduFieldsLogin[j]) {
          itiEduFieldsNew = idFromLogin[j];
        } else if (dId == eduFieldsLogin[j]) {
          diplomaEduFieldsNew = idFromLogin[j];
        } else if (gId == eduFieldsLogin[j]) {
          graduateEduFieldsNew = idFromLogin[j];
        } else if (pgId == eduFieldsLogin[j]) {
          postGraduateEduFieldsNew = idFromLogin[j];
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "something went wrong");
    }

    if (pg == true && g == true && i == true && d == true) {
      var sid, hid, iid, did, gid, pgid;
      sid = sscEduFieldsNew;
      hid = hscEduFieldsNew;
      iid = itiEduFieldsNew;
      did = diplomaEduFieldsNew;
      gid = graduateEduFieldsNew;
      pgid = postGraduateEduFieldsNew;
      exid = exid;
      eFirstname = firstnameCon.text;
      eLastname = lastnameCon.text;
      eMobile = mobileCon.text;
      eEmail = emailCon.text;
      if (myCountry != null) {
        eCountry = myCountry;
      } else {
        eCountry = seekerDetails.country;
      }
      if (myState != null) {
        eState = myState;
      } else if (myState == null) {
        if (stateDDText != "Select State") {
          eState = seekerDetails.state;
        } else if (stateDDText == "Select State") {
          eState = myState;
        }
      }
      if (myCity != null) {
        eCity = myCity;
      } else {
        if (cityDDText != "Select City") {
          eCity = seekerDetails.city;
        } else if (cityDDText == "Select City") {
          eCity = myCity;
        }
      }

      eAddress = addressCon.text;
      ePostal = postalCon.text;
      if (backgroundDDText != "Select Background") {
        eBackground = backgroundDDText;
      } else if (backgroundDDText == "Select Background") {
        eBackground = userBackground;
      }
      if (secEdu == false) {
        sInstituteName = null;
        sBoard = null;
        sPercentage = null;
        sYearOfPassing = null;
      } else {
        sInstituteName = sscInstituteName.text;
        sBoard = sscBoard.text;
        sPercentage = sscPercentage.text;
        sYearOfPassing = sscYearOfPassing.text;
      }
      if (high_edu == false) {
        hInstituteName = null;
        hBoard = null;
        hPercentage = null;
        hYearOfPassing = null;
      } else {
        hInstituteName = hscInstituteName.text;
        hBoard = hscBoard.text;
        hPercentage = hscPercentage.text;
        hYearOfPassing = hscYearOfPassing.text;
      }
      if (diplomadegreeBool == false) {
        dDegree = null;
        dCourseName = null;
        dInstituteName = null;
        dYearOfPassing = null;
        dCGPA = null;
      } else {
        dDegree = dDegreeDD;
        dCourseName = diplomaCourseName.text;
        dInstituteName = diplomaInstituteName.text;
        dYearOfPassing = diplomaYearOfPassing.text;
        dCGPA = diplomaCGPA.text;
      }
      if (itidegreeBool == false) {
        iDegree = null;
        iCourseName = null;
        iInstituteName = null;
        iYearOfPassing = null;
        iCGPA = null;
      } else {
        iDegree = iDegreeDD;
        iCourseName = itiCourseName.text;
        iInstituteName = itiInstituteName.text;
        iYearOfPassing = itiYearOfPassing.text;
        iCGPA = itiCGPA.text;
      }
      if (graduatedegreeBool == false) {
        gDegree = null;
        gCourseName = null;
        gInstituteName = null;
        gYearOfPassing = null;
        gCGPA = null;
      } else {
        gDegree = gDegreeDD;
        gCourseName = graduationCourseName.text;
        gInstituteName = graduationInstituteName.text;
        gYearOfPassing = graduationYearOfPassing.text;
        gCGPA = graduationCGPA.text;
      }
      if (postgraduatedegreeBool == false) {
        pgDegree = null;
        pgCourseName = null;
        pgInstituteName = null;
        pgYearOfPassing = null;
        pgCGPA = null;
      } else {
        pgDegree = pgDegreeDD;
        pgCourseName = postGraduationCourseName.text;
        pgInstituteName = postGraduationInstituteName.text;
        pgYearOfPassing = postGraduationYearOfPassing.text;
        pgCGPA = postGraduationCGPA.text;
      }

      if (secEdu == true ||
          high_edu == true ||
          diplomadegreeBool == true ||
          itidegreeBool == true ||
          graduatedegreeBool == true ||
          postgraduatedegreeBool == true) {
        educationalDetailsBool = true;
      } else {
        educationalDetailsBool = false;
      }

      Map exper;
      var currentExp;
      List oldSkillsId = [];
      if (showSkills != null) {
        for (var i = 0; i < showSkills.length; i++) {
          oldSkillsId.add(showSkills[i]['id']);
        }
      }

      List<String> currentSelectedMember =
          currenSelectedSkills.map((el) => el.toString()).toList();
      List updatedSkills = oldSkillsId + currentSelectedMember;
      var distinctList = updatedSkills.toSet().toList();
      distinctList.sort();
      sendSkills = [];
      exp = [];
      var someskilll;
      if (skills == true) {
        someskills = [];
        someskilll = newSkillList.join(",");
        jsonEncode(someskills);
        if ((workExperienceDDText == "Select Experience") &&
            (workExperience == null)) {
          showAlertDia(
              context, "Select Experience", "Select your current experience");
        } else if ((workExperienceDDText != "Select Experience") ||
            (workExperience != null)) {
          if ((skills == true) && (workExperience != null)) {
            currentExp = workExperience;
          } else if ((skills == true) && (workExperience == null)) {
            currentExp = workExperienceDDText;
          }
        }
      } else if (skills == false) {
        someskills = [];
        someskills = oldSkills;
      }
      exper = {};
      if (exid == null) {
        exper = {"exp": currentExp, "seeker": studentId};
      } else if (exid != null) {
        exper = {"id": exid, "exp": currentExp, "seeker": studentId};
      }
      if (skills == true) {
        exp.add(exper);
      }

      connectivityResult = await (Connectivity().checkConnectivity());
      if ((connectivityResult == ConnectivityResult.mobile) ||
          (connectivityResult == ConnectivityResult.wifi)) {
        if (await DataConnectionChecker().hasConnection) {
          setState(() => isLoading = true);

          Map seekerJson = {
            "id": studentId,
            "firstname": eFirstname,
            "lastname": eLastname,
            "email": eEmail,
            "mobile": eMobile,
            "city": eCity,
            "state": eState,
            "country": eCountry,
            "address": eAddress,
            "postal": ePostal,
            "college": 'null',
            "background": eBackground
          };

          Map sscJson;
          if (sid == null) {
            sscJson = {
              "course": sBoard,
              "degree": null,
              "done": secEdu,
              "institute_name": sInstituteName,
              "marks": sPercentage,
              "passing_year": sYearOfPassing,
            };
          } else {
            sscJson = {
              "id": sid,
              "edu_fields": sid,
              "course": sBoard,
              "degree": null,
              "done": secEdu,
              "institute_name": sInstituteName,
              "marks": sPercentage,
              "passing_year": sYearOfPassing,
            };
          }
          Map hscJson;
          if (hid == null) {
            hscJson = {
              "course": hBoard,
              "degree": null,
              "done": high_edu,
              "institute_name": hInstituteName,
              "marks": hPercentage,
              "passing_year": hYearOfPassing,
            };
          } else {
            hscJson = {
              "id": hid,
              "edu_fields": hid,
              "course": hBoard,
              "degree": null,
              "done": high_edu,
              "institute_name": hInstituteName,
              "marks": hPercentage,
              "passing_year": hYearOfPassing,
            };
          }
          Map diplomaJson;
          if (did == null) {
            diplomaJson = {
              "course": dCourseName,
              "degree": dDegree,
              "done": diplomadegreeBool,
              "institute_name": dInstituteName,
              "marks": dCGPA,
              "passing_year": dYearOfPassing,
            };
          } else {
            diplomaJson = {
              "id": did,
              "edu_fields": did,
              "course": dCourseName,
              "degree": dDegree,
              "done": diplomadegreeBool,
              "institute_name": dInstituteName,
              "marks": dCGPA,
              "passing_year": dYearOfPassing,
            };
          }
          Map itiJson;
          if (iid == null) {
            itiJson = {
              "course": iCourseName,
              "degree": iDegree,
              "done": itidegreeBool,
              "institute_name": iInstituteName,
              "marks": iCGPA,
              "passing_year": iYearOfPassing,
            };
          } else {
            itiJson = {
              "id": iid,
              "edu_fields": iid,
              "course": iCourseName,
              "degree": iDegree,
              "done": itidegreeBool,
              "institute_name": iInstituteName,
              "marks": iCGPA,
              "passing_year": iYearOfPassing,
            };
          }
          Map graduationJson;
          if (gid == null) {
            graduationJson = {
              "course": gCourseName,
              "degree": gDegree,
              "done": graduatedegreeBool,
              "institute_name": gInstituteName,
              "marks": gCGPA,
              "passing_year": gYearOfPassing,
            };
          } else {
            graduationJson = {
              "id": gid,
              "edu_fields": gid,
              "course": gCourseName,
              "degree": gDegree,
              "done": graduatedegreeBool,
              "institute_name": gInstituteName,
              "marks": gCGPA,
              "passing_year": gYearOfPassing,
            };
          }
          Map postGraduationJson;
          if (pgid == null) {
            postGraduationJson = {
              "course": pgCourseName,
              "degree": pgDegree,
              "done": postgraduatedegreeBool,
              "institute_name": pgInstituteName,
              "marks": pgCGPA,
              "passing_year": pgYearOfPassing,
            };
          } else {
            postGraduationJson = {
              "id": pgid,
              "edu_fields": pgid,
              "course": pgCourseName,
              "degree": pgDegree,
              "done": postgraduatedegreeBool,
              "institute_name": pgInstituteName,
              "marks": pgCGPA,
              "passing_year": pgYearOfPassing,
            };
          }
          Map educationalDetailsJson = {
            "ssc": sscJson,
            "hsc": hscJson,
            "diploma": diplomaJson,
            "iti": itiJson,
            "graduation": graduationJson,
            "post_graduation": postGraduationJson
          };
          var jsonSkill = {'seeker': seekerId, 'skills': someskilll};

          Map jsonProfile = {
            "seeker_details": seekerJson,
            "educational_details": educationalDetailsJson,
            "seeker_skills": jsonSkill,
            "seeker_exp": exp
          };

          final String profileApiUrl = allApis.updateUserProfile;
          final http.Response response = await http.put(
            profileApiUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'token': userToken
            },
            body: jsonEncode(jsonProfile),
          );
          setState(() => isLoading = false);

          if (profilePicChanged == true) {
            Fluttertoast.showToast(msg: "Uploading profile pic.");
            final String profileUrl = allApis.updateProfilePic;
            final profileEmail = emailCon.text;
            imageLoaction = imageSelected.path;

            Map<String, String> headers = {"token": userToken};
            // ignore: deprecated_member_use
            var stream = new http.ByteStream(
                // ignore: deprecated_member_use
                DelegatingStream.typed(result.openRead()));
            var length = await result.length();
            try {
              var request =
                  new http.MultipartRequest("POST", Uri.parse(profileUrl));
              request.headers.addAll(headers);
              var multipartFile = new http.MultipartFile(
                  'image', stream, length,
                  filename: imageLoaction);
              request.fields['email'] = profileEmail;
              request.files.add(multipartFile);
              var response = await request.send();
              var jsonDecoded;
              var message;
              response.stream.transform(utf8.decoder).listen((value) {
                jsonDecoded = jsonDecode(value);
                message = jsonDecoded['msg'];
                Fluttertoast.cancel();
                Fluttertoast.showToast(msg: message);
                // parse value
              });
            } catch (e) {
              setState(() => isLoading = false);
              Fluttertoast.showToast(msg: "something went wrong");
              Fluttertoast.showToast(msg: "Image can't be uploaded.");
            }
          }
          profileCompleted = true;
          var errorFromServer;
          if (response.statusCode == 201) {
            setState(() => isLoading = false);
            profileCompleted = true;
          } else {
            setState(() => isLoading = false);
            Fluttertoast.showToast(msg: "something went wrong");
          }

          if (errorFromServer == false) {
            setState(() => isLoading = false);
          } else {
            setState(() => isLoading = false);
          }
        } else {
          Fluttertoast.showToast(msg: 'No internet available');
        }
      } else {
        Fluttertoast.showToast(msg: 'No internet available');
      }
    } else {
      showAlertDia(context, "Incomplete Degree", "Please select your Degree");
    }
  }

  getCountryName(fetchedCountryId) async {
    countryDDText = 'Loading country name...';
    var countryName;
    var countryId;
    List countries;
    String myCountryUrl = allApis.country;
    http.Response response = await http.get(myCountryUrl);
    final dataFirst = jsonDecode(response.body);
    await http.get(myCountryUrl).then((response) {
      countries = dataFirst;
      for (var i = 0; i < countries.length; i++) {
        var countryObject = countries[i];
        countryId = countryObject['id'];
        if (countryId == fetchedCountryId) {
          countryName = countryObject['name'];
          setState(() {
            countryList = countries;
            countryDDText = countryName;
          });
        }
      }
      if ((fetchedStatetId == null) && (fetchedCountryId != null)) {
      }
    });
  }

  getStateName(countryId, stateId) async {
    stateDDText = "Loading state name...";
    var stateName;
    var checkStateId;
    var stateObject;
    List states;
    String myStateUrl = allApis.state + countryId;
    http.Response response = await http.get(myStateUrl);
    final dataFirst = jsonDecode(response.body);
    await http.get(myStateUrl).then((response) {
      states = dataFirst;
      for (var i = 0; i < states.length; i++) {
        stateObject = states[i];
        checkStateId = stateObject['id'];
        if (stateId == checkStateId) {
          stateName = stateObject['name'];
          setState(() {
            stateList = states;
            stateDDText = stateName;
          });
        }
      }
      if ((fetchedCityId == null) && (stateId != null)) {
        _getCityList(stateId);
      }
    });
  }

  getCityName(stateId, cityId) async {
    cityDDText = 'Loading city name...';
    var cityName;
    var cityObject;
    var checkCityId;
    List cities;
    String myCityUrl = allApis.city + stateId;
    http.Response response = await http.get(myCityUrl);
    final dataFirst = jsonDecode(response.body);
    await http.get(myCityUrl).then((response) {
      cities = dataFirst;
      for (var i = 0; i < cities.length; i++) {
        cityObject = cities[i];
        checkCityId = cityObject['id'];
        if (checkCityId == cityId) {
          cityName = cityObject['name'];
          setState(() {
            cityList = cities;
            cityDDText = "Select City";
            cityDDText = cityName;
          });
          break;
        }
      }
    });
  }

  Widget _buildFirstNameRow() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        onChanged: (value) {
          setState(() {
            eFirstname = value;
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: mainColor,
            ),
            labelText: 'Firstname*'),
        controller: firstnameCon,
        validator: (value) => value == null ? 'Firstname required' : null,
      ),
    );
  }

  Widget _buildLastNameRow() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        onChanged: (value) {
          setState(() {
            eLastname = value;
          });
        },
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
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            eMobile = value;
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.mobile_screen_share,
              color: mainColor,
            ),
            labelText: 'Mobile Number*'),
        controller: mobileCon,
        validator: MultiValidator([
          MinLengthValidator(10, errorText: 'Should be 10 digits'),
          MaxLengthValidator(10, errorText: "Should be 10 digits")
        ]),
      ),
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              eEmail = value;
            });
          },
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email,
                color: mainColor,
              ),
              labelText: 'E-mail*'),
          controller: emailCon,
          validator: MultiValidator([
            RequiredValidator(errorText: 'Email required*'),
            EmailValidator(errorText: 'Enter valid email')
          ])),
    );
  }

  Widget _buildCountryRow() {
    return Stack(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 23.0),
            child: Icon(
              Icons.flag,
              color: mainColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 15.0, top: 10),
          child: Padding(
            padding: EdgeInsets.only(bottom: 1.0),
            child: SearchableDropdown.single(
              items: countryList?.map((item) {
                    return new DropdownMenuItem(
                      child: new Text(item['name']),
                      value: item['name'].toString(),
                    );
                  })?.toList() ??
                  [],
              value: myCountryName,
              searchHint: "Search Country",
              hint: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text('$countryDDText'),
              ),
              onChanged: (countryNewValue) {
                setState(() {
                  myCountryName = countryNewValue;
                  myStateName = null;
                  myCityName = null;
                  myState = null;
                  myCity = null;
                  stateSelected = false;
                });
                for (var i = 0; i < countryList.length; i++) {
                  if (myCountryName == countryList[i]['name']) {
                    myCountry = countryList[i]['id'];
                    break;
                  }
                }
                setState(() {
                  countrySelected = false;
                });
                if (myCountryName != null) {
                  _getStatesList(myCountry);
                } else {
                  Fluttertoast.showToast(msg: "Select country again.");
                }
              },
              dialogBox: false,
              isExpanded: true,
              displayClearIcon: false,
              menuConstraints: BoxConstraints.tight(Size.fromHeight(400)),
            ),
          ),
        ),
      ],
    );
  }

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
                if (myStateName != null) {
                  setState(() {
                    stateSelected = false;
                    myCityName = null;
                  });
                }
                setState(() {
                  myStateName = newValue;
                  stateDDText = "Select State";
                  stateSelected = false;
                  myCity = null;
                  cityList = [];
                  cityDDText = 'Loading Cities...';
                });
                for (var i = 0; i < stateList.length; i++) {
                  if (myStateName == stateList[i]['name']) {
                    myState = stateList[i]['id'];
                    break;
                  }
                }
                if (myStateName != null) {
                  _getCityList(myState);
                } else {
                  Fluttertoast.showToast(msg: "Select state again.");
                }
              },
              isExpanded: true,
              dialogBox: false,
              isCaseSensitiveSearch: false,
              displayClearIcon: false,
              menuConstraints: BoxConstraints.tight(Size.fromHeight(400)),
            ),
          )),
    ]);
  }

  Widget _buildHiddenContainerState() {
    return Container();
  }

  Widget _buildHiddenContainerCity() {
    return Container();
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
                onChanged: (String newValue) {
                  myCityName = newValue;
                  setState(() {
                    cityDDText = "Select City";
                    for (var i = 0; i < cityList.length; i++) {
                      if (myCityName == cityList[i]['name']) {
                        myCity = cityList[i]['id'];
                        break;
                      }
                    }
                  });
                },
                isExpanded: true,
                dialogBox: false,
                isCaseSensitiveSearch: false,
                menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
              ),
            )),
      ],
    );
  }

  Widget _buildAddressRow() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 2,
        onChanged: (value) {
          eAddress = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.streetview,
              color: mainColor,
            ),
            labelText: 'Address'),
        controller: addressCon,
      ),
    );
  }

  Widget _buildPostalRow() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          ePostal = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_city, //  Icons.location_pin,
              color: mainColor,
            ),
            labelText: 'Pincode'),
        controller: postalCon,
      ),
    );
  }

  Widget _buildBackgroundRow() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            left: 44.0,
          ),
          margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 0.0),
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: DropdownButtonFormField(
              isExpanded: true,
              value: userBackground,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
              hint: Text('$backgroundDDText'),
              onChanged: (String selectedBackground) {
                setState(() {
                  backgroundDDText = "Select Background";
                  userBackground = selectedBackground;
                });
              },
              items: [
                DropdownMenuItem(child: Text('Student'), value: 'student'),
                DropdownMenuItem(
                    child: Text('Professional Worker'),
                    value: 'professional worker'),
                DropdownMenuItem(child: Text('Other'), value: 'other'),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30.0, left: 40.0),
          child: Icon(
            Icons.history,
            color: mainColor,
            size: 25.0,
          ),
        ),
      ],
    );
  }

  List countryList;
  String myCountry;
  var myCountryName;
  bool countrySelected = false, stateSelected = false;

  Future<String> getCountryList() async {
    String myCountryUrl = allApis.country;
    http.Response response = await http.get(myCountryUrl);
    final dataFirst = jsonDecode(response.body);
    await http.get(myCountryUrl).then((response) {
      if ((response.statusCode >= 200) && (response.statusCode <= 300))
        setState(() {
          countryList = dataFirst;
          countryDDText = 'Select Country';
        });
    });
    return null;
  }

  List stateList;
  String myState;
  var myStateName;
  Future _getStatesList(countryId) async {
    Fluttertoast.showToast(msg: "Loading States...");
    setState(() {
      stateDDText = "Loading States...";
      myStateName = null;
    });
    if (countryId != null) {
      String myStateUrl = allApis.state + countryId;
      http.Response response = await http.get(myStateUrl);
      final stateDataResponse = jsonDecode(response.body);

      await http.get(myStateUrl).then((response) {
        setState(() {
          countrySelected = true;
        });
        if (stateDataResponse.isEmpty) {
          setState(() => stateDDText = "No States Found");
        } else {
          setState(() {
            stateList = stateDataResponse;
            stateDDText = 'Select State';
          });
        }
      });
    } else {
      var olderCountryId = seekerDetails.country;
      String myStateUrl = allApis.state + olderCountryId;
      http.Response response = await http.get(myStateUrl);
      final stateDataResponse = jsonDecode(response.body);

      await http.get(myStateUrl).then((response) {
        setState(() {
          countrySelected = true;
        });
        if (stateDataResponse.isEmpty) {
          setState(() => stateDDText = "No States Found");
        } else {
          setState(() {
            stateList = stateDataResponse;
            stateDDText = 'Select State';
          });
        }
      });
    }
  }

  List cityList;
  String myCity, myCityName;
  Future _getCityList(stateId) async {
    Fluttertoast.showToast(msg: "Loading Cities...");
    setState(() {
      cityDDText = "Loading Cities...";
    });
    if (stateId != null) {
      String myCityUrl = allApis.city + stateId;
      http.Response response = await http.get(myCityUrl);
      final cityDataResponse = jsonDecode(response.body);
      await http.get(myCityUrl).then((response) {
        setState(() {
          stateSelected = true;
        });
        if (cityDataResponse.isEmpty) {
          setState(() => cityDDText = "No Cities Found");
        } else {
          setState(() {
            cityList = cityDataResponse;
            cityDDText = 'Select City';
          });
        }
      });
    } else {
      Fluttertoast.showToast(msg: "Select state again.");
    }
  }
}
