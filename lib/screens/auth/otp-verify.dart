import 'dart:async';

import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/auth-service.dart';
import 'new-password.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

SentryError sentryError = new SentryError();

class OtpVerify extends StatefulWidget {
  final String otpToken;
  final String locale;
  final Map<String, Map<String, String>> localizedValues;
  OtpVerify({Key key, this.otpToken, this.locale, this.localizedValues})
      : super(key: key);
  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  bool isLoading = false;
  String otp;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void verifyOTP() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      AuthService.verifyOTP({'otp': otp}, widget.otpToken).then((onValue) {
        try {
          if (onValue['message'] != null) {
            showSnackbar(onValue['message']);
            if (onValue['token'] != null) {
              Future.delayed(Duration(milliseconds: 1500), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => NewPassword(
                      otpToken: onValue['token'],
                      locale: widget.locale,
                      localizedValues: widget.localizedValues,
                    ),
                  ),
                );
              });
            }
          }
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        } catch (error, stackTrace) {
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        showSnackbar(onError);
      });
    }
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
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
        key: _scaffoldKey,
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
          title: Text(MyLocalizations.of(context).verifyOtp),
          centerTitle: true,
          backgroundColor: PRIMARY,
        ),
        body: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Image(
                  image: AssetImage("lib/assets/bgImgs/background.png"),
                  fit: BoxFit.fill,
                  height: screenHeight(context),
                  width: screenWidth(context),
                ),
                Form(
                  key: _formKey,
                  child: _buildOTPField(),
                ),
                _buildVerifyOTPButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 14.0, end: 14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 100),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: 30.0,
              bottom: 30.0,
            ),
            child: Center(
                child: Text(
              MyLocalizations.of(context).verifyOtp + '!',
              textAlign: TextAlign.center,
              style: subTitleWhiteLightOSR(),
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 14.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  flex: 9,
                  child: TextFormField(
                    decoration: new InputDecoration(
                      labelText: MyLocalizations.of(context).otp,
                      hintStyle: hintStyleGreyLightOSR(),
                      contentPadding: EdgeInsets.all(12.0),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String value) {
                      if (value.isEmpty || value.length < 6) {
                        return MyLocalizations.of(context).otpErrorMessage;
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      otp = value;
                    },
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Icon(Icons.email, size: 16.0, color: greyTextc),
                ),
              ],
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: new Text(
              MyLocalizations.of(context).otpMessage,
              textAlign: TextAlign.center,
              style: subTitleWhiteLightOSR(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyOTPButton() {
    return Positioned(
      width: screenWidth(context),
      top: screenHeight(context) * 0.76,
      child: Container(
        padding: const EdgeInsets.all(14.0),
        child: RawMaterialButton(
          child: !isLoading
              ? Container(
                  alignment: AlignmentDirectional.center,
                  margin: EdgeInsets.only(left: 5.0, right: 5.0),
                  height: 56.0,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.white70)),
                  child: Text(
                    MyLocalizations.of(context).verifyOtp,
                    style: subTitleWhiteShadeLightOSR(),
                  ),
                )
              : Container(
                  alignment: AlignmentDirectional.center,
                  margin: EdgeInsets.only(left: 5.0, right: 5.0),
                  height: 56.0,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.white70)),
                  child: Image.asset(
                    'lib/assets/icon/spinner.gif',
                    width: 40.0,
                    height: 40.0,
                  ),
                ),
          onPressed: verifyOTP,
        ),
      ),
    );
  }
}
