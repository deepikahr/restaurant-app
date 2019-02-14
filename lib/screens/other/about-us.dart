import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text("About Us"),
      ),
      body: new SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Image.asset('lib/assets/imgs/chicken.png'),
            new Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Text(
                      'Restaurant Sass',
                      style: titleBoldOSL(),
                    ),
                    new Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: new Text(
                        'Short Description',
                        style: textOSL(),
                      ),
                    ),
                    new Text(
                      'Grilled Chicken Lorem ipsum dolor sit amet, consectetur adipiscing elit,'
                          ' sed do eiusmod tempor incididunt ut labore et dolore magna ',
                      style: textOS(),
                    ),
                    new Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: new Text(
                        'Mobile No',
                        style: textOSL(),
                      ),
                    ),
                    new Text(
                      '90989098000',
                      style: textOS(),
                    ),
                    new Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: new Text(
                        'Email ID',
                        style: textOSL(),
                      ),
                    ),
                    new Text(
                      'ionicfirebaseapp@gmail.com',
                      style: textOS(),
                    ),
                    new Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: new Text(
                        'Address',
                        style: textOSL(),
                      ),
                    ),
                    new Text(
                      '1440 , South end , A road , Marenahalli, Bangalore',
                      style: textOS(),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
