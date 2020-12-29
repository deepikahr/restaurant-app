import 'package:RestaurantSaas/screens/auth/reset-password.dart';
import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:RestaurantSaas/widgets/button.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bg,
        appBar:
            authAppBarWithTitle(context, MyLocalizations.of(context).verifyOtp),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  buildLoginLogo(),
                  buildTextField(),
                  SizedBox(height: 55),
                  buildButton(),
                  SizedBox(height: 15),
                  buildResendOtpButton(),
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
            margin: EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              '${MyLocalizations.of(context).verifyOtp}',
              textAlign: TextAlign.center,
              style: textMuliSemiboldd(),
            )),
        Container(
            margin: EdgeInsets.all(25),
            child: Text(
              MyLocalizations.of(context).otpMessage,
              style: textMuliRegular(),
              textAlign: TextAlign.center,
            )),
      ],
    );
  }

  Widget buildTextField() {
    return TextFormField(
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
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).otp,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget buildButton() {
    return buildPrimaryHalfWidthButton(
        context, MyLocalizations.of(context).verifyOtp, isLoading, verifyOTP);
  }

  Widget buildResendOtpButton() {
    return InkWell(
      onTap: () {
        AuthService.resendOtp({"contactNumber": widget.mobileNumber})
            .then((value) {
          if (value['response_data']['message'] != null) {
            showSnackbar(value['response_data']['message']);
          }
        }).catchError((error) {
          showSnackbar(error);
        });
      },
      child:
          Text(MyLocalizations.of(context).resendOtp, style: textMuliRegular()),
    );
  }
}
