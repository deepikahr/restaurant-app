import 'dart:async';

import 'package:RestaurantSaas/screens/auth/otp-verify.dart';
import 'package:RestaurantSaas/services/constant.dart';
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
          print(onValue.toString());
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
      backgroundColor: Color(0XFF303030),
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          MyLocalizations.of(context).register,
          style: textbarlowSemiBoldWhite(),
        ),
        centerTitle: true,
        backgroundColor: PRIMARY,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                _buildNameField(),
                _buildCountryCode(),
                _buildNumberField(),
                _buildEmailField(),
                _buildPasswordField(),
                _buildTermsAndCondiField(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildRegisterButton(),
    );
  }

  Widget _buildNameField() {
    return Container(
      margin: EdgeInsets.only(top: 14.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 9,
            child: TextFormField(
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
              decoration: new InputDecoration(
                labelText: MyLocalizations.of(context).fullName,
                hintStyle: hintStyleGreyLightOSR(),
                contentPadding: EdgeInsets.all(12.0),
                border: InputBorder.none,
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Icon(Icons.person, size: 16.0, color: greyTextc),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCode() {
    return Container(
      margin: EdgeInsets.only(top: 14.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CountryListPick(
              initialSelection: '+91',
              onChanged: (CountryCode code) {
                register['countryCode'] = code.dialCode.substring(1).toString();
              }),
        ],
      ),
    );
  }

  Widget _buildNumberField() {
    return Container(
      margin: EdgeInsets.only(top: 14.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 9,
            child: TextFormField(
              maxLength: 10,
              keyboardType: TextInputType.number,
              validator: (String value) {
                if (value.isEmpty || value.length < 8) {
                  return MyLocalizations.of(context)
                      .pleaseEnterValidMobileNumber;
                } else
                  return null;
              },
              onChanged: (String value) {
                register['contactNumber'] = value;
              },
              decoration: new InputDecoration(
                counterText: "",
                labelText: MyLocalizations.of(context).mobileNumber,
                hintStyle: hintStyleGreyLightOSR(),
                contentPadding: EdgeInsets.all(12.0),
                border: InputBorder.none,
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Icon(Icons.phone, size: 16.0, color: greyTextc),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
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
                labelText: MyLocalizations.of(context).emailId,
                hintStyle: hintStyleGreyLightOSR(),
                contentPadding: EdgeInsets.all(12.0),
                border: InputBorder.none,
              ),
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
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Icon(Icons.email, size: 16.0, color: greyTextc),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
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
                labelText: MyLocalizations.of(context).password,
                hintStyle: hintStyleGreyLightOSR(),
                contentPadding: EdgeInsets.all(12.0),
                border: InputBorder.none,
              ),
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
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Icon(Icons.lock, size: 16.0, color: greyTextc),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndCondiField() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 10.0, bottom: 30.0),
      child: Row(
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
            activeColor: PRIMARY,
          ),
          Container(
            child: Expanded(
              child: new Text(
                MyLocalizations.of(context).acceptTerms,
                style: subTitleWhiteShadeLightOSR(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
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
                  MyLocalizations.of(context).registerNow,
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
        onPressed: _onRegister,
      ),
    );
  }
}
