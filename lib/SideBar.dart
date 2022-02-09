import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pickup_nitofication/dashboard.dart';

class SideBar extends StatelessWidget {
  SideBar({Key key, this.name, this.position, this.apiKey}) : super(key: key);
  final String name;
  final String position;
  final String apiKey;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return Container(
      child: Drawer(
          elevation: 0,
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            Container(
              height: 0.25 * screenHeight,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: DrawerHeader(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Menu',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 27,
                          fontFamily: font,
                          fontWeight: FontWeight.w900,
                        )),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
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
                                  name.toString(),
                                  style: TextStyle(
                                      fontFamily: font,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900),
                                ),
                                Text(position.toString(),
                                    style: TextStyle(
                                      fontFamily: font,
                                      color: Colors.black.withOpacity(0.6),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ))
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Drawer Buttons
            Container(
              margin: const EdgeInsets.only(
                left: 20,
              ),
              child: Row(
                children: <Widget>[
                  // Online VISA Button
                  Container(
                    width: 0.3 * screenWidth,
                    height: 0.1 * screenHeight,
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

                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 0, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(CupertinoIcons.globe,
                                size: 0.035 * screenHeight,
                                color: Colors.grey.withOpacity(0.9)),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 0.005 * screenHeight),
                              child: Text(
                                'Online VISA',
                                style: TextStyle(
                                    fontFamily: 'Source Sans Pro',
                                    fontSize: 0.041 * screenWidth,
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
                    width: 0.3 * screenWidth,
                    height: 0.1 * screenHeight,
                    margin: const EdgeInsets.only(left: 15.0),
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
                        showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                                  title: Text(
                                    'SMS VISA',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Source Sans Pro',
                                        fontSize: 20),
                                  ),
                                  content: Text(
                                      'Menu unavailable currently on development.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                              fontFamily: 'Source Sans Pro'),
                                        ))
                                  ],
                                ));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 0.042 * screenWidth, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(CupertinoIcons.envelope,
                                size: 0.035 * screenHeight,
                                color: Colors.grey.withOpacity(0.9)),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 0.005 * screenHeight),
                              child: Text(
                                'SMS VISA',
                                style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 0.041 * screenWidth,
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
              margin: const EdgeInsets.only(left: 20, top: 12),
              child: Row(
                children: <Widget>[
                  // Help Button
                  Container(
                    width: 0.3 * screenWidth,
                    height: 0.1 * screenHeight,
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
                                  'Coming soon! Stay tune for the next update.'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
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
                        padding: EdgeInsets.only(
                            right: 0.11 * screenWidth, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(CupertinoIcons.question,
                                size: 0.035 * screenHeight,
                                color: Colors.grey.withOpacity(0.9)),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 0.005 * screenHeight),
                              child: Text(
                                'Help',
                                style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 0.042 * screenWidth,
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
          ])),
    );
  }
}
