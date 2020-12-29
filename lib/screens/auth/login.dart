import 'dart:async';

import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:RestaurantSaas/widgets/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/types/gf_button_type.dart';
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
            style: textprimaryBoldOSR())
      ])),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: authAppBarWithTitle(context, MyLocalizations.of(context).login),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  buildLoginLogo(),
                  buildEmailTextField(),
                  SizedBox(height: 15),
                  buildPasswordTextField(),
                  buildForgotPasswordButton(),
                  SizedBox(height: 35),
                  buildLoginButton(),
                  SizedBox(height: 25),
                  buildSignUpButton(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget buildLoginLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'lib/assets/icons/auth.png',
          width: 277.0,
          height: 195,
        ),
        Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              MyLocalizations.of(context).loginToYourAccount,
              style: textMuliSemiboldd(),
            )),
      ],
    );
  }

  Widget buildEmailTextField() {
    return TextFormField(
      initialValue: 'user@ionicfirebaseapp.com',
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return MyLocalizations.of(context).pleaseEnterValidEmailOrPhoneNumber;
        }
        return null;
      },
      onChanged: (String value) {
        mobileNumber = value;
      },
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).yourEmailOrMobileNumber,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget buildPasswordTextField() {
    return TextFormField(
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
      obscureText: true,
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).yourPassword,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget buildForgotPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GFButton(
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
            type: GFButtonType.transparent,
            child: Text(
              '${MyLocalizations.of(context).forgotPassword} ?',
              style: textMuliRegular(),
            )),
      ],
    );
  }

  Widget buildLoginButton() {
    return buildPrimaryHalfWidthButton(
        context, MyLocalizations.of(context).login, isLoading, login);
  }

  Widget buildSignUpButton() {
    return InkWell(
      onTap: () {
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
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                text: MyLocalizations.of(context).dontHaveAccountYet,
                style: textMuliRegular()),
            TextSpan(
              text: ' ${MyLocalizations.of(context).signUpNow}',
              style: textMuliSemiboldprimary(),
            ),
          ],
        ),
      ),
    );
  }
}
