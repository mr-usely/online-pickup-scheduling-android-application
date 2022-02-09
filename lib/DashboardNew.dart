import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:pickup_nitofication/ClientModel.dart';
import 'package:pickup_nitofication/Servers.dart';
import 'package:pickup_nitofication/SideBar.dart';
import 'package:pickup_nitofication/database_helper.dart';
import 'package:pickup_nitofication/login.dart';
// import 'package:pickup_nitofication/CustomWidgets.dart';
import 'package:telephony/telephony.dart';
import 'package:pickup_nitofication/Response.dart';
import 'MyConnectivity.dart';

final String font = "Source Sans Pro";
bool onSMS = false;
bool online = false;
bool expanded = false;
double screenWidth, screenHeight;

class ListItem {
  int id;
  String value;
  ListItem(this.id, this.value);
}

class Farmers {
  int id;
  String farmerNo;
  String name;
  Farmers(this.id, this.farmerNo, this.name);
}

class Dashboard extends StatefulWidget {
  const Dashboard(
      {Key key,
      this.title,
      this.apiKey,
      this.name,
      this.position,
      this.emei,
      this.mode})
      : super(key: key);

  final String title, apiKey, name, position, emei;
  final bool mode;
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final Duration duration = const Duration(milliseconds: 400);
  Map _source = {ConnectivityResult.none: false};
  MyConnectivity _connectivity = MyConnectivity.instance;
  Servers link = Servers.ins;
  final _farName = TextEditingController(),
      _wrapperBales = TextEditingController(),
      _nowrapperBales = TextEditingController();
  final telephony = Telephony.instance;

  List test = [
    'NABFARCAU-0221',
    'ISBFARAUR-5044',
    'DACFARCAU-0218',
    'ISBFARCAU-0221'
  ];

  List<ListItem> _selectItems = [ListItem(0, 'HOME'), ListItem(1, 'FARM')];
  List<DropdownMenuItem<ListItem>> _dropdownMenus;
  ListItem _selectedItem;
  List drop = [];

  List<DropdownMenuItem<ListItem>> buildDropdownMenuItem(List listItems) {
    List<DropdownMenuItem<ListItem>> item = [];
    for (ListItem listItem in listItems) {
      item.add(DropdownMenuItem(
        child: Text(
          listItem.value,
          style: TextStyle(fontFamily: 'Source Sans Pro', color: Colors.grey),
        ),
        value: listItem,
      ));
    }
    return item;
  }

  onChangeItem(ListItem selectedItem) {
    setState(() {
      _selectedItem = selectedItem;
    });
  }

  @override
  void initState() {
    super.initState();
    _dropdownMenus = buildDropdownMenuItem(_selectItems);
    _selectedItem = _dropdownMenus[0].value;
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

    Future<void> _pullRefresh() async {
      setState(() {
        print('hello');
      });
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          key: scaffoldKey,
          elevation: 10,
          backgroundColor: Colors.white,
          centerTitle: true,
          shadowColor: Color.fromRGBO(2, 85, 207, 0.16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
          leading: InkWell(
            child: Icon(
              CupertinoIcons.bars,
              color: Colors.black,
              size: 35,
            ),
            onTap: () => setState(() => scaffoldKey.currentState.openDrawer()),
          ),
          title: Text(
            "VISA App",
            style: TextStyle(
                fontFamily: font,
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: RefreshIndicator(
          child: Container(
            child: ListView(children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(2, 85, 207, 0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 1.5))
                    ]),
                child: Stack(children: [
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            left: 15,
                            right: 15,
                          ),
                          child: Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Farmer Name",
                                    style: TextStyle(
                                        fontFamily: font, fontSize: 17),
                                  ),
                                  Container(
                                    width: 160,
                                    child: TextFormField(
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      decoration: InputDecoration(
                                          labelText: 'Eg. John Lang',
                                          labelStyle: TextStyle(
                                              fontFamily: font, fontSize: 14),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never),
                                    ),
                                  )
                                ],
                              ),
                              Expanded(child: SizedBox()),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Pick-up Point",
                                    style: TextStyle(
                                        fontFamily: font, fontSize: 17),
                                  ),
                                  Container(
                                    width: 155,
                                    child: DropdownButton(
                                        underline: SizedBox(),
                                        value: _selectedItem,
                                        items: _dropdownMenus,
                                        onChanged: onChangeItem,
                                        elevation: 7,
                                        dropdownColor: Colors.white,
                                        icon: Icon(
                                          CupertinoIcons.chevron_down,
                                          color: Colors.grey,
                                        )),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Wrapper",
                                    style: TextStyle(
                                        fontFamily: font, fontSize: 17),
                                  ),
                                  Container(
                                    width: 155,
                                    margin: EdgeInsets.symmetric(),
                                    child: TextFormField(
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                          labelText: 'Eg. 100',
                                          labelStyle: TextStyle(
                                              fontFamily: font, fontSize: 14),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never),
                                    ),
                                  )
                                ],
                              ),
                              Expanded(child: SizedBox()),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Non Wrapper",
                                    style: TextStyle(
                                        fontFamily: font, fontSize: 17),
                                  ),
                                  Container(
                                    width: 155,
                                    margin: EdgeInsets.symmetric(),
                                    child: TextFormField(
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                          labelText: 'Eg. 100',
                                          labelStyle: TextStyle(
                                              fontFamily: font, fontSize: 14),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Send',
                                  style: TextStyle(
                                      fontFamily: font,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(0, 132, 189, 1),
                                  primary: Colors.white,
                                  shadowColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              )),
                              Container(
                                width: 20,
                              ),
                              Expanded(
                                  child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                      fontFamily: font,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(16, 68, 119, 0.3),
                                  primary: Colors.white,
                                  shadowColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ]),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Records",
                      style: TextStyle(
                          fontFamily: font,
                          fontSize: 19,
                          fontWeight: FontWeight.w700),
                    ),
                    Expanded(child: Container()),
                    Text(
                      'Filter  ',
                      style: TextStyle(
                        fontFamily: font,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.arrow_up_arrow_down,
                      size: 13,
                    ),
                    Text(
                      '  2021-06-24',
                      style: TextStyle(
                        fontFamily: font,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: List.generate(
                    test.length,
                    (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              expanded = !expanded;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height: expanded ? 100 : 90,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color.fromRGBO(
                                                2, 85, 207, 0.16),
                                            spreadRadius: 0,
                                            blurRadius: 15,
                                            offset: Offset(0, 0))
                                      ]),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              test[index],
                                              style: TextStyle(
                                                  fontFamily: "Source Sans Pro",
                                                  color: Colors.grey),
                                            ),
                                            Expanded(
                                              child: SizedBox(),
                                            ),
                                            Text(
                                              "May 02, 2021",
                                              style: TextStyle(
                                                  fontFamily: "Source Sans Pro",
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              "ALEJO, JULIETA PAGUIRIGAN",
                                              style: TextStyle(
                                                  fontFamily: "Source Sans Pro",
                                                  fontSize: 15),
                                            ),
                                            Expanded(child: SizedBox()),
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () {},
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Source Sans Pro',
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromRGBO(
                                                            0, 128, 255, 0.7),
                                                    primary: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        9))),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
              )
            ]),
          ),
          onRefresh: _pullRefresh,
        ),
      ),
      onWillPop: () => showDialog(
          context: context,
          builder: (c) => AlertDialog(
                title: Text('Close App'),
                content: Text("Do you really want to close the app?"),
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
