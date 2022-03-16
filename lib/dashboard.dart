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
import 'package:telephony/telephony.dart';
import 'package:pickup_nitofication/Response.dart';
import 'MyConnectivity.dart';

final String font = "Source Sans Pro"; // Default Font
bool onSMS = false;
bool online = false;
double screenWidth, screenHeight;

class Dashboard extends StatefulWidget {
  Dashboard(
      {Key key,
      this.title,
      this.apiKey,
      this.name,
      this.position,
      this.emei,
      this.mode})
      : super(key: key);

  final String title;
  final String apiKey;
  final String name;
  final String position;
  final String emei;
  final bool mode;
  @override
  _DashboardState createState() => _DashboardState();
}

// class List Item for the drop down
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

class _DashboardState extends State<Dashboard> {
  final _farName = TextEditingController(),
      _wrapperBales = TextEditingController(),
      _nowrapperBales = TextEditingController();
  final telephony = Telephony.instance;
  final Duration duration = const Duration(milliseconds: 400);
  var scaffoldKey = GlobalKey<ScaffoldState>();
  Map _source = {ConnectivityResult.none: false};
  MyConnectivity _connectivity = MyConnectivity.instance;
  Servers link = Servers.ins;

  String _message = "";
  String farmersNo = "";
  List<Clients> testData = [];
  List<Farmers> farmers = [];
  List<ListItem> _selectItems = [ListItem(0, 'HOME'), ListItem(1, 'FARM')];
  List<DropdownMenuItem<ListItem>> _dropdownMenus;
  ListItem _selectedItem;
  List drop = [];
  bool loading = true;
  bool nab = false;
  bool isb = false;
  bool dac = false;
  bool wrapperFocused = false;
  bool nonwrapperFocused = false;
  bool sending = false;

  bool isCollapse = true;
  bool typed = false;

