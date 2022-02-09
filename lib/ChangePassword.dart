import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pickup_nitofication/Servers.dart';
import 'package:pickup_nitofication/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword(
      {Key key, this.emei, this.apiKey, this.name, this.position, this.mode})
      : super(key: key);
  final String emei;
  final String apiKey;
  final String name;
  final String position;
  final bool mode;
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class GetID {
  String newID;
  int empID;
  String name;
  String position;

  GetID(this.empID, this.newID, this.name, this.position);

  GetID.fromJson(Map<String, dynamic> json)
      : name = json['Name'],
        empID = json['EmpID'],
        newID = json['NewID'],
        position = json['Position'];
  Map<String, dynamic> toJson() =>
      {'Name': name, 'EmpID': empID, 'NewID': newID, 'Position': position};
}

class _ChangePasswordState extends State<ChangePassword> {
  final _oldpasswordController = TextEditingController();
  final _newpasswordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _password = StreamController<String>();
  final _newpassword = StreamController<String>();
  final _confirmpassword = StreamController<String>();
  Servers link = Servers.ins;
  FocusNode _focus;
  FocusNode focusNode;
  bool _hasInputError = false;
  bool textChange = true;
  bool showButton = false;
  bool validateText = false;
  bool confirmText = false;
  bool buttonText = false;
  bool wrongPw = false;
  bool pwVisibility = true;
  bool newpwVisib = true;
  bool confpwVisib = true;
  bool firstText = true;
  int selectedIndex = 0;
  String text = '';
  String _platformImei = 'Unknown';
  int employeeID;
  String name;
  String position;

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  // Get ID
  getID() async {
    // String url = "http://122.2.12.50:8012/VISA_app/index.php";
    var res =
        await http.post(Uri.encodeFull(link.srvLink(widget.mode)), headers: {
      "Accept": "application/json"
    }, body: {
      "GetID": "GetID",
      "get_emei": widget.emei,
    });

    if (res.body.isNotEmpty) {
      Map inf = jsonDecode(res.body);
      var respo = GetID.fromJson(inf);
      setState(() {
        employeeID = respo.empID;
        name = respo.name;
        position = respo.position;
      });
    } else {
      print('error');
    }
  }

  // For Checking the password.
  checkOldPW() async {
    buttonText = true;
    try {
      // String url = "http://122.2.12.50:8012/VISA_app/index.php";
      var res =
          await http.post(Uri.encodeFull(link.srvLink(widget.mode)), headers: {
        "Accept": "application/json"
      }, body: {
        "validate_pass": "validate",
        "APIKey": widget.apiKey,
        "old_pw": _oldpasswordController.text.toString(),
      });

      if (res.body.isNotEmpty && json.decode(res.body) == 'verified') {
        print('good to go!');
        setState(() {
          wrongPw = false;

          buttonText = false;
          onTapped(1);
        });
      } else if (res.body.isNotEmpty &&
          json.decode(res.body) == 'not_verified') {
        setState(() {
          wrongPw = true;
          buttonText = false;
        });
      }
    } on ClientException catch (_) {
      print(_);
    }
  }

