import 'dart:async';

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
                      verificationId: onValue['response_data']['data']['verificationId'],
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
      backgroundColor: Color(0XFF303030),
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
          widget.title,
          style: textbarlowSemiBoldWhite(),
        ),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 0.0,
      ),
      body: Form(
        key: _formKey,
        child: _buildEmailField(),
      ),
      bottomNavigationBar: _buildSubmitButton(),
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
            padding: EdgeInsetsDirectional.only(bottom: 30.0),
            child: widget.title == MyLocalizations.of(context).verifyOtp
                ? Container()
                : Center(
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
                      if (value.isEmpty) {
                        return MyLocalizations.of(context)
                            .pleaseEnterValidEmailOrPhoneNumber;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value;
                    },
                    decoration: new InputDecoration(
                      labelText:
                          MyLocalizations.of(context).yourEmailOrMobileNumber,
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
    return Container(
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
                  widget.title == MyLocalizations.of(context).verifyOtp
                      ? MyLocalizations.of(context).proceed
                      : MyLocalizations.of(context).resetPassword,
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
    );
  }
}
