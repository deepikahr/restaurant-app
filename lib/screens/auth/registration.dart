import 'package:RestaurantSaas/services/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/styles.dart';
import '../../services/auth-service.dart';
import 'dart:async';
import '../../services/localizations.dart';
import 'package:flutter/foundation.dart';

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
  Map<String, dynamic> register = {
    'email': null,
    'password': null,
    'name': null,
    'role': 'User',
    'contactNumber': null
  };
  bool isLoading = false;
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
    selectedLanguages();
  }

  var selectedLanguage;

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
        _formKey.currentState.save();
        await AuthService.register(register).then((onValue) {
          if (onValue['message'] != null) {
            showSnackbar(onValue['message']);
            Future.delayed(const Duration(milliseconds: 3000), () {
              if (onValue['_id'] != null) {
                Navigator.pop(context);
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
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(MyLocalizations.of(context).register),
        centerTitle: true,
        backgroundColor: PRIMARY,
      ),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: AssetImage("lib/assets/bgImgs/background.png"),
              fit: BoxFit.fill,
              height: screenHeight(context),
              width: screenWidth(context),
            ),
            SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildNameField(),
                    _buildNumberField(),
                    _buildEmailField(),
                    _buildPasswordField(),
                    _buildTermsAndCondiField(),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
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
              onSaved: (String value) {
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
                if (value.isEmpty || value.length < 9) {
                  return MyLocalizations.of(context)
                      .pleaseEnterValidMobileNumber;
                } else
                  return null;
              },
              onSaved: (String value) {
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
            child: Icon(Icons.person, size: 16.0, color: greyTextc),
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
                if (value.isEmpty || !RegExp(EMAIL_PATTERN).hasMatch(value)) {
                  return MyLocalizations.of(context).pleaseEnterValidEmail;
                } else
                  return null;
              },
              onSaved: (String value) {
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
              onSaved: (String value) {
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
            child: new Text(
              MyLocalizations.of(context).acceptTerms,
              style: subTitleWhiteShadeLightOSR(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      // width: screenWidth(context),
      // top: screenHeight(context) * 0.78,
      child: RawMaterialButton(
        child: !isLoading
            ? Container(
                alignment: AlignmentDirectional.center,
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                height: 56.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                ),
                child: Text(
                  MyLocalizations.of(context).registerNow,
                  style: subTitleWhiteShadeLightOSR(),
                ),
              )
            : Container(
                alignment: AlignmentDirectional.center,
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
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

// import 'package:flutter/material.dart';
// import '../../styles/styles.dart';
// import '../../blocs/validators.dart';
// import '../../services/auth-service.dart';
// import '../../services/sentry-services.dart';
//
// import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
// import 'package:RestaurantSaas/constant.dart' show languages;
// import 'package:RestaurantSaas/localizations.dart'
//     show MyLocalizations, MyLocalizationsDelegate;
// import 'package:shared_preferences/shared_preferences.dart';

// SentryError sentryError = new SentryError();

// class RegisterForm extends StatefulWidget {
//   final String locale;
//   final Map<String, Map<String, String>> localizedValues;

//   RegisterForm({Key key, this.locale, this.localizedValues}) : super(key: key);
//   @override
//   _RegisterFormState createState() => _RegisterFormState();
// }

// class _RegisterFormState extends State<RegisterForm> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     selectedLanguages();
//   }

//   var selectedLanguage;

//   selectedLanguages() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//       if (mounted) {
// setState(() {
//       selectedLanguage = prefs.getString('selectedLanguage');
//     });
//
//   }

//   Map<String, dynamic> register = {
//     'email': null,
//     'password': null,
//     'name': null,
//     'role': 'User',
//     'contactNumber': null
//   };
//   bool isLoading = false;
//   bool isChecked = false;

//   _onRegister() async {
//     if (_formKey.currentState.validate()) {
//       if (isChecked) {
//           if (mounted) {
// setState(() {
//           isLoading = true;
//         });
//         _formKey.currentState.save();
//         await AuthService.register(register).then((onValue) {
//           try {
//             if (onValue['message'] != null) {
//               showSnackbar(onValue['message']);
//               Future.delayed(const Duration(milliseconds: 3000), () {
//                 if (onValue['_id'] != null) {
//                   Navigator.pop(context);
//                 }
//                   if (mounted) {
// setState(() {
//                   isLoading = false;
//                 });
//               });
//             }
//           } catch (error, stackTrace) {
//             sentryError.reportError(error, stackTrace);
//           }
//         }).catchError((onError) {
//           sentryError.reportError(onError, null);
//           showSnackbar(onError);
//             if (mounted) {
// setState(() {
//             isLoading = false;
//           });
//         });
//       } else {
//         showSnackbar('Please Accept terms and conditions');
//       }
//     }
//   }

//   showSnackbar(message) {
//     final snackBar = SnackBar(
//       content: Text(message),
//       duration: Duration(milliseconds: 3000),
//     );
//     _scaffoldKey.currentState.showSnackBar(snackBar);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       locale: Locale(widget.locale),
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: [
//         MyLocalizationsDelegate(widget.localizedValues),
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       supportedLocales: languages.map((language) => Locale(language, '')),
//       home: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           title: Text(MyLocalizations.of(context).register),
//           centerTitle: true,
//           backgroundColor: PRIMARY,
//         ),
//         body: SingleChildScrollView(
//           child: Stack(
//             children: <Widget>[
//               Image(
//                 image: AssetImage("lib/assets/bgImgs/background.png"),
//                 fit: BoxFit.fill,
//                 height: screenHeight(context),
//                 width: screenWidth(context),
//               ),
//               Form(
//                 key: _formKey,
//                 child: Container(
//                   padding: EdgeInsetsDirectional.only(start: 14.0, end: 14.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       Padding(padding: EdgeInsets.only(top: 60.0)),
//                       _buildNameField(),
//                       _buildNumberField(),
//                       _buildEmailField(),
//                       _buildPasswordField(),
//                       _buildTermsAndCondiField(),
//                     ],
//                   ),
//                 ),
//               ),
//               _buildRegisterButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNameField() {
//     return Container(
//       margin: EdgeInsets.only(top: 14.0),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 9,
//             child: TextFormField(
//               keyboardType: TextInputType.text,
//               validator: (String value) {
//                 if (value.isEmpty) {
//                   return MyLocalizations.of(context).pleaseEnterValidName;
//                 }
//               },
//               onSaved: (String value) {
//                 register['name'] = value;
//               },
//               decoration: new InputDecoration(
//                 labelText: MyLocalizations.of(context).fullName,
//                 hintStyle: hintStyleGreyLightOSR(),
//                 contentPadding: EdgeInsets.all(12.0),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 1,
//             child: Icon(Icons.person, size: 16.0, color: greyTextc),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNumberField() {
//     return Container(
//       margin: EdgeInsets.only(top: 14.0),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 9,
//             child: TextFormField(
//               keyboardType: TextInputType.number,
//               validator: (String value) {
//                 if (value.isEmpty || value.length < 9) {
//                   return MyLocalizations.of(context).pleaseEnterValidMobileNumber;
//                 }
//               },
//               onSaved: (String value) {
//                 register['contactNumber'] = value;
//               },
//               decoration: new InputDecoration(
//                 labelText:  MyLocalizations.of(context).mobileNumber,
//                 hintStyle: hintStyleGreyLightOSR(),
//                 contentPadding: EdgeInsets.all(12.0),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 1,
//             child: Icon(Icons.person, size: 16.0, color: greyTextc),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmailField() {
//     return Container(
//       margin: EdgeInsets.only(top: 14.0),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 9,
//             child: TextFormField(
//               decoration: new InputDecoration(
//                 labelText:  MyLocalizations.of(context).emailId,
//                 hintStyle: hintStyleGreyLightOSR(),
//                 contentPadding: EdgeInsets.all(12.0),
//                 border: InputBorder.none,
//               ),
//               keyboardType: TextInputType.emailAddress,
//               validator: (String value) {
//                 if (value.isEmpty ||
//                     !RegExp(Validators.emailPattern).hasMatch(value)) {
//                   return MyLocalizations.of(context).pleaseEnterValidEmail;
//                 }
//               },
//               onSaved: (String value) {
//                 register['email'] = value;
//               },
//             ),
//           ),
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 1,
//             child: Icon(Icons.email, size: 16.0, color: greyTextc),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPasswordField() {
//     return Container(
//       margin: EdgeInsets.only(top: 14.0),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 9,
//             child: TextFormField(
//               decoration: new InputDecoration(
//                 labelText: MyLocalizations.of(context).password,
//                 hintStyle: hintStyleGreyLightOSR(),
//                 contentPadding: EdgeInsets.all(12.0),
//                 border: InputBorder.none,
//               ),
//               keyboardType: TextInputType.text,
//               obscureText: true,
//               validator: (String value) {
//                 if (value.isEmpty || value.length < 6) {
//                   return MyLocalizations.of(context).pleaseEnterValidPassword;
//                 }
//               },
//               onSaved: (String value) {
//                 register['password'] = value;
//               },
//             ),
//           ),
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 1,
//             child: Icon(Icons.lock, size: 16.0, color: greyTextc),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTermsAndCondiField() {
//     return Padding(
//       padding: EdgeInsetsDirectional.only(top: 10.0, bottom: 30.0),
//       child: Row(
//         children: <Widget>[
//           new Checkbox(
//             value: isChecked,
//             onChanged: (bool value) {
//                 if (mounted) {
// setState(() {
//                 isChecked = value;
//               });
//             },
//             activeColor: PRIMARY,
//           ),
//           Flexible(
//             child: Container(
//               height: 50.0,
//               child: new Text(
//                 MyLocalizations.of(context).acceptTerms,
//                 style: subTitleWhiteShadeLightOSR(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRegisterButton() {
//     return Container(
//       // width: screenWidth(context),
//       // top: screenHeight(context) * 0.78,
//       child: RawMaterialButton(
//         child: !isLoading
//             ? Container(
//                 alignment: AlignmentDirectional.center,
//                 margin: EdgeInsets.only(left: 20.0, right: 20.0),
//                 height: 56.0,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white70),
//                 ),
//                 child: Text(
//                   MyLocalizations.of(context).registerNow,
//                   style: subTitleWhiteShadeLightOSR(),
//                 ),
//               )
//             : Container(
//                 alignment: AlignmentDirectional.center,
//                 margin: EdgeInsets.only(left: 20.0, right: 20.0),
//                 height: 56.0,
//                 decoration:
//                     BoxDecoration(border: Border.all(color: Colors.white70)),
//                 child: Image.asset(
//                   'lib/assets/icon/spinner.gif',
//                   width: 40.0,
//                   height: 40.0,
//                 ),
//               ),
//         onPressed: _onRegister,
//       ),
//     );
//   }
// }