  List<DropdownMenuItem<ListItem>> buildDropdownMenuItem(List listItems) {
    List<DropdownMenuItem<ListItem>> item = List();
    for (ListItem listItem in listItems) {
      item.add(DropdownMenuItem(
        child: Text(
          listItem.value,
          style: TextStyle(fontFamily: 'Source Sans Pro'),
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

  // Checking SMS Status
  onSendStatus(SendStatus status) {
    setState(() async {
      _message = status == SendStatus.SENT ? "sent" : "delivered";

      if (_message == "sent") {
        testData.clear();

        initData(onSMS ? 'SMS' : 'ONLINE');

        setState(() {
          snacky('Data is sent to MA.');
        });
      } else if (_message == "delivered") {
        print('inserting data from database...');

        setState(() {
          showSmsDialogue(context, 'VISA Sent Successfully');
          incomingSms();
        });
      }
    });
  }

  onSelectData(String data) async {
    List<SmsMessage> message = await telephony.getInboxSms(
      columns: [SmsColumn.BODY],
      filter: SmsFilter.where(SmsColumn.BODY).equals('237808'),
    );

    print(message.length);
    print(data);
  }

  snacky(String message) {
    final snackbar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  // send button
  void _send() async {
    loading = true;
    typed = false;
    setState(() => sending = true);
    print('sending');
    if (online || onSMS == false)
      try {
        if (_farName.text.isNotEmpty) {
          if (farmersNo.isNotEmpty && farmersNo != '') {
            if (farmersNo.substring(0, 3).toString() == "NAB") {
              if (_wrapperBales.text.isNotEmpty ||
                  _nowrapperBales.text.isNotEmpty) {
                if (_wrapperBales.text.isNotEmpty) {
                  if (_nowrapperBales.text.isNotEmpty) {
                    Future.delayed(
                        Duration(seconds: 3),
                        () => setState(() {
                              sending = false;
                              internetFunction();
                            }));
                    loading = false;
                  } else {
                    Future.delayed(Duration(seconds: 3),
                        () => setState(() => sending = false));
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Record Incomplete',
                              style: TextStyle(fontFamily: font, fontSize: 20),
                            ),
                            content: Text(
                              'Please fill the Non-Wrapper Bales field before sending data.',
                              style: TextStyle(fontFamily: font, fontSize: 17),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK',
                                    style: TextStyle(
                                        fontFamily: font, fontSize: 14)),
                              )
                            ],
                          );
                        });
                    loading = false;
                  }
                } else {
                  Future.delayed(Duration(seconds: 3),
                      () => setState(() => sending = false));
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Record Incomplete',
                            style: TextStyle(fontFamily: font, fontSize: 20),
                          ),
                          content: Text(
                            'Please fill the Wrapper Bales field before sending data.',
                            style: TextStyle(fontFamily: font, fontSize: 17),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK',
                                  style: TextStyle(
                                      fontFamily: font, fontSize: 14)),
                            )
                          ],
                        );
                      });
                  loading = false;
                }
              } else {
                Future.delayed(Duration(seconds: 3),
                    () => setState(() => sending = false));
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Record Incomplete',
                          style: TextStyle(fontFamily: font, fontSize: 20),
                        ),
                        content: Text(
                          'Please fill Wrapper and Non Wrapper Bales field before sending data.',
                          style: TextStyle(fontFamily: font, fontSize: 17),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK',
                                style:
                                    TextStyle(fontFamily: font, fontSize: 14)),
                          )
                        ],
                      );
                    });
                loading = false;
              }
            } else if (farmersNo.substring(0, 3).toString() != "NAB") {
              if (_nowrapperBales.text.isNotEmpty) {
                Future.delayed(
                    Duration(seconds: 3),
                    () => setState(() {
                          internetFunction();
                          sending = false;
                        }));

                loading = false;
              } else {
                Future.delayed(Duration(seconds: 3),
                    () => setState(() => sending = false));
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Record Incomplete',
                          style: TextStyle(fontFamily: font, fontSize: 20),
                        ),
                        content: Text(
                            'Please fill the Bales field before sending data.',
                            style: TextStyle(fontFamily: font, fontSize: 17)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK',
                                style:
                                    TextStyle(fontFamily: font, fontSize: 14)),
                          )
                        ],
                      );
                    });
                loading = false;
              }
            }
          } else {
            Future.delayed(
                Duration(seconds: 3), () => setState(() => sending = false));
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Record Incomplete',
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 20,
                        )),
                    content:
                        Text('Please input valid farmer name from the field.',
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 17,
                            )),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK',
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 14,
                            )),
                      )
                    ],
                  );
                });
            loading = false;
          }
        } else {
          Future.delayed(
              Duration(seconds: 3), () => setState(() => sending = false));
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Record Incomplete',
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 20,
                      )),
                  content:
                      Text('Kindly fill all necessary fields before sending.',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 17,
                          )),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 14,
                          )),
                    )
                  ],
                );
              });
          loading = false;
        }
      } on SocketException catch (_) {
        Future.delayed(
            Duration(seconds: 3), () => setState(() => sending = false));
        showSmsDialogue(context,
            "Canot use the internet connection due to unreliable internet connection.");
        loading = false;
      }

    // else if view is SMS
    else {
      if (_farName.text.isNotEmpty) {
        if (farmersNo.isNotEmpty && farmersNo != '') {
          if (farmersNo.substring(0, 3).toString() == "NAB") {
            if (_wrapperBales.text.isNotEmpty ||
                _nowrapperBales.text.isNotEmpty) {
              if (_wrapperBales.text.isNotEmpty) {
                if (_nowrapperBales.text.isNotEmpty) {
                  !onSMS
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Data Redirection',
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 20,
                                  )),
                              content: Text(
                                  "You're currently offline. VISA will redirect through SMS. Are you sure, you want to send your data?",
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 17,
                                  )),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel',
                                      style: TextStyle(
                                        fontFamily: font,
                                        fontSize: 15,
                                      )),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    smsFunction();
                                  },
                                  child: Text('Ok',
                                      style: TextStyle(
                                        fontFamily: font,
                                        fontSize: 15,
                                      )),
                                )
                              ],
                            );
                          })
                      : smsFunction();
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Record Incomplete',
                            style: TextStyle(fontFamily: font, fontSize: 20),
                          ),
                          content: Text(
                            'Please fill the Non-Wrapper  before sending data.',
                            style: TextStyle(fontFamily: font, fontSize: 17),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK',
                                  style: TextStyle(
                                      fontFamily: font, fontSize: 14)),
                            )
                          ],
                        );
                      });
                }
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Record Incomplete',
                          style: TextStyle(fontFamily: font, fontSize: 20),
                        ),
                        content: Text(
                          'Please fill the Wrapper before sending data.',
                          style: TextStyle(fontFamily: font, fontSize: 18),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK',
                                style:
                                    TextStyle(fontFamily: font, fontSize: 14)),
                          )
                        ],
                      );
                    });
              }
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Record Incomplete',
                        style: TextStyle(fontFamily: font, fontSize: 20),
                      ),
                      content: Text(
                        'Please fill Wrapper and Non Wrapper Bales field before sending data.',
                        style: TextStyle(fontFamily: font, fontSize: 17),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK',
                              style: TextStyle(fontFamily: font, fontSize: 14)),
                        )
                      ],
                    );
                  });
              loading = false;
            }
          } else if (farmersNo.substring(0, 3).toString() == "ISB") {
            if (_wrapperBales.text.isNotEmpty) {
              !onSMS
                  ? showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Data Redirection',
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 20,
                              )),
                          content: Text(
                              "You're currently offline. VISA will redirect through SMS. Are you sure, you want to send your data?",
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 17,
                              )),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel',
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 15,
                                  )),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                smsFunction();
                              },
                              child: Text('Ok',
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 15,
                                  )),
                            )
                          ],
                        );
                      })
                  : smsFunction();
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Record Incomplete',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 20,
                          )),
                      content: Text(
                          'Please fill the Wrapper field before sending data.',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 17,
                          )),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK',
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 14,
                              )),
                        )
                      ],
                    );
                  });
            }
          } else if (farmersNo.substring(0, 3).toString() == "DAC") {
            if (_wrapperBales.text.isNotEmpty) {
              !onSMS
                  ? showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Data Redirection',
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 20,
                              )),
                          content: Text(
                              "You're currently offline. VISA will redirect through SMS. Are you sure, you want to send your data?",
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 17,
                              )),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel',
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 15,
                                  )),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                smsFunction();
                              },
                              child: Text('Ok',
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 15,
                                  )),
                            )
                          ],
                        );
                      })
                  : smsFunction();
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Record Incomplete',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 15,
                          )),
                      content: Text(
                        'Please fill the Wrapper field before sending data.',
                        style: TextStyle(fontFamily: font, fontSize: 17),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Ok',
                            style: TextStyle(fontFamily: font, fontSize: 14),
                          ),
                        )
                      ],
                    );
                  });
            }
          }
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Record Incomplete',
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 20,
                      )),
                  content: Text(
                    'Please input valid farmer name from the field.',
                    style: TextStyle(fontFamily: font, fontSize: 17),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Ok',
                        style: TextStyle(fontFamily: font, fontSize: 14),
                      ),
                    )
                  ],
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Record Incomplete',
                    style: TextStyle(
                      fontFamily: font,
                      fontSize: 20,
                    )),
                content: Text(
                  'Kindly fill all necessary fields before sending.',
                  style: TextStyle(fontFamily: font, fontSize: 17),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(fontFamily: font, fontSize: 14),
                    ),
                  )
                ],
              );
            });
      }
    }
  }

  // For Online VISA Function
  internetFunction() async {
    try {
      try {
        // String url = Servers.liveServer;
        if (widget.apiKey != "" &&
            widget.apiKey.isNotEmpty &&
            widget.apiKey != null) {
          var res = await http
              .post(Uri.encodeFull(link.srvLink(widget.mode)), headers: {
            "Accept": "application/json"
          }, body: {
            "VISA": "VISA_Submit",
            "farmerno": farmersNo,
            "pickuppoint": _selectedItem.value,
            "wrapper": _wrapperBales.text,
            "nonwrapper": _nowrapperBales.text,
            "id": "${widget.apiKey}"
          });
          Map respo = jsonDecode(res.body);
          var response = Responses.fromJson(respo);
          if (res.body.isNotEmpty && response.result == "VISA_Success") {
            showSmsDialogue(context, "VISA Recorded Successfully.");
            farmersNo = '';
            _farName.clear();
            _wrapperBales.clear();
            _nowrapperBales.clear();
            initRecords();
            initData('ONLINE');
          } else if (res.body.isNotEmpty && response.result == "VISA_Exist") {
            showSmsDialogue(context,
                "VISA for ${_farName.text} - $farmersNo already exists.");
            farmersNo = '';
            _farName.clear();
            _wrapperBales.clear();
            _nowrapperBales.clear();
          } else if (res.body.isNotEmpty && response.result == "VISA_Overdue") {
            farmersNo = '';
            _farName.clear();
            _wrapperBales.clear();
            _nowrapperBales.clear();
            showSmsDialogue(context,
                "VISA Cancellation Failed. Cancellation of the record is already overdue.");
          } else if (res.body.isNotEmpty && response.result == "VISA_Exceed") {
            farmersNo = '';
            _farName.clear();
            _wrapperBales.clear();
            _nowrapperBales.clear();
            showSmsDialogue(context,
                "VISA Failed to Save. Encoding of the record(s) should be done before 3PM.");
          }
        } else {
          print(widget.mode);
          print(widget.apiKey);
        }
      } on FormatException catch (_) {
        print(farmersNo);
        print(widget.apiKey);
        farmersNo = '';
        _farName.clear();
        _wrapperBales.clear();
        _nowrapperBales.clear();
        print(_);
        showSmsDialogue(context,
            "Can't Connect to the server. Please try resending your data again.");
      }
    } on SocketException catch (_) {
      farmersNo = '';
      _farName.clear();
      _wrapperBales.clear();
      _nowrapperBales.clear();
      print(_);
      showSmsDialogue(context, "Please try resending your data again.");
    }
  }

  // For SMS Function
  smsFunction() async {
    // Check if a device is capable of sending SMS
    bool canSendSms = await telephony.isSmsCapable;

    // Get sim state
    SimState simState = await telephony.simState;
    String message = "VISA " +
        farmersNo +
        " " +
        _selectedItem.value +
        " " +
        _wrapperBales.text +
        " " +
        _nowrapperBales.text;

    if (_farName.text != "" &&
        _wrapperBales.text != "" &&
        _nowrapperBales.text != "") {
      snacky('Sending SMS to server..');
      (canSendSms && simState == SimState.READY)
          ? telephony.sendSms(
              to: "09175860386", message: message, statusListener: onSendStatus)
          : showSmsDialogue(context,
              'Your network is unavailable. kindly check your signal before sending request.');
    }
  }

  // Listening for incoming sms from the server
  incomingSms() {
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) async {
          print(message.address);
          int msgLength = message.body.length; // message length
          int strt = msgLength - 6; // message start
          String recRes = message.body.substring(0, 8).toString();
          String recID = message.body.substring(strt, msgLength).toString();
          var now = DateTime.now();
          var date = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
          print(recRes);

          if (recRes == "Recorded") {
            int i = await DbHelper.db.insert({
              DbHelper.colRecID: recID,
              DbHelper.colRecDate: date,
              DbHelper.colFarmerNo: farmersNo,
              DbHelper.colFarmerName: _farName.text,
              DbHelper.colPickupPoint: _selectedItem.value,
              DbHelper.colWrapper: int.parse(_wrapperBales.text),
              DbHelper.colNonWrapper: int.parse(_nowrapperBales.text),
              DbHelper.colSentFrom: "SMS",
              DbHelper.colRemarks: "Recorded"
            });
            print('The data stored is $i');
          } else if (recRes == "You have") {
            int i = await DbHelper.db.update({
              DbHelper.colRecID: int.parse(recID),
              DbHelper.colRemarks: 'Cancelled'
            });
            print('The data cancelled is $i');
          }

          // Show Success Dialogue
          message.body == "+639175860386"
              ? showSmsDialogue(context, message.body)
              : print('_');
          sending = false;
          farmersNo = '';
          _farName.clear();
          _wrapperBales.clear();
          _nowrapperBales.clear();

          // initialise the new record
          initData(onSMS
              ? 'SMS'
              : online
                  ? 'ONLINE'
                  : 'SMS');
        },
        listenInBackground: false);
  }

  // initialize the data from the database
  initData(String filter) async {
    List<Map<String, dynamic>> queryRows =
        await DbHelper.db.queryAll(filter, widget.position);

    setState(() {
      testData.clear();
      for (var i = 0; i < queryRows.length; i++) {
        testData.add(Clients(
            farmerNo: queryRows[i]['FarmerNo'],
            name: queryRows[i]['Name'],
            pickupPoint: queryRows[i]['PickupPoint'],
            wrapper: queryRows[i]['Wrapper'],
            nonWrapper: queryRows[i]['NonWrapper'],
            recID: queryRows[i]['RecID'],
            createdBy: queryRows[i]['CreatedBy'],
            remarks: queryRows[i]['Remarks'],
            dateBatched: DateTime.parse(queryRows[i]['BatchedDate']),
            date: DateTime.parse(queryRows[i]['RecDate']),
            dateCancelled: DateTime.parse(queryRows[i]['DateCancelled'])));
      }
      loading = false;
    });
  }

  // VISA Cancel
  cancelVISA(int recID, String farmerName, String farmerNo) async {
    if (online || onSMS == false)
      try {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            // String url = 'http://122.2.12.50:8012/VISA_app_testing/index.php';
            var res = await http.post(Uri.encodeFull(link.srvLink(widget.mode)),
                headers: {"Accept": "application/json"},
                body: {"VISA": "VISA_Cancel", "recID": recID.toString()});
            Map respo = jsonDecode(res.body);
            var response = Responses.fromJson(respo);
            if (res.body.isNotEmpty && response.result == "VISA_Success") {
              print(response.result);
              int update = await DbHelper.db.update({
                DbHelper.colRecID: recID,
                DbHelper.colRemarks: 'Cancelled',
                DbHelper.colDateCancelled:
                    DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now())
              });
              print('updated : $update');
              showSmsDialogue(context, 'VISA Cancelled Successfully.');
            } else if (response.result == "VISA_Exceed") {
              showSmsDialogue(context,
                  "Record not canceled! The VISA for $farmerNo - $farmerName with record ID: $recID is already batched, please contact TMG immediately.");
            } else if (response.result == "VISA_Overdue") {
              showSmsDialogue(context,
                  "VISA Failed to Cancel. Cancellation of the record is already overdue.");
            }
          }
        } on FormatException catch (_) {
          print(_);
        }
      } on SocketException catch (_) {
        print(_);
      }
    else {
      // Check if a device is capable of sending SMS
      bool canSendSms = await telephony.isSmsCapable;

      // Get sim state
      SimState simState = await telephony.simState;
      // VISA SMS
      String visa = "VISA CANCEL $recID";
      (canSendSms && simState == SimState.READY)
          ? telephony.sendSms(
              to: "09175860386", message: visa, statusListener: onSendStatus)
          : showSmsDialogue(context,
              'Your network is unavailable. kindly check your signal before sending request.');
    }
    initRecords();
    initData('ONLINE');
  }

  // Get the online or sms data from the server
  Future<List> getData() async {
    try {
      try {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            // String url = 'http://122.2.12.50:8012/VISA_app_testing/index.php';
            var res = await http
                .post(Uri.encodeFull(link.srvLink(widget.mode)), headers: {
              "Accept": "application/json"
            }, body: {
              "VISA": onSMS ? "VISA_View_SMS" : "VISA_View_ONLINE",
              "identification": "${widget.apiKey}"
            });

            if (res.body.isNotEmpty && json.decode(res.body).toString() != "") {
              return json.decode(res.body);
            } else {
              return null;
            }
          } else {
            showSmsDialogue(context, 'Please Check your internet connection');
            return null;
          }
        } on FormatException catch (_) {
          print(_);
          return null;
        }
      } on ClientException catch (_) {
        return null;
      }
    } on SocketException catch (_) {
      print(_);
      return null;
    }
  }

  initRecords() async {
    try {
      if (getData() != null) {
        List _jsonValue = await getData();

        if (_jsonValue != null) {
          DbHelper.db.deleteRecord();
          for (var i = 0; i < _jsonValue.length; i++) {
            print('should add: ${_jsonValue[i]['recID']}');
            int k = await DbHelper.db.insert({
              DbHelper.colRecID: _jsonValue[i]['recID'],
              DbHelper.colRecDate: _jsonValue[i]['recDate'],
              DbHelper.colBatchedDate: _jsonValue[i]['BatchedDate'] == null
                  ? DateFormat('yyyy-MM-dd hh:mm:ss')
                      .format(DateTime(0000 - 00 - 00))
                  : _jsonValue[i]['BatchedDate'],
              DbHelper.colDateCancelled: _jsonValue[i]['DateCancelled'] == null
                  ? DateFormat('yyyy-MM-dd hh:mm:ss')
                      .format(DateTime(0000 - 00 - 00))
                  : _jsonValue[i]['DateCancelled'],
              DbHelper.colFarmerNo: _jsonValue[i]['FarmerNo'],
              DbHelper.colFarmerName: _jsonValue[i]['Name'],
              DbHelper.colPickupPoint: _jsonValue[i]['PickupPoint'],
              DbHelper.colWrapper: _jsonValue[i]['WrapperBales'],
              DbHelper.colNonWrapper: _jsonValue[i]['NonWrapperBales'],
              DbHelper.colSentFrom: _jsonValue[i]['SentFrom'],
              DbHelper.colCreatedBy: _jsonValue[i]['CreatedBy'],
              DbHelper.colRemarks: _jsonValue[i]['Remarks'] == null
                  ? 'Recorded'
                  : _jsonValue[i]['Remarks']
            });
            print('recorded data : $k');
          }
          initData('ONLINE');
          loading = false;
        } else {
          initData('ONLINE');
          print('json is null');
        }
      }
      loading = false;
    } on SocketException catch (_) {
      print(_);
    }
  }

  // Get the User's Farmers
  Future<List> getUFarmers() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          // String url = "http://122.2.12.50:8012/VISA_app_testing/index.php";
          var response = await http
              .post(Uri.encodeFull(link.srvLink(widget.mode)), headers: {
            "Accept": "application/json"
          }, body: {
            "getAOR": "validate",
            "identification": "${widget.apiKey}"
          });
          if (json.decode(response.body) != null) {
            return json.decode(response.body);
          } else {
            return null;
          }
        } on FormatException catch (_) {
          print(_);
          return ["null", "null"];
        }
      } else {
        return null;
      }
    } on SocketException catch (_) {
      print(_);
      return null;
    }
  }

  // initializing all the fetch data farmers from getUFarmers()
  initUFarmers() async {
    try {
      try {
        if (getUFarmers != null) {
          List _jsonValue = await getUFarmers();

          if (_jsonValue != null) {
            if (_jsonValue.toString() != "[]") {
              print(_jsonValue[0][0]);
              if (_jsonValue[0][0] == "null") {
                setState(() {
                  showDialog(
                      context: context,
                      builder: (c) => WillPopScope(
                            onWillPop: () {
                              return;
                            },
                            child: AlertDialog(
                              title: Text("No Farmer List",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: font, fontSize: 20)),
                              content: Text(
                                  "No list of farmers can find on your account.",
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 18,
                                  )),
                              actions: [
                                TextButton(
                                    onPressed: () => SystemChannels.platform
                                        .invokeMethod('SystemNavigator.pop'),
                                    child: Text("Exit",
                                        style: TextStyle(
                                          fontFamily: font,
                                          fontSize: 15,
                                        ))),
                                TextButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) => LogIn(
                                                  emei: widget.emei,
                                                ))),
                                    child: Text("ReLog-In",
                                        style: TextStyle(
                                          fontFamily: font,
                                          fontSize: 15,
                                        )))
                              ],
                            ),
                          ));
                });
              } else {
                for (var i = 0; i < _jsonValue.length; i++) {
                  List checkRecord =
                      await DbHelper.db.checkFarmers(_jsonValue[i]['FarmerNo']);

                  if (checkRecord.toString() == "[]") {
                    int k = await DbHelper.db.insertFarmers({
                      DbHelper.colUFarmerNo: _jsonValue[i]['FarmerNo'],
                      DbHelper.colUName: _jsonValue[i]['Name']
                    });
                    print('recorded data : $k');
                  } else {
                    print('should not add anymore data');
                  }
                }
              }
            }
          } else {
            print('none');
          }
        } else {
          print('none');
        }
      } catch (_) {
        print(_);
      }
    } on SocketException catch (_) {
      print(_);
    }
  }

  // Function for getting the farmer records from the database
  farmerRecord(String farmerRec) async {
    List checkRecord = await DbHelper.db.getFarmers(farmerRec);
    setState(() {
      farmers.clear();
      if (checkRecord.toString() != '[]') {
        for (var i = 0; i < checkRecord.length; i++) {
          farmers.add(Farmers(checkRecord[i]['id'], checkRecord[i]['FarmerNo'],
              checkRecord[i]['Name']));
        }
      } else {
        farmers.add(Farmers(1, 'none', 'NO LIST OF FARMERS.'));
      }
    });
  }

  // check if right device
  checDevice() async {
    try {
      try {
        try {
          // String url = "http://122.2.12.50:8012/VISA_app_testing/index.php";
          var check = await http.post(Uri.encodeFull(link.srvLink(widget.mode)),
              headers: {
                "Accept": "application/json"
              },
              body: {
                "check_apikey": "${widget.apiKey}",
                "Emei": "${widget.emei}"
              });
          if (check.body.isNotEmpty &&
              json.decode(check.body).toString() == "change_device") {
            print(json.decode(check.body));
            showDialog(
                context: context,
                builder: (c) => WillPopScope(
                      onWillPop: () {
                        return;
                      },
                      child: AlertDialog(
                        title: Text(
                          "Unregistered Device",
                          style: TextStyle(fontFamily: font, fontSize: 20),
                        ),
                        content: Text(
                          "You're currently login to a different device. Relogin or use your previous device for sending VISA",
                          style: TextStyle(fontFamily: font, fontSize: 18),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop'),
                            child: Text(
                              "Exit",
                              style: TextStyle(fontFamily: font, fontSize: 15),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LogIn(
                                          emei: widget.emei,
                                        ))),
                            child: Text(
                              "ReLog-in",
                              style: TextStyle(fontFamily: font, fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ));
          } else if (check.body.isNotEmpty &&
              json.decode(check.body).toString() == "right_device") {
            print('valid device');
          }
        } on FormatException catch (_) {
          print(_);
        }
      } on ClientException catch (_) {
        print(_);
      }
    } on SocketException catch (_) {
      print(_);
    }
  }

  @override
  void initState() {
    super.initState();
    checDevice();
    initRecords();
    initUFarmers();
    print(widget.apiKey);
    print(widget.emei);
    _dropdownMenus = buildDropdownMenuItem(_selectItems);
    _selectedItem = _dropdownMenus[0].value;
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });

    if (widget.position == "LFA") {
      nab = true;
    } else if (widget.position == "FS") {
      nab = false;
      isb = true;
    } else {
      nab = true;
      isb = false;
      dac = false;
    }

    _farName.addListener(() {
      farmerRecord(_farName.text);
      typed = _farName.text.isNotEmpty ? true : false;
      try {
        if (farmersNo.substring(0, 3).toString() == "NAB") {
          setState(() {
            nab = true;
          });
        } else {
          nab = false;
        }
      } catch (_) {}
    });
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

    if (_source.keys.isNotEmpty) {
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.none:
          setState(() {
            online = false;
            print('offline');
            initData('ONLINE');
          });
          break;
        case ConnectivityResult.mobile:
          setState(() {
            online = true;
            print('online');
            // initData('ONLINE');
          });
          break;
        case ConnectivityResult.wifi:
          setState(() {
            online = true;
            print('online');
            // initData('ONLINE');
          });

          break;
      }
    } else {
      print('no internet');
      showSmsDialogue(context, 'No Internet Connection');
    }

    Future<void> _pullRefresh() async {
      setState(() {
        initRecords();
        initUFarmers();
      });
    }

    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: WillPopScope(
        child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 0.08 * screenHeight,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: InkWell(
                child: Icon(
                  CupertinoIcons.bars,
                  color: Colors.grey,
                  size: 35,
                ),
                onTap: () {
                  setState(() {
                    scaffoldKey.currentState.openDrawer();
                  });
                },
              ),
              title: Stack(
                children: <Widget>[
                  Container(
                    width: 0.35 * screenWidth,
                    child: Text("VISA App",
                        style: TextStyle(
                            fontFamily: font,
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.w800)),
                  ),
                  Positioned(
                    left: 0.235 * screenWidth,
                    child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: online ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          online ? "Online" : "Offline",
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 12,
                          ),
                        )),
                  )
                ],
              ),
              actions: [
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    online
                        ? CupertinoIcons.person_crop_circle_badge_checkmark
                        : CupertinoIcons.person_crop_circle_badge_xmark,
                    color: online ? Colors.green : Colors.grey,
                    size: 35,
                  ),
                )
              ],
            ),
            drawer: SideBar(
              name: widget.name,
              position: widget.position,
            ),
            body: Stack(
              children: [menu(context), dashboard(context)],
            )),
        onWillPop: () => showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
                  title: Text("Close App"),
                  content: Text("Do you really want to close the app?"),
                  actions: [
                    TextButton(
                      child: Text("Yes",
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 15,
                          )),
                      onPressed: () => SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop'),
                    ),
                    TextButton(
                        child: Text("No",
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 15,
                            )),
                        onPressed: () => Navigator.pop(c, false))
                  ],
                )),
      ),
    );
  }

  Widget dashboard(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0.0 * screenHeight,
      bottom: 0,
      left: isCollapse ? 0 : 0.6 * screenWidth,
      right: isCollapse ? 0 : -0.63 * screenWidth,
      child: Material(
        elevation: 0,
        child: Container(
          child: ListView(children: [
            Column(
              children: <Widget>[
                // Text Form Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 10))
                      ]),
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Farmer Name",
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontSize: 18),
                                          ),
                                          Container(
                                              width: 160,
                                              child: TextFormField(
                                                autofocus: false,
                                                autocorrect: false,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .deny(RegExp("[0-9]"))
                                                ],
                                                textAlignVertical:
                                                    TextAlignVertical.bottom,
                                                controller: _farName,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .characters,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement
                                                        .enforced,
                                                decoration: InputDecoration(
                                                    labelText: 'Eg. John Lang',
                                                    labelStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Source Sans Pro'),
                                                    border: OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none),
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pick-up Point',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontSize: 18),
                                          ),
                                          Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              width: 160,
                                              child: DropdownButton(
                                                underline: SizedBox(),
                                                value: _selectedItem,
                                                items: _dropdownMenus,
                                                onChanged: onChangeItem,
                                              )),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  height: 1.5,
                                  width: 320,
                                  margin: EdgeInsets.only(bottom: 15, top: 5),
                                  color: Colors.black12,
                                ),
                                if (nab && widget.position != "FS")
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Wrapper',
                                              style: TextStyle(
                                                  fontFamily: 'Source Sans Pro',
                                                  fontSize: 18),
                                            ),
                                            Container(
                                                width: 160,
                                                child: TextFormField(
                                                  onTap: () => setState(
                                                      () => typed = false),
                                                  textAlignVertical:
                                                      TextAlignVertical.bottom,
                                                  controller: _wrapperBales,
                                                  maxLength: 3,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  buildCounter: (context,
                                                          {currentLength,
                                                          isFocused,
                                                          maxLength}) =>
                                                      null,
                                                  decoration: InputDecoration(
                                                      labelText: 'Eg. 100',
                                                      labelStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Source Sans Pro'),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .never),
                                                ))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Non-Wrapper',
                                              style: TextStyle(
                                                  fontFamily: 'Source Sans Pro',
                                                  fontSize: 18),
                                            ),
                                            Container(
                                              width: 160,
                                              child: TextFormField(
                                                onTap: () => setState(
                                                    () => typed = false),
                                                controller: _nowrapperBales,
                                                maxLength: 3,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                buildCounter: (context,
                                                        {currentLength,
                                                        isFocused,
                                                        maxLength}) =>
                                                    null,
                                                decoration: InputDecoration(
                                                    labelText: 'Eg. 100',
                                                    labelStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Source Sans Pro'),
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never,
                                                    border: OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                else
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Bales',
                                              style: TextStyle(
                                                  fontFamily: 'Source Sans Pro',
                                                  fontSize: 18),
                                            ),
                                            Container(
                                                width: 160,
                                                child: TextFormField(
                                                  onTap: () => setState(
                                                      () => typed = false),
                                                  textAlignVertical:
                                                      TextAlignVertical.bottom,
                                                  controller: _nowrapperBales,
                                                  maxLength: 3,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  buildCounter: (context,
                                                          {currentLength,
                                                          isFocused,
                                                          maxLength}) =>
                                                      null,
                                                  decoration: InputDecoration(
                                                      labelText: 'Eg. 10',
                                                      labelStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Source Sans Pro'),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .never),
                                                ))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 160,
                                      )
                                    ],
                                  ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: sending ? 40 : 320,
                                      height: 40,
                                      child: sending
                                          ? CircularProgressIndicator()
                                          : TextButton(
                                              onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (c) => AlertDialog(
                                                        title: Text(
                                                          "Notification",
                                                          style: TextStyle(
                                                              fontFamily: font),
                                                        ),
                                                        content: Text(
                                                          "I hereby certify that these tobaccos I have evaluated are free from NTRM, within the required Moisture level and compliant with other quality requirements as stated in the Policies and Procedures of Universal Leaf Philippines, Inc.",
                                                          style: TextStyle(
                                                            fontFamily: font,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      c),
                                                              child: Text(
                                                                  "Cancel")),
                                                          TextButton(
                                                              onPressed: () =>
                                                                  _send(),
                                                              child: Text("Ok"))
                                                        ],
                                                      )),
                                              child: Text(
                                                'Send',
                                                style: TextStyle(
                                                    fontFamily:
                                                        'Source Sans Pro',
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Color.fromRGBO(
                                                          0, 132, 189, 1),
                                                  primary: Colors.white,
                                                  shadowColor: Colors.grey)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Search results of farmers name
                      AnimatedPositioned(
                        duration: duration,
                        top: 0.12 * screenHeight,
                        left: 0.08 * screenWidth,
                        child: typed
                            ? Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 2)
                                    ]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      farmers.length,
                                      (index) => GestureDetector(
                                            onTap: () {
                                              farmersNo =
                                                  (farmers[index].farmerNo ==
                                                          "none")
                                                      ? ''
                                                      : farmers[index].farmerNo;
                                              _farName.text =
                                                  (farmers[index].farmerNo ==
                                                          "none")
                                                      ? ''
                                                      : farmers[index].name;
                                              typed = false;
                                              wrapperFocused = true;
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                    child: Text(farmers[index]
                                                                .farmerNo ==
                                                            "none"
                                                        ? farmers[index].name
                                                        : farmers[index]
                                                                .farmerNo
                                                                .substring(
                                                                    0, 3) +
                                                            ' - ' +
                                                            farmers[index]
                                                                .name)),
                                                (farmers.length == 4)
                                                    ? Container(
                                                        height: 0.7,
                                                        width:
                                                            0.7 * screenWidth,
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          )),
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),

