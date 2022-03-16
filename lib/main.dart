import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickup_nitofication/Servers.dart';
import 'package:pickup_nitofication/Updater.dart';
import 'package:pickup_nitofication/dashboard.dart';
// import 'package:pickup_nitofication/DashboardNew.dart';
import 'package:telephony/telephony.dart';
import 'package:connectivity/connectivity.dart';
import 'MyConnectivity.dart';
import 'package:pickup_nitofication/login.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info/package_info.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pickup_nitofication/database_helper.dart';
import 'User.dart';

// onBackgroundMessage(SmsMessage message) {
//   print(message.body.toString());
// }

// declare for debugging mode or not.
bool testMode = false;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map _source = {ConnectivityResult.none: false};
  MyConnectivity _connectivity = MyConnectivity.instance;
  Servers link = Servers.ins;
  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  final telephony = Telephony.instance;
  bool v = false;
  List<User> user = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();

    checkAPI();
    fetchdata();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
  }

  snacky(String message) {
    final snackbar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  checkAPI() async {
    List<Map<String, dynamic>> selectUser = await DbHelper.db.getClient();
    // List selectUser = await DbHelper.db.getClient({DbHelper.colID: 1});

    if (selectUser.toString() != '[]')
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Dashboard(
                  emei: _platformImei,
                  title: 'VISA App',
                  apiKey: selectUser[0]['APIKey'],
                  name: selectUser[0]['Name'],
                  mode: testMode,
                  position: selectUser[0]['Position'])));
  }

  // Initialize Platform
  Future<void> initPlatformState() async {
    String platformImei;
    String idunique;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformImei =
          await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);

      if (platformImei.isNotEmpty) {
        PermissionStatus permissionStorage = await Permission.storage.request();
        if (permissionStorage.isGranted) {
          print('permsion storage is granted');
        }

        final bool permissionsGranted =
            await telephony.requestPhoneAndSmsPermissions;

        if (permissionsGranted != null && permissionsGranted) {
          print('permission granted');
        }
      }
      idunique = await ImeiPlugin.getId();
    } on PlatformException {
      platformImei = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformImei = platformImei;
      uniqueId = idunique;
    });
  }

  // Check if the App is in Latestz
  Future<String> getJsonData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String version = packageInfo.version;
        String urlApi =
            "${link.srvLink(testMode)}/VISA_app/index.php?app_update=" +
                '$version';
        http.Response response = await http.get(urlApi);
        if (json.decode(response.body) != null) {
          return json.decode(response.body);
        } else {
          return 'null';
        }
      } else {
        snacky('Please check your internet connection');
        return 'null';
      }
    } catch (_) {
      print(_);
      return 'null';
    }
  }

  fetchdata() async {
    try {
      if (getJsonData() != null) {
        String _jsonValue = await getJsonData();

        if (_jsonValue != null) {
          print(_jsonValue);
          if (_jsonValue != 'latest version' && _jsonValue != "null") {
            updateDialog(context, _jsonValue);
          } else {
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            String version = packageInfo.version;
            try {
              var path = await ExtStorage.getExternalStoragePublicDirectory(
                  ExtStorage.DIRECTORY_DOWNLOADS);
              final dir = Directory(path + '/ulpi_visa$version.apk');
              dir.deleteSync(recursive: true);
            } on FileSystemException catch (_) {
              print(_);
            }
          }
        } else {}
      } else {}
    } on SocketException catch (_) {
      snacky('No Internet Connection');
      print(_);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));

    Widget page = Container(
      color: Colors.blue.withOpacity(0.15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/img/pickup-logo-transpa.png'),
              width: 110,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(
                'VISA Mobile App',
                style: TextStyle(
                    fontFamily: 'Source Sans Pro',
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
            )
          ],
        ),
      ),
    );

    if (_source.keys.isNotEmpty) {
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.none:
          setState(() {
            page = LogIn(emei: _platformImei, mode: testMode);
          });
          break;
        case ConnectivityResult.mobile:
          if (v == false) {
            setState(() {
              page = LogIn(emei: _platformImei, mode: testMode);
            });
          }
          break;
        case ConnectivityResult.wifi:
          if (v == false) {
            setState(() {
              page = LogIn(emei: _platformImei, mode: testMode);
            });
          }
          break;
      }
    } else {
      snacky('No Internet Connection');
    }

    return Scaffold(
      body: page,
    );
  }

  @override
  void dispose() {
    super.dispose();
    // _connectivity.disposeStream();
    // deactivate();
  }
}

updateDialog(BuildContext context, String appname) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("Update Now"),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppUpdater(appName: appname)),
      );
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Update Available"),
    content: Text('There was a new update from the app.'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        child: alert,
        onWillPop: () {
          return;
        },
      );
    },
  );
}
