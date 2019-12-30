import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/auth-service.dart';
import '../../blocs/validators.dart';
import 'otp-verify.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();

class ResetPassword extends StatefulWidget {
  var locale;
  final Map<String, Map<String, String>> localizedValues;

  ResetPassword({Key key, this.locale, this.localizedValues}) : super(key: key);
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String email;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void sendOTP() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      AuthService.sendOTP({'email': email}).then((onValue) {
        try {
          if (onValue['message'] != null) {
            showSnackbar(onValue['message']);
            if (onValue['token'] != null) {
              Future.delayed(Duration(milliseconds: 1500), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => OtpVerify(
                      otpToken: onValue['token'],
                      locale: widget.locale,
                      localizedValues: widget.localizedValues,
                    ),
                  ),
                );
              });
            }
          }
          setState(() {
            isLoading = false;
          });
        } catch (error, stackTrace) {
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
        showSnackbar(onError);
        setState(() {
          isLoading = false;
        });
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
            title: Text(
              MyLocalizations.of(context).resetPassword,
            ),
            centerTitle: true,
            backgroundColor: PRIMARY,
            elevation: 0.0,
          ),
          body: new ListView(
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
                    child: _buildEmailField(),
                  ),
                  _buildSubmitButton(),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildEmailField() {
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
            padding: EdgeInsetsDirectional.only(top: 30.0, bottom: 30.0),
            child: Center(
                child: Text(
              MyLocalizations.of(context).resetPasswordOtp,
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
                    keyboardType: TextInputType.emailAddress,
                    validator: (String value) {
                      if (value.isEmpty ||
                          !RegExp(Validators.emailPattern).hasMatch(value)) {
                        return MyLocalizations.of(context)
                            .pleaseEnterValidEmail;
                      }
                    },
                    onSaved: (value) {
                      email = value;
                    },
                    decoration: new InputDecoration(
                      labelText: MyLocalizations.of(context).emailId,
                      hintStyle: hintStyleGreyLightOSR(),
                      contentPadding: EdgeInsets.all(12.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Icon(
                    Icons.email,
                    size: 16.0,
                    color: greyTextc,
                  ),
                ),
              ],
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: new Text(
              MyLocalizations.of(context).resetMessage,
              textAlign: TextAlign.center,
              style: subTitleWhiteLightOSR(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
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
                    MyLocalizations.of(context).resetPassword,
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
          onPressed: sendOTP,
        ),
      ),
    );
  }
}