// -------------- Table -------------------
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    (testData.isEmpty)
                        ? Container(
                            margin: EdgeInsets.only(top: 40),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 132, 189, 0.8),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 375,
                                child: DataTable(
                                    dataTextStyle: TextStyle(
                                        fontFamily: 'Source Sans Pro'),
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                        'Record ID',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Farmer No',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Farmer Name',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Pickup Point',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        widget.position == "FS"
                                            ? 'Bales'
                                            : 'Wrapper Bale',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      if (widget.position != "FS")
                                        DataColumn(
                                            label: Text(
                                          'Non-Wrapper',
                                          style: TextStyle(
                                              fontFamily: 'Source Sans Pro',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17,
                                              color: Colors.white),
                                        )),
                                      DataColumn(
                                          label: Text(
                                        'Date Recorded',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Date Cancelled',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Date Batched',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Created By',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Remarks',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Action',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                            color: Colors.white),
                                      ))
                                    ],
                                    rows: [
                                      DataRow(cells: [
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        if (widget.position != "FS")
                                          DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-')),
                                        DataCell(Text('-'))
                                      ])
                                    ]),
                              ),
                            ))
                        : Container(
                            margin: EdgeInsets.only(top: 40),
                            height: (testData.length >= 6)
                                ? null
                                : 0.7 * screenHeight,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 132, 189, 0.8),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: loading
                                ? Center(
                                    child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    color: Colors.white,
                                  ))
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: DataTable(
                                        sortAscending: true,
                                        columnSpacing: 35,
                                        dataTextStyle: TextStyle(
                                            fontFamily: 'Source Sans Pro'),
                                        columns: [
                                          DataColumn(
                                              label: Text(
                                            'Record ID',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Farmer No',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Farmer Name',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Pickup Point',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            widget.position == "FS"
                                                ? 'Bales'
                                                : 'Wrapper',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          if (widget.position != "FS")
                                            DataColumn(
                                                label: Text(
                                              'Non-Wrapper',
                                              style: TextStyle(
                                                  fontFamily: 'Source Sans Pro',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 17,
                                                  color: Colors.white),
                                            )),
                                          DataColumn(
                                              label: Text(
                                            'Date Recorded',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Date Cancelled',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Date Batched',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Created By',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Remarks',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Action',
                                            style: TextStyle(
                                                fontFamily: 'Source Sans Pro',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white),
                                          ))
                                        ],
                                        rows: List.generate(testData.length,
                                            (index) {
                                          if (testData.isEmpty)
                                            return DataRow(cells: [
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              if (widget.position != "FS")
                                                DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-'))
                                            ]);
                                          else
                                            return DataRow(cells: [
                                              DataCell(
                                                Text(testData[index]
                                                    .recID
                                                    .toString()),
                                              ),
                                              DataCell(
                                                Text(testData[index].farmerNo),
                                              ),
                                              DataCell(
                                                Text(testData[index].name),
                                              ),
                                              DataCell(Text(
                                                  testData[index].pickupPoint)),
                                              DataCell(Text(
                                                  widget.position == "FS"
                                                      ? testData[index]
                                                          .nonWrapper
                                                          .toString()
                                                      : testData[index]
                                                          .wrapper
                                                          .toString())),
                                              if (widget.position != "FS")
                                                DataCell(Text(testData[index]
                                                    .nonWrapper
                                                    .toString())),
                                              DataCell(Text(DateFormat().format(
                                                  testData[index].date))),
                                              DataCell(Text(DateFormat()
                                                          .format(testData[
                                                                  index]
                                                              .dateCancelled)
                                                          .toString()
                                                          .substring(0, 3) ==
                                                      'Jan'
                                                  ? '-'
                                                  : DateFormat().format(
                                                      testData[index]
                                                          .dateCancelled))),
                                              DataCell(Text(DateFormat()
                                                          .format(
                                                              testData[index]
                                                                  .dateBatched)
                                                          .toString()
                                                          .substring(0, 3) ==
                                                      'Jan'
                                                  ? '-'
                                                  : DateFormat().format(
                                                      testData[index]
                                                          .dateBatched))),
                                              DataCell(Text(testData[index]
                                                  .createdBy
                                                  .toString())),
                                              DataCell(Text(testData[index]
                                                  .remarks
                                                  .toString())),
                                              DataCell(Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  (testData[index]
                                                              .remarks
                                                              .toString() !=
                                                          "Cancelled")
                                                      ? TextButton(
                                                          onPressed: () =>
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      title:
                                                                          Text(
                                                                        "Confirm Cancellation",
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                font),
                                                                      ),
                                                                      content:
                                                                          Text(
                                                                        "Are you sure you want to cancel ${testData[index].name} - ${testData[index].farmerNo}?",
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                font,
                                                                            fontSize:
                                                                                17),
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Text("Cancel", style: TextStyle(fontFamily: font, fontSize: 18))),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              cancelVISA(testData[index].recID, testData[index].name, testData[index].farmerNo);
                                                                              FocusScope.of(context).requestFocus(new FocusNode());
                                                                            },
                                                                            child:
                                                                                Text("Ok", style: TextStyle(fontFamily: font, fontSize: 18)))
                                                                      ],
                                                                    );
                                                                  }),
                                                          child: Text('Cancel',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'Source Sans Pro',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900)),
                                                        )
                                                      : Container()
                                                ],
                                              ))
                                            ]);
                                        }),
                                      ),
                                    ),
                                  )),
                  ],
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget menu(context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: 0.07 * screenWidth,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Menu",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontFamily: font,
                    fontWeight: FontWeight.w800),
              ),
            ),
            Row(
              children: <Widget>[
                Stack(children: [
                  Icon(
                    CupertinoIcons.person_alt_circle,
                    size: 0.18 * screenWidth,
                    color: Colors.grey.withOpacity(0.9),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 0.053 * screenHeight),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Icon(
                      CupertinoIcons.largecircle_fill_circle,
                      color: online ? Colors.green : Colors.grey,
                      size: 0.05 * screenWidth,
                    ),
                  )
                ]),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: TextStyle(
                              fontFamily: font,
                              fontSize: 15,
                              fontWeight: FontWeight.w900),
                        ),
                        Text(widget.position,
                            style: TextStyle(
                              fontFamily: font,
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ))
                      ]),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 20,
              ),
              child: Row(
                children: <Widget>[
                  // Settings Button
                  Container(
                    width: 0.25 * screenWidth,
                    height: 0.09 * screenHeight,
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
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(0, 2))
                        ]),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.transparent)),
                      onPressed: () {
                        onSMS = false;
                        isCollapse = !isCollapse;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(CupertinoIcons.globe,
                                size: 20, color: Colors.grey.withOpacity(0.9)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Online VISA',
                                style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  //Manual VISA Button
                  Container(
                    width: 0.25 * screenWidth,
                    height: 0.09 * screenHeight,
                    margin: const EdgeInsets.only(left: 12.0),
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
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(0, 2))
                        ]),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.transparent)),
                      onPressed: () {
                        onSMS = true;
                        isCollapse = !isCollapse;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(CupertinoIcons.envelope,
                                size: 20, color: Colors.grey.withOpacity(0.9)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'SMS VISA',
                                style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: Row(
                children: <Widget>[
                  // Help Button
                  Container(
                    width: 0.25 * screenWidth,
                    height: 0.09 * screenHeight,
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
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(0, 2))
                        ]),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.transparent)),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Help',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Source Sans Pro',
                                    fontSize: 20),
                              ),
                              content: Text(
                                'Coming soon! Stay tune for the next update.',
                                style:
                                    TextStyle(fontFamily: font, fontSize: 18),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      isCollapse = !isCollapse;
                                    },
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                          fontFamily: 'Source Sans Pro'),
                                    ))
                              ],
                            );
                          }),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 25, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(CupertinoIcons.question,
                                size: 20, color: Colors.grey.withOpacity(0.9)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Help',
                                style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _connectivity.disposeStream();
    // _farmerNo.dispose();
  }
}

showSmsDialogue(BuildContext context, String message) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      "Notification",
      textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'Source Sans Pro', fontSize: 20),
    ),
    content: Container(
      child: Text(
        message,
        style: TextStyle(fontFamily: 'Source Sans Pro'),
      ),
    ),
    actions: [okButton],
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}
