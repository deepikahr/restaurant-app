import 'package:RestaurantSaas/localizations.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

SentryError sentryError = new SentryError();

class AddAddressPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  AddAddressPage({Key key, this.locale, this.localizedValues})
      : super(key: key);
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> address = {
    'name': null,
    'contactNumber': null,
    'zip': null,
    'locationName': null,
    'city': null,
    'state': null,
    'country': null,
    'addressType': 'Home',
    'address': null,
    'isSelected': false
  };
  bool isLoading = false;

  _saveAddress() async {
    if (_formKey.currentState.validate()) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      _formKey.currentState.save();
      ProfileService.addAddress(address).then((onValue) {
        try {
          if (mounted) {
            setState(() {
              isLoading = false;
              Navigator.of(context).pop(address);
            });
          }
        } catch (error, stackTrace) {
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: Locale(widget.locale),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          MyLocalizationsDelegate(widget.localizedValues),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: languages.map((language) => Locale(language, '')),
        home: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            backgroundColor: PRIMARY,
            elevation: 0.0,
            title: new Text(
              MyLocalizations.of(context).deliveryAddress,
              style: titleBoldWhiteOSS(),
            ),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[
                Container(
                  height: screenHeight(context),
                  child: ListView(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
                        child: new Column(
                          children: <Widget>[
                            new Text(
                              MyLocalizations.of(context).whereToDeliver,
                              style: titleDarkOSS(),
                            ),
                            new Text(
                              MyLocalizations.of(context).byCreating,
                              style: textOSR(),
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).fullName,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    child: new Container(
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: new TextFormField(
                                    decoration: InputDecoration(
                                        hintText: MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context)
                                                .fullName,
                                        hintStyle: hintStyleSmallLightOSR(),
                                        border: InputBorder.none),
                                    style: textOSR(),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return MyLocalizations
                                                    .of(context)
                                                .please +
                                            " " +
                                            MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context)
                                                .fullName;
                                      } else {
                                        return address['name'] = value;
                                      }
                                    },
                                  ),
                                ))
                              ],
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).mobileNumber,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: BorderDirectional(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: TextFormField(
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText:
                                        MyLocalizations.of(context).enterYour +
                                            "  " +
                                            MyLocalizations.of(context)
                                                .mobileNumber,
                                    counterText: "",
                                    hintStyle: hintStyleSmallLightOSR(),
                                    border: InputBorder.none),
                                style: textOSR(),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return MyLocalizations.of(context).please +
                                        " " +
                                        MyLocalizations.of(context).enterYour +
                                        "  " +
                                        MyLocalizations.of(context)
                                            .mobileNumber;
                                  } else {
                                    return address['contactNumber'] = value;
                                  }
                                },
                              ),
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).postalCode,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    child: new Container(
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: new TextFormField(
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                        counterText: "",
                                        hintText: MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context)
                                                .postalCode,
                                        hintStyle: hintStyleSmallLightOSR(),
                                        border: InputBorder.none),
                                    style: textOSR(),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return MyLocalizations
                                                    .of(context)
                                                .please +
                                            " " +
                                            MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context)
                                                .postalCode;
                                      } else {
                                        return address['zip'] = value;
                                      }
                                    },
                                  ),
                                ))
                              ],
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).subUrban,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    child: new Container(
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: new TextFormField(
                                    decoration: InputDecoration(
                                        hintText: MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context)
                                                .subUrban,
                                        hintStyle: hintStyleSmallLightOSR(),
                                        border: InputBorder.none),
                                    style: textOSR(),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return MyLocalizations
                                                    .of(context)
                                                .please +
                                            " " +
                                            MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context)
                                                .subUrban;
                                      } else {
                                        return address['locationName'] = value;
                                      }
                                    },
                                  ),
                                ))
                              ],
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).city,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    child: new Container(
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: new TextFormField(
                                    decoration: InputDecoration(
                                      hintText: MyLocalizations.of(context)
                                              .enterYour +
                                          "  " +
                                          MyLocalizations.of(context).city,
                                      hintStyle: hintStyleSmallLightOSR(),
                                      border: InputBorder.none,
                                    ),
                                    style: textOSR(),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return MyLocalizations
                                                    .of(context)
                                                .please +
                                            " " +
                                            MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context).city;
                                      } else {
                                        return address['city'] = value;
                                      }
                                    },
                                  ),
                                ))
                              ],
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).state,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    child: new Container(
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: new TextFormField(
                                    decoration: InputDecoration(
                                      hintText: MyLocalizations.of(context)
                                              .enterYour +
                                          "  " +
                                          MyLocalizations.of(context).state,
                                      hintStyle: hintStyleSmallLightOSR(),
                                      border: InputBorder.none,
                                    ),
                                    style: textOSR(),
                                    validator: (String value) {
                                      return address['state'] = value;
                                    },
                                  ),
                                ))
                              ],
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).country,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    child: new Container(
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: new TextFormField(
                                    decoration: InputDecoration(
                                      hintText: MyLocalizations.of(context)
                                              .enterYour +
                                          "  " +
                                          MyLocalizations.of(context).country,
                                      hintStyle: hintStyleSmallLightOSR(),
                                      border: InputBorder.none,
                                    ),
                                    style: textOSR(),
                                    validator: (String value) {
                                      return address['country'] = value;
                                    },
                                  ),
                                ))
                              ],
                            ),
                            new Padding(padding: EdgeInsets.only(top: 20.0)),
                            new Row(
                              children: <Widget>[
                                new Text(
                                  MyLocalizations.of(context).address,
                                  style: hintStyleSmallDarkBoldOSR(),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    child: new Container(
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: new TextFormField(
                                    decoration: InputDecoration(
                                      hintText: MyLocalizations.of(context)
                                              .enterYour +
                                          "  " +
                                          MyLocalizations.of(context).address,
                                      hintStyle: hintStyleSmallLightOSR(),
                                      border: InputBorder.none,
                                    ),
                                    style: textOSR(),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return MyLocalizations
                                                    .of(context)
                                                .please +
                                            " " +
                                            MyLocalizations.of(context)
                                                .enterYour +
                                            "  " +
                                            MyLocalizations.of(context).address;
                                      } else {
                                        return address['address'] = value;
                                      }
                                    },
                                  ),
                                ))
                              ],
                            ),
                            Container(
                              color: bgColor,
                              height: 50.0,
                              child: Text(""),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  width: screenWidth(context),
                  top: screenHeight(context) * 0.78,
                  child: new Padding(
                    padding: EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {
                        _saveAddress();
                      },
                      child: isLoading
                          ? Container(
                              alignment: AlignmentDirectional.center,
                              width: screenWidth(context),
                              height: 44.0,
                              decoration: BoxDecoration(
                                  color: PRIMARY,
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: Image.asset(
                                'lib/assets/icon/spinner.gif',
                                width: 19.0,
                                height: 19.0,
                              ),
                            )
                          : Container(
                              alignment: AlignmentDirectional.center,
                              width: screenWidth(context),
                              height: 44.0,
                              decoration: BoxDecoration(
                                  color: PRIMARY,
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: new Text(
                                  MyLocalizations.of(context).addAddress,
                                  style: subTitleWhiteBOldOSB()),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
