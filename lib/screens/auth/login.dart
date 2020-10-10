import 'dart:async';

import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth-service.dart';
import '../../services/common.dart';
import '../../services/localizations.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import 'forgot-password.dart';
import 'registration.dart';

SentryError sentryError = new SentryError();

class LoginPage extends StatefulWidget {
  final isDrawe;
  final String locale;
  final Map<String, Map<String, String>> localizedValues;

  LoginPage({Key key, this.isDrawe, this.locale, this.localizedValues})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String mobileNumber, password;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    mobileNumber = mobileNumber ?? 'user@ionicfirebaseapp.com';
    super.initState();
  }

  login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_formKey.currentState.validate()) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      _formKey.currentState.save();
      var body;
      if (RegExp(EMAIL_PATTERN).hasMatch(mobileNumber)) {
        body = {
          'email': mobileNumber,
          'password': password,
          "playerId": prefs.getString("playerId")
        };
      } else {
        body = {
          'email': mobileNumber,
          'password': password,
          "playerId": prefs.getString("playerId")
        };
      }
      AuthService.login(body).then((onValue) {
        try {
          if (onValue['message'] != null) {
            if (onValue['message'].toString().compareTo(
                    'Your Mobile Number is not verified yet. Please verify it and then continue') ==
                0) {
              showVerifySnackbar(onValue['message']);
            } else {
              showSnackbar(onValue['message']);
            }
          }
          if (onValue['token'] != null) {
            Common.setToken(onValue['token']).then((saved) {
              if (saved) {
                showSnackbar(MyLocalizations.of(context).loginSuccessful);
                Future.delayed(Duration(milliseconds: 1500), () {
                  if (widget.isDrawe == true) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => HomePage(
                              locale: widget.locale,
                              localizedValues: widget.localizedValues),
                        ),
                        (Route<dynamic> route) => route.isFirst);
                  } else {
                    Navigator.of(context).pop(
                      MyLocalizations.of(context).success,
                    );
                  }
                });
              }
            });
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

  void showVerifySnackbar(message) {
    final snackBar = SnackBar(
      duration: Duration(minutes: 1),
      content: RichText(
          text: TextSpan(text: message, children: [
        TextSpan(text: '  '),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ForgotPassword(
                            title: MyLocalizations.of(context).verifyOtp,
                            locale: widget.locale,
                            localizedValues: widget.localizedValues,
                          ))),
            text: MyLocalizations.of(context).verifyNow,
            style: textPrimaryBoldOSR())
      ])),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0XFF303030),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // buildLoginPageBg(),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildLoginPageLogo(),
                  buildLoginPageForm(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLoginPageBg() {
    return Positioned(
      top: 0.0,
      child: Image(
        image: AssetImage("lib/assets/bgImgs/background.png"),
        fit: BoxFit.cover,
        height: screenHeight(context),
        width: screenWidth(context),
      ),
    );
  }

  Widget buildLoginPageLogo() {
    return Padding(
      padding: EdgeInsets.only(top: 70.0, bottom: 40.0),
      child: Image(
        image: AssetImage("lib/assets/logos/logo.png"),
        fit: BoxFit.cover,
        width: 95.0,
      ),
    );
  }

  Widget buildLoginPageForm() {
    return Form(
      key: _formKey,
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              buildEmailTextField(),
              buildPasswordTextField(),
              buildLoginButton(),
              buildForgotPasswordButton(),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 40.0, bottom: 20.0),
                child: Text(
                  MyLocalizations.of(context).dontHaveAccountYet,
                  style: subTitleWhiteLightOSR(),
                ),
              ),
              buildSignupButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmailTextField() {
    return Container(
      color: Colors.white,
      child: TextFormField(
        initialValue: 'user@ionicfirebaseapp.com',
        keyboardType: TextInputType.emailAddress,
        validator: (String value) {
          if (value.isEmpty) {
            return MyLocalizations.of(context)
                .pleaseEnterValidEmailOrPhoneNumber;
          }
          return null;
        },
        onChanged: (String value) {
          mobileNumber = value;
        },
        decoration: InputDecoration(
          labelText: MyLocalizations.of(context).yourEmailOrMobileNumber,
          labelStyle: hintStyleGreyLightOSR(),
          contentPadding: EdgeInsets.all(10),
          border: InputBorder.none,
        ),
        style: textBlackOSR(),
      ),
    );
  }

  Widget buildPasswordTextField() {
    return Container(
      margin: EdgeInsets.only(top: 4.0),
      color: Colors.white,
      child: TextFormField(
        initialValue: '123456',
        keyboardType: TextInputType.text,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return MyLocalizations.of(context).pleaseEnterValidPassword;
          } else
            return null;
        },
        onSaved: (String value) {
          password = value;
        },
        decoration: InputDecoration(
          labelText: MyLocalizations.of(context).yourPassword,
          labelStyle: hintStyleGreyLightOSR(),
          contentPadding: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: 10.0,
            bottom: 10.0,
          ),
          border: InputBorder.none,
        ),
        style: textBlackOSR(),
        obscureText: true,
      ),
    );
  }

  Widget buildLoginButton() {
    return RawMaterialButton(
      onPressed: isLoading ? null : login,
      child: Container(
        alignment: AlignmentDirectional.center,
        margin: const EdgeInsetsDirectional.only(top: 10.0),
        height: 56.0,
        width: screenWidth(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              const Color(0xFFFFFFFF).withOpacity(0.25),
              const Color(0xFFFFFFFF).withOpacity(0.25)
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              MyLocalizations.of(context).loginToYourAccount,
              style: subTitleWhiteLightOSR(),
            ),
            Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0)),
            isLoading
                ? Image.asset(
                    'lib/assets/icon/spinner.gif',
                    width: 19.0,
                    height: 19.0,
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }

  Widget buildForgotPasswordButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 0.0, bottom: 20.0),
      child: FlatButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ForgotPassword(
                  title: MyLocalizations.of(context).forgotPassword,
                  locale: widget.locale,
                  localizedValues: widget.localizedValues,
                ),
              ),
            );
          },
          child: Text(
            MyLocalizations.of(context).forgotPassword,
            style: hintStyleLightOSB(),
          )),
    );
  }

  Widget buildSignupButton() {
    return RawMaterialButton(
      child: Container(
        alignment: AlignmentDirectional.center,
        height: 56.0,
        width: screenWidth(context),
        decoration: BoxDecoration(border: Border.all(color: Colors.white70)),
        child: Text(
          MyLocalizations.of(context).signUpNow,
          style: subTitleWhiteShadeLightOSR(),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RegisterForm(
              locale: widget.locale,
              localizedValues: widget.localizedValues,
            ),
          ),
        );
      },
    );
  }
}
