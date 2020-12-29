import 'dart:async';

import 'package:RestaurantSaas/screens/auth/login.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:RestaurantSaas/widgets/button.dart';
import 'package:flutter/material.dart';

import '../../services/auth-service.dart';
import '../../services/localizations.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import 'otp-verify.dart';

SentryError sentryError = new SentryError();

class ForgotPassword extends StatefulWidget {
  final String title;
  final String locale;
  final Map<String, Map<String, String>> localizedValues;

  ForgotPassword({Key key, this.locale, this.localizedValues, this.title})
      : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void sendOTP() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      AuthService.forgetPassword({'email': email}).then((onValue) {
        try {
          if (onValue['response_data'] != null) {
            showSnackbar(onValue['response_data']['message']);
            if (onValue['response_data']['token'] != null) {
              Future.delayed(Duration(milliseconds: 1500), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => OtpVerify(
                      isComingRegister: false,
                      userToken: onValue['response_data']['token'],
                      mobileNumber: email,
                      verificationId: onValue['response_data']['data']
                          ['verificationId'],
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
        showSnackbar(onError);
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
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
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bg,
        appBar: authAppBarWithTitle(
            context,
            widget.title == MyLocalizations.of(context).verifyOtp
                ? MyLocalizations.of(context).verifyOtp
                : MyLocalizations.of(context).forgotPassword),
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
                  SizedBox(height: 35),
                  buildButton(),
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
        widget.title == MyLocalizations.of(context).verifyOtp
            ? Container()
            : Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  '${MyLocalizations.of(context).resetPasswordOtp}',
                  textAlign: TextAlign.center,
                  style: textMuliSemiboldd(),
                )),
        Container(
            margin: EdgeInsets.all(25),
            child: Text(
              '${MyLocalizations.of(context).resetMessage}',
              style: textMuliRegular(),
              textAlign: TextAlign.center,
            )),
      ],
    );
  }

  Widget buildEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return MyLocalizations.of(context).pleaseEnterValidEmailOrPhoneNumber;
        }
        return null;
      },
      onSaved: (value) {
        email = value;
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

  Widget buildButton() {
    return buildPrimaryHalfWidthButton(
        context,
        widget.title == MyLocalizations.of(context).verifyOtp
            ? MyLocalizations.of(context).proceed
            : MyLocalizations.of(context).resetPassword,
        isLoading,
        sendOTP);
  }

  Widget buildSignUpButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(
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
                text: MyLocalizations.of(context).loginToYourAccount,
                style: textMuliRegular()),
            TextSpan(
              text: ' ${MyLocalizations.of(context).signInNow}',
              style: textMuliSemiboldprimary(),
            ),
          ],
        ),
      ),
    );
  }
}
