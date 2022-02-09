import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ota_update/ota_update.dart';
import 'package:pickup_nitofication/Servers.dart';
import 'package:platform/platform.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:install_plugin/install_plugin.dart';

class AppUpdater extends StatefulWidget {
  AppUpdater({Key key, this.appName}) : super(key: key);
  final String appName;
  @override
  _AppUpdaterState createState() => _AppUpdaterState();
}

class _AppUpdaterState extends State<AppUpdater> {
  OtaEvent currentEvent;
  @override
  void initState() {
    super.initState();

    tryOtaUpdate();
  }

  Future<void> tryOtaUpdate() async {
    try {
      OtaUpdate()
          .execute(
        '${Servers.serverURL}/LeafAppUpdates/AppUpdates/${widget.appName}',
        destinationFilename: '${widget.appName}',
        //FOR NOW ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
        sha256checksum:
            "d6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478",
      )
          .listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  initInstall() async {
    var path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    if (const LocalPlatform().isAndroid) {
      InstallPlugin.installApk(
              path + '/${widget.appName}', 'com.ulpi.sms_notification_app.ssdg')
          .then((result) {
        print('install apk $result');
      }).catchError((error) {
        print('install apk error: $error');
      });
    }
    print('installing...');
  }

  conditioner() {
    try {
      var val = int.parse(currentEvent.value);
      double progress;
      if (currentEvent.value == 'Checksum verification failed')
        progress = 1.0;
      else
        progress = val * 0.01;
      return progress;
    } on FormatException catch (_) {
      initInstall();
      double progress = 1.0;
      return progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentEvent == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/img/pickup-logo-transpa.png'),
                width: 120,
              )
            ],
          ),
        ),
      );
    }
    return Scaffold(
        body: WillPopScope(
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage('assets/img/pickup-logo-transpa.png'),
                width: 90,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'VISA App',
                  style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 243,
                child: LinearProgressIndicator(
                  value: conditioner(),
                  backgroundColor: Colors.teal.withOpacity(0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
              if (currentEvent.status.toString() != 'OtaStatus.CHECKSUM_ERROR')
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Downloading Update... ${currentEvent.value}%',
                    style:
                        TextStyle(color: Colors.grey, fontFamily: 'Open Sans'),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Installing...',
                    style:
                        TextStyle(color: Colors.grey, fontFamily: 'Open Sans'),
                  ),
                )
            ],
          ),
        ),
      ),
      onWillPop: () => showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                title: Text('Exit Update'),
                content: Text('Do you really want to exit?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                      child: Text('Yes')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(c, false);
                      },
                      child: Text('No'))
                ],
              )),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
