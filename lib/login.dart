import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pickup_nitofication/ChangePassword.dart';
import 'package:pickup_nitofication/dashboard.dart';
import 'package:pickup_nitofication/database_helper.dart';
import 'package:pickup_nitofication/Servers.dart';

import 'User.dart';

class LogIn extends StatefulWidget {
  LogIn({Key key, this.emei, this.mode}) : super(key: key);
  final String emei;
  final bool mode;
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _username = TextEditingController(),
      _password = TextEditingController();
  Servers link = Servers.ins;
  bool pwVisib = true;

  navigate() async {
    try {
      try {
        print(widget.emei);
        if (_username.text.isNotEmpty && _password.text.isNotEmpty) {
          var res = await http
              .post(Uri.encodeFull(link.srvLink(widget.mode)), headers: {
            "Accept": "application/json"
          }, body: {
            "Authenticate": "VISA_Authentication",
            "username": _username.text,
            "password": _password.text,
            "Emei": widget.emei,
          });

          if (res.body.isNotEmpty &&
              json.decode(res.body).toString() == "VISA_Auth_Success") {
            print(json.decode(res.body).toString());
            // if VISA is Success
            ///
            ///
            ///
            var res2 = await http.post(Uri.encodeFull(Servers.liveServer),
                headers: {"Accept": "application/json"},
                body: {"getInfo": "getInfo", "identification": _username.text});
            //
            //
            //
            print(json.decode(res2.body));
            if (res2.body.isNotEmpty &&
                json.decode(res2.body).toString() != "change_device") {
              Map userMap = jsonDecode(res2.body);
              var userResponse = User.fromJson(userMap);

              // String uri = 'http://122.2.12.50:8012/VISA_app_testing/index.php';

              var r = await http.post(Uri.encodeFull(Servers.liveServer),
                  headers: {
                    "Accept": "application/json"
                  },
                  body: {
                    "checkpw": "validate",
                    "APIkey": userResponse.apiKey.toString()
                  });

              int i = await DbHelper.db.insertUser({
                DbHelper.colUserID: userResponse.id,
                DbHelper.colAPIkey: userResponse.apiKey,
                DbHelper.colName: userResponse.name,
                DbHelper.colPosition: userResponse.position,
              });
              print('User Data recorded: $i');
              if (r.body.isNotEmpty &&
                  json.decode(r.body) == "ChangePW_NotNull") {
                print(json.decode(r.body));
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(
                              title: 'VISA App',
                              apiKey: userResponse.apiKey,
                              name: userResponse.name,
                              position: userResponse.position,
                              emei: widget.emei,
                              mode: widget.mode,
                            )));
              } else if (r.body.isNotEmpty &&
                  json.decode(r.body) == "ChangePW_Null") {
                print(json.decode(r.body));
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePassword(
                              apiKey: userResponse.apiKey,
                              emei: widget.emei,
                              name: userResponse.name,
                              position: userResponse.position,
                              mode: widget.mode,
                            )));
              }
            } else {
              print(json.decode(res2.body));
            }
          } else {
            showDialog(
                context: context,
                builder: (c) => AlertDialog(
                      title: Text(
                        "Invalid Credentials",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: font, fontSize: 20),
                      ),
                      content: Text(
                        "Username or Password is incomplete",
                        style: TextStyle(fontFamily: font, fontSize: 18),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: Text(
                            "Ok",
                            style: TextStyle(fontFamily: font, fontSize: 15),
                          ),
                        )
                      ],
                    ));
            print(json.decode(res.body).toString());
          }
        } else {
          showDialog(
              context: context,
              builder: (c) => AlertDialog(
                    title: Text(
                      "Invalid Credentials",
                      style: TextStyle(fontFamily: font, fontSize: 20),
                    ),
                    content: Text(
                      "Username or Password is incomplete",
                      style: TextStyle(fontFamily: font, fontSize: 18),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: Text(
                          "Ok",
                          style: TextStyle(fontFamily: font, fontSize: 15),
                        ),
                      )
                    ],
                  ));
        }
      } catch (_) {
        print(_);
      }
    } on SocketException catch (_) {
      snacky('Slow Internet connection.');
      print(_);
    }
  }

  snacky(String message) {
    final snackbar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  void initState() {
    super.initState();
    print(link.srvLink(widget.mode));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 50),
                child: Column(
                  children: <Widget>[
                    Image(
                      image: AssetImage('assets/img/pickup-logo-transpa.png'),
                      width: 90,
                    ),
                    Text(
                      'VISA App',
                      style: TextStyle(
                          fontFamily: 'Source Sans Pro',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: Offset(0, 20))
                    ]),
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 30.0, right: 30.0, top: 50.0, bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      // Username Input
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.account_circle_outlined,
                            color: Colors.grey,
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 0.61 * screenWidth,
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.bottom,
                                    controller: _username,
                                    decoration: InputDecoration(
                                        labelText: 'Username',
                                        labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Source Sans Pro'),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      // Password Input
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.lock_outlined,
                            color: Colors.grey,
                          ),
                          Container(
                            child: Wrap(
                              direction: Axis.horizontal,
                              children: <Widget>[
                                Container(
                                  width: 0.57 * screenWidth,
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.bottom,
                                    controller: _password,
                                    obscureText: pwVisib,
                                    obscuringCharacter: '•',
                                    decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Source Sans Pro'),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none)),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        pwVisib = !pwVisib;
                                      });
                                    },
                                    icon: Icon(
                                      pwVisib
                                          ? CupertinoIcons.eye_slash
                                          : CupertinoIcons.eye,
                                      color: Colors.grey.withOpacity(0.8),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: 1,
                        width: 300,
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        color: Colors.grey,
                      ),
                      // Log In Button
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 250,
                              height: 40,
                              child: TextButton(
                                  onPressed: navigate,
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                        fontFamily: 'Source Sans Pro',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(0, 132, 189, 1),
                                      primary: Colors.white,
                                      shadowColor: Colors.grey)),
                            ),
                          ])
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onWillPop: () => showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                title: Text(
                  "Close App",
                  style: TextStyle(fontFamily: font, fontSize: 15),
                ),
                content: Text(
                  "Do you really want to close the app?",
                  style: TextStyle(fontFamily: font, fontSize: 15),
                ),
                actions: [
                  TextButton(
                      onPressed: () => SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop'),
                      child: Text(
                        "Yes",
                        style: TextStyle(fontFamily: font, fontSize: 15),
                      )),
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(
                        "No",
                        style: TextStyle(fontFamily: font, fontSize: 15),
                      ))
                ],
              )),
    );
  }
}
