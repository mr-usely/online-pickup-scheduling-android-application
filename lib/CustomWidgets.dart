import 'package:flutter/material.dart';

class ListInfo extends StatelessWidget {
  const ListInfo({Key key, this.name, this.farmerno}) : super(key: key);
  final String name, farmerno;
  @override
  Widget build(BuildContext context) {
    bool expand = false;
    return GestureDetector(
      onTap: () {
        expand = !expand;
        print(expand);
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: expand ? 100 : 90,
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(2, 85, 207, 0.16),
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
                          farmerno,
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
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "ALEJO, JULIETA PAGUIRIGAN",
                          style: TextStyle(
                              fontFamily: "Source Sans Pro", fontSize: 15),
                        ),
                        Expanded(child: SizedBox()),
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  fontFamily: 'Source Sans Pro',
                                  fontWeight: FontWeight.w600),
                            ),
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(0, 128, 255, 0.7),
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9))),
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
    );
  }
}
