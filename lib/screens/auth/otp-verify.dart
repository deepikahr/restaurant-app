import 'package:RestaurantSaas/screens/auth/reset-password.dart';
import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth-service.dart';
import '../../services/localizations.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';

SentryError sentryError = new SentryError();

class OtpVerify extends StatefulWidget {
  final bool isComingRegister;
  final String countryCode;
  final String verificationId;
  final String locale;
  final String mobileNumber;
  final String userToken;
  final Map<String, Map<String, String>> localizedValues;

  OtpVerify(
      {Key key,
      this.countryCode,
      this.verificationId,
      this.locale,
      this.localizedValues,
      this.mobileNumber,
      this.userToken,
      this.isComingRegister})
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

      Map<String, dynamic> body = {
        "otp": otp,
        "verificationId": widget.verificationId,
        "contactNumber": widget.mobileNumber
      };

      AuthService.verifyOTP(body).then((onValue) {
        try {
          if (onValue['response_data']['message'] != null) {
            showSnackbar(onValue['response_data']['message']);
            if (onValue['response_code'] == 200) {
              if (widget.isComingRegister) {
                if (widget.userToken != null) {
                  Common.setToken(widget.userToken);
                }
                Future.delayed(Duration(milliseconds: 1500), () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => HomePage(
                            locale: widget.locale,
                            localizedValues: widget.localizedValues),
                      ),
                      (Route<dynamic> route) => route.isFirst);
                });
              } else {
                Future.delayed(Duration(milliseconds: 1500), () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ResetPassword(
                            token: widget.userToken,
                            locale: widget.locale,
                            localizedValues: widget.localizedValues),
                      ),
                      (Route<dynamic> route) => route.isFirst);
                });
              }
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
      content: Text(message.toString()),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    print(widget.userToken);
    print(widget.verificationId);
    print(widget.mobileNumber);
    super.initState();
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
          MyLocalizations.of(context).verifyOtp,
          style: textbarlowSemiBoldWhite(),
        ),
        centerTitle: true,
        backgroundColor: PRIMARY,
      ),
      body: Form(
        key: _formKey,
        child: _buildOTPField(),
      ),
      bottomNavigationBar: _buildVerifyOTPButton(),
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
            padding: EdgeInsetsDirectional.only(bottom: 30.0),
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
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                    ],
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
          InkWell(
            onTap: () {
              AuthService.resendOtp({"contactNumber": widget.mobileNumber})
                  .then((value) {
                print(value.toString());
                if (value['response_data']['message'] != null) {
                  showSnackbar(value['response_data']['message']);
                }
              }).catchError((error) {
                showSnackbar(error);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Resend OTP',
                    style: textbarlowSemiBoldwhite(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVerifyOTPButton() {
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
    );
  }
}
