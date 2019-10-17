import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../blocs/validators.dart';
import '../../services/auth-service.dart';
import '../../services/sentry-services.dart';

SentryError sentryError = new SentryError();

class RegisterForm extends StatefulWidget {
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

  _onRegister() async {
    if (_formKey.currentState.validate()) {
      if (isChecked) {
        setState(() {
          isLoading = true;
        });
        _formKey.currentState.save();
        await AuthService.register(register).then((onValue) {
          try {
            if (onValue['message'] != null) {
              showSnackbar(onValue['message']);
              Future.delayed(const Duration(milliseconds: 3000), () {
                if (onValue['_id'] != null) {
                  Navigator.pop(context);
                }
                setState(() {
                  isLoading = false;
                });
              });
            }
          } catch (error, stackTrace) {
            sentryError.reportError(error, stackTrace);
          }
        }).catchError((onError) {
          sentryError.reportError(onError, null);
          showSnackbar(onError);
          setState(() {
            isLoading = false;
          });
        });
      } else {
        showSnackbar('Please Accept terms and conditions');
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
        title: Text("Register"),
        centerTitle: true,
        backgroundColor: PRIMARY,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Image(
              image: AssetImage("lib/assets/bgImgs/background.png"),
              fit: BoxFit.fill,
              height: screenHeight(context),
              width: screenWidth(context),
            ),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsetsDirectional.only(start: 14.0, end: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 60.0)),
                    _buildNameField(),
                    _buildNumberField(),
                    _buildEmailField(),
                    _buildPasswordField(),
                    _buildTermsAndCondiField(),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ),
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
                  return 'Please enter a valid name';
                }
              },
              onSaved: (String value) {
                register['name'] = value;
              },
              decoration: new InputDecoration(
                labelText: "Full Name",
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
              keyboardType: TextInputType.number,
              validator: (String value) {
                if (value.isEmpty || value.length < 9) {
                  return 'Please enter a valid contact number';
                }
              },
              onSaved: (String value) {
                register['contactNumber'] = value;
              },
              decoration: new InputDecoration(
                labelText: "Contact Number",
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
                labelText: "Email",
                hintStyle: hintStyleGreyLightOSR(),
                contentPadding: EdgeInsets.all(12.0),
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (String value) {
                if (value.isEmpty ||
                    !RegExp(Validators.emailPattern).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
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
                labelText: "Password",
                hintStyle: hintStyleGreyLightOSR(),
                contentPadding: EdgeInsets.all(12.0),
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.text,
              obscureText: true,
              validator: (String value) {
                if (value.isEmpty || value.length < 6) {
                  return 'Password should be atleast 6 char long';
                }
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
              setState(() {
                isChecked = value;
              });
            },
            activeColor: PRIMARY,
          ),
          new Text(
            "Accept T&C and Privacy Policy",
            style: subTitleWhiteShadeLightOSR(),
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
                  " Register Now",
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
