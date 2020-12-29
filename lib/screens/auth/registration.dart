import 'dart:async';

import 'package:RestaurantSaas/screens/auth/login.dart';
import 'package:RestaurantSaas/screens/auth/otp-verify.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:RestaurantSaas/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_list_pick/country_list_pick.dart';

import '../../services/auth-service.dart';
import '../../services/localizations.dart';
import '../../styles/styles.dart';

class RegisterForm extends StatefulWidget {
  final String locale;
  final Map<String, Map<String, String>> localizedValues;

  RegisterForm({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false, isChecked = false;
  var selectedLanguage;
  Map<String, dynamic> register = {
    'email': null,
    'password': null,
    'countryCode': "91",
    'name': null,
    'role': 'User',
    'contactNumber': null
  };

  get theme => null;

  @override
  void initState() {
    super.initState();
    selectedLanguages();
  }

  selectedLanguages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selectedLanguage = prefs.getString('selectedLanguage');
      });
    }
  }

  _onRegister() async {
    if (_formKey.currentState.validate()) {
      if (isChecked) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        if (register['email'] == null) {
          register.remove("email");
        }
        _formKey.currentState.save();
        await AuthService.register(register).then((onValue) {
          if (onValue['message'] != null) {
            showSnackbar(onValue['message']);
            Future.delayed(const Duration(milliseconds: 3000), () {
              if (onValue['_id'] != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OtpVerify(
                              isComingRegister: true,
                              userToken: onValue['token'],
                              countryCode: register['countryCode'],
                              mobileNumber: register['contactNumber'],
                              verificationId: onValue['verificationId'],
                              localizedValues: widget.localizedValues,
                              locale: widget.locale,
                            )));
              }
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            });
          }
        }).catchError((onError) {
          showSnackbar(onError);
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        showSnackbar(
            MyLocalizations.of(context).pleaseAccepttermsandconditions);
      }
    }
  }

  showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message.toString()),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar:
            authAppBarWithTitle(context, MyLocalizations.of(context).register),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  buildLoginLogo(),
                  buildNameTextField(),
                  SizedBox(height: 15),
                  buildEmailTextField(),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _buildCountryCode(),
                      SizedBox(
                        width: 6,
                      ),
                      Expanded(child: buildMobileNumberTextField()),
                    ],
                  ),
                  SizedBox(height: 15),
                  buildPasswordTextField(),
                  SizedBox(height: 15),
                  _buildTermsAndConditionsField(),
                  SizedBox(height: 35),
                  buildRegisterButton(),
                  SizedBox(height: 15),
                  buildSignInButton(),
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
              MyLocalizations.of(context).signUpNow,
              style: textMuliSemiboldd(),
            )),
      ],
    );
  }

  Widget buildNameTextField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return MyLocalizations.of(context).pleaseEnterValidName;
        } else
          return null;
      },
      onChanged: (String value) {
        register['name'] = value;
      },
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).fullName,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget buildEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if ((value?.length ?? 0) > 0 &&
            !RegExp(EMAIL_PATTERN).hasMatch(value)) {
          return MyLocalizations.of(context).pleaseEnterValidEmail;
        } else
          return null;
      },
      onChanged: (String value) {
        register['email'] = value;
      },
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).emailId,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget buildMobileNumberTextField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty || value.length < 8) {
          return MyLocalizations.of(context).pleaseEnterValidMobileNumber;
        } else
          return null;
      },
      onChanged: (String value) {
        register['contactNumber'] = value;
      },
      style: textMuliRegular(),
      decoration: InputDecoration(
        labelText: MyLocalizations.of(context).mobileNumber,
        labelStyle: textMuliSemiboldgrey(),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: secondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget buildPasswordTextField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return MyLocalizations.of(context).pleaseEnterValidPassword;
        } else
          return null;
      },
      onChanged: (String value) {
        register['password'] = value;
      },
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

  Widget _buildCountryCode() {
    return Container(
      margin: EdgeInsets.only(top: 11.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: secondary.withOpacity(0.5)),
          )),
      child: CountryListPick(
          initialSelection: '+91',
          onChanged: (CountryCode code) {
            register['countryCode'] = code.dialCode.substring(1).toString();
          }),
    );
  }

  Widget _buildTermsAndConditionsField() {
    return Row(
      children: <Widget>[
        new Checkbox(
          value: isChecked,
          onChanged: (bool value) {
            if (mounted) {
              setState(() {
                isChecked = value;
              });
            }
          },
          activeColor: primary,
        ),
        Container(
          child: Expanded(
            child: new Text(MyLocalizations.of(context).acceptTerms,
                style: textMuliRegular()),
          ),
        ),
      ],
    );
  }

  Widget buildRegisterButton() {
    return buildPrimaryHalfWidthButton(
        context, MyLocalizations.of(context).register, isLoading, _onRegister);
  }

  Widget buildSignInButton() {
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