  sendChangePw() async {
    try {
      // String url = "http://122.2.12.50:8012/VISA_app/index.php";
      var res =
          await http.post(Uri.encodeFull(link.srvLink(widget.mode)), headers: {
        "Accept": "application/json"
      }, body: {
        "change_pass": "validate",
        "APIkey": widget.apiKey,
        "pw": _confirmpasswordController.text,
      });
      if (res.body.isNotEmpty && json.decode(res.body) == 'Success') {
        // show dialog before proceeding to dashboard
        showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 3), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(
                              title: 'VISA App',
                              apiKey: widget.apiKey,
                              name: widget.name,
                              position: widget.position,
                              emei: widget.emei,
                              mode: widget.mode,
                            )));
              });
              return WillPopScope(
                child: AlertDialog(
                  title: Text(
                    'Loading...',
                    style:
                        TextStyle(fontFamily: 'Source Sans Pro', fontSize: 20),
                  ),
                  content: Icon(
                    CupertinoIcons.slowmo,
                    size: 40,
                  ),
                  actions: [],
                ),
                onWillPop: null,
              );
            });
      } else {
        print('request failed');
      }
    } on ClientException catch (_) {}
  }

  //Page View Builder
  Widget buildPageView() {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        StreamBuilder<String>(
            initialData: '',
            stream: _password.stream,
            builder: (context, oldpasswordSnapshot) {
              return Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Icon(
                      CupertinoIcons.person_crop_circle,
                      color: Colors.grey,
                      size: 110,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                    child: wrongPw
                        ? Text(
                            'Wrong Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: 'Source Sans Pro',
                                fontSize: 12),
                          )
                        : Text(
                            'Enter your old password',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.grey.withOpacity(1),
                                fontFamily: 'Source Sans Pro',
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                  ),

                  //Old Paswword TextFormField
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 17, right: 12),
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Container(
                            width: 220,
                            height: 50,
                            child: TextFormField(
                              obscureText: pwVisibility,
                              onChanged: _password.add,
                              textAlignVertical: TextAlignVertical.center,
                              controller: _oldpasswordController,
                              decoration: InputDecoration(
                                  labelText: 'Old Password',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Source Sans Pro',
                                      fontSize: 14),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      gapPadding: 0.0),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.only(top: 0),
                            icon: Icon(
                              pwVisibility
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.withOpacity(0.8),
                            ),
                            onPressed: () {
                              setState(() {
                                if (pwVisibility == false)
                                  pwVisibility = true;
                                else if (pwVisibility == true)
                                  pwVisibility = false;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),

                  //Forgot Password

                  Container(
                    margin: const EdgeInsets.only(left: 30, top: 0),
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 13),
                          child: GestureDetector(
                            onTap: () {
                              launch("tel://09178217909");
                            },
                            child: Text(
                              'Forgot Password',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 132, 189, 1),
                                  fontFamily: 'Source Sans Pro',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),

                        // Customize flat button
                        if (oldpasswordSnapshot.data.isNotEmpty)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 120, top: 0, right: 10),
                                child: TextButton(
                                  onPressed: checkOldPW,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        buttonText ? 'VERIFYNG..' : 'NEXT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black.withOpacity(0.5),
                                          fontFamily: 'Source Sans Pro',
                                          fontSize: 14,
                                        ),
                                      ),
                                      buttonText
                                          ? SizedBox()
                                          : Icon(
                                              CupertinoIcons.chevron_right,
                                              size: 20,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                    ],
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.2)),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(),
                      ],
                    ),
                  ),
                ],
              );
            }),
        StreamBuilder<String>(
            initialData: '',
            stream: _confirmpassword.stream,
            builder: (context, confirmpasswordSnapshot) {
              return StreamBuilder<String>(
                  initialData: '',
                  stream: _newpassword.stream,
                  builder: (context, newpasswordSnapshot) {
                    if (confirmpasswordSnapshot.data !=
                            newpasswordSnapshot.data &&
                        confirmpasswordSnapshot.data.isNotEmpty) {
                      _hasInputError = true;

                      confirmText = false;
                    } else if (newpasswordSnapshot.data.isNotEmpty &&
                        confirmpasswordSnapshot.data.isEmpty) {
                      firstText = false;
                    } else if (newpasswordSnapshot.data ==
                            confirmpasswordSnapshot.data &&
                        confirmpasswordSnapshot.data.isNotEmpty &&
                        newpasswordSnapshot.data.isNotEmpty) {
                      confirmText = true;
                      _hasInputError = false;
                    } else {
                      _hasInputError = false;
                      confirmText = false;
                    }

                    return Column(
                      children: <Widget>[
                        //User Icon
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Icon(
                            CupertinoIcons.person_crop_circle,
                            color: Colors.grey,
                            size: 110,
                          ),
                        ),

                        //Text
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                          child: confirmText
                              ? Text(
                                  'Password Confirmed!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(220, 16, 204, 169),
                                      fontFamily: 'Source Sans Pro'),
                                )
                              : firstText
                                  ? Text('Enter your new password.',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Source Sans Pro',
                                          fontWeight: FontWeight.w500))
                                  : !newpasswordSnapshot.data
                                          .contains(new RegExp('[A-Z]'))
                                      ? Text('Password must have Uppercase and Lowercase',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: 'Source Sans Pro',
                                              fontSize: 14))
                                      : !newpasswordSnapshot.data
                                              .contains(new RegExp('[a-z]'))
                                          ? Text('Password must have Uppercase and Lowercase',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontFamily: 'Source Sans Pro',
                                                  fontSize: 14))
                                          : !newpasswordSnapshot.data
                                                  .contains(new RegExp('[0-9]'))
                                              ? Text('Password must have numbers and \nspecial characters.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          'Source Sans Pro',
                                                      fontSize: 14))
                                              : !newpasswordSnapshot.data
                                                      .contains(new RegExp(
                                                          '[\\_|\\-|\\=@,\\.;]'))
                                                  ? Text('Password must have numbers and \nspecial characters.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontFamily:
                                                              'Source Sans Pro',
                                                          fontSize: 14))
                                                  : newpasswordSnapshot.data.length ==
                                                          8
                                                      ? Text(
                                                          'Your password must have at least\n8-16 characters.',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(color: Colors.red, fontFamily: 'Source Sans Pro', fontSize: 12))
                                                      : textChange
                                                          ? Text(
                                                              _hasInputError
                                                                  ? "Password doesn't match"
                                                                  : 'Perfect! Confirm your new password!',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  color: _hasInputError
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green
                                                                          .withOpacity(
                                                                              0.8),
                                                                  fontFamily:
                                                                      'Source Sans Pro',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )
                                                          : Text(
                                                              _hasInputError
                                                                  ? "Password doesn't match"
                                                                  : 'Confirm your new password',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  color: _hasInputError
                                                                      ? Colors
                                                                          .red
                                                                      : Colors.grey
                                                                          .withOpacity(
                                                                              1),
                                                                  fontFamily:
                                                                      'Source Sans Pro',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                        ),

                        // New Password Text field
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: Wrap(
                              direction: Axis.horizontal,
                              children: [
                                SizedBox(
                                  width: 205,
                                  child: TextFormField(
                                    obscureText: newpwVisib,
                                    focusNode: focusNode,
                                    onChanged: _newpassword.add,
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: _newpasswordController,
                                    decoration: InputDecoration(
                                        labelText: 'New Password',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        labelStyle: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontSize: 14),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            borderSide: BorderSide.none)),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.only(top: 0),
                                  icon: Icon(
                                    newpwVisib
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (newpwVisib == false)
                                        newpwVisib = true;
                                      else if (newpwVisib == true)
                                        newpwVisib = false;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ),

                        // Confirm Password Text field
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: Wrap(
                              direction: Axis.horizontal,
                              children: [
                                SizedBox(
                                  width: 205,
                                  child: TextFormField(
                                    obscureText: confpwVisib,
                                    focusNode: _focus,
                                    textAlignVertical: TextAlignVertical.center,
                                    onChanged: _confirmpassword.add,
                                    controller: _confirmpasswordController,
                                    decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        labelStyle: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontSize: 14),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none)),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.only(top: 0),
                                  icon: Icon(
                                    confpwVisib
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (confpwVisib == false)
                                        confpwVisib = true;
                                      else if (confpwVisib == true)
                                        confpwVisib = false;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ),

                        // Customize flat button
                        if (newpasswordSnapshot.data ==
                                confirmpasswordSnapshot.data &&
                            confirmpasswordSnapshot.data.isNotEmpty)
                          Container(
                            height: 65,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  Container(
                                    width: 115,
                                    margin: const EdgeInsets.only(
                                        left: 212, right: 10, top: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, right: 12),
                                      child: TextButton(
                                        onPressed: sendChangePw,
                                        child: const Text(
                                          'Confirm',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontFamily: 'Source Sans Pro',
                                            fontSize: 15,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                Color.fromRGBO(0, 132, 189, 1)),
                                      ),
                                    ),
                                  ),
                                ]),
                          )
                        else
                          Container(),
                      ],
                    );
                  });
            })
      ],
    );
  }

  void pageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void onTapped(int index) {
    setState(() {
      selectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Text(
                  'Manage Account',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Source Sans Pro',
                      fontSize: 30,
                      fontWeight: FontWeight.w900),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Change your default password ' + '\nfor your security.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Source Sans Pro'),
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Container(
              height: 345,
              margin: const EdgeInsets.only(
                  top: 70, bottom: 20, right: 10, left: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 6,
                        blurRadius: 25,
                        offset: Offset(0, 0))
                  ]),
              child: buildPageView(),
            ),
          ),
        ],
      ),
    );
  }
}
