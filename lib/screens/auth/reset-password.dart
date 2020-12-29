import 'package:RestaurantSaas/screens/auth/login.dart';
import 'package:RestaurantSaas/services/auth-service.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/services/sentry-services.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:RestaurantSaas/widgets/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

SentryError sentryError = new SentryError();

class ResetPassword extends StatefulWidget {
  final String token, locale;
  final Map localizedValues;

  ResetPassword({Key key, this.token, this.localizedValues, this.locale})
      : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String password1;
  String password2;
  bool success = false, passwordVisible = true, passwordVisible1 = true;

  bool isResetPasswordLoading = false;

  resetPassword() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (mounted) {
        setState(() {
          isResetPasswordLoading = true;
        });
      }
      Map<String, dynamic> body = {"newPass": password1};
      await AuthService.createNewPassword(body, widget.token).then((onValue) {
        try {
          if (mounted) {
            setState(() {
              isResetPasswordLoading = false;
            });
          }
          if (onValue['token'] != null) {
            showSnackbar(onValue['message']);
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage(
                        locale: widget.locale,
                        localizedValues: widget.localizedValues),
                  ),
                  (Route<dynamic> route) => route.isFirst);
            });
          } else if (onValue['response_code'] == 401) {
            showSnackbar('${onValue['response_data']}');
          } else {
            showSnackbar('${onValue['response_data']}');
          }
        } catch (error, stackTrace) {
          if (mounted) {
            setState(() {
              isResetPasswordLoading = false;
            });
          }
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            isResetPasswordLoading = false;
          });
        }
        sentryError.reportError(error, null);
      });
    } else {
      if (mounted) {
        setState(() {
          isResetPasswordLoading = false;
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      appBar: authAppBarWithTitle(
          context, MyLocalizations.of(context).resetPassword),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                SizedBox(height: 15),
                buildLoginLogo(),
                buildNewPasswordTextField(),
                SizedBox(height: 15),
                buildReEnterPasswordTextField(),
                SizedBox(height: 55),
                buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
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
              '${MyLocalizations.of(context).resetPassword}',
              textAlign: TextAlign.center,
              style: textMuliSemiboldd(),
            )),
      ],
    );
  }

  Widget buildNewPasswordTextField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return MyLocalizations.of(context).pleaseEnter;
        } else if (value.length < 6) {
          return MyLocalizations.of(context).pleaseEnterMin6DigitPassword;
        } else
          return null;
      },
      controller: _passwordTextController,
      onSaved: (String value) {
        password1 = value;
      },
      obscureText: passwordVisible1,
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).enterPassword,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
        suffixIcon: InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                passwordVisible1 = !passwordVisible1;
              });
            }
          },
          child: Icon(
            Icons.remove_red_eye,
            color: !passwordVisible1 ? primary : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildReEnterPasswordTextField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return MyLocalizations.of(context).enterPassword;
        } else if (value.length < 6) {
          return MyLocalizations.of(context).pleaseEnterMin6DigitPassword;
        } else if (_passwordTextController.text != value) {
          return MyLocalizations.of(context).passwordsdonotmatch;
        } else
          return null;
      },
      onSaved: (String value) {
        password2 = value;
      },
      obscureText: passwordVisible,
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).enternewpassword,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
        suffixIcon: InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            }
          },
          child: Icon(
            Icons.remove_red_eye,
            color: !passwordVisible ? primary : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildButton() {
    return buildPrimaryHalfWidthButton(
        context,
        MyLocalizations.of(context).resetPassword,
        isResetPasswordLoading,
        resetPassword);
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
