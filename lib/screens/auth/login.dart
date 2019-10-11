import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../blocs/validators.dart';
import '../../services/auth-service.dart';
import '../../services/common.dart';
import 'registration.dart';
import 'forgot-password.dart';

class LoginPage extends StatefulWidget {
  final isDrawe;
  LoginPage({Key key, this.isDrawe}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email, password;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  login() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState.save();
      Map<String, dynamic> body = {'email': email, 'password': password};
      AuthService.login(body).then((onValue) {
        if (onValue['message'] != null) {
          showSnackbar(onValue['message']);
        }
        if (onValue['token'] != null) {
          Common.setToken(onValue['token']).then((saved) {
            if (saved) {
              showSnackbar('Login Successful!');
              Future.delayed(Duration(milliseconds: 1500), () {
                if (widget.isDrawe == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => HomePage(),
                    ),
                  );
                } else {
                  Navigator.of(context).pop('Success');
                }
              });
            }
          });
        }
        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            buildLoginPageBg(),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildLoginPageLogo(),
                  buildLoginPageForm(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLoginPageBg() {
    return Positioned(
      top: 0.0,
      child: Image(
        image: AssetImage("lib/assets/bgImgs/background.png"),
        fit: BoxFit.cover,
        height: screenHeight(context),
        width: screenWidth(context),
      ),
    );
  }

  Widget buildLoginPageLogo() {
    return Padding(
      padding: EdgeInsets.only(top: 128.0, bottom: 45.0),
      child: Image(
        image: AssetImage("lib/assets/logos/logo.png"),
        fit: BoxFit.cover,
        width: 95.0,
      ),
    );
  }

  Widget buildLoginPageForm() {
    return Form(
      key: _formKey,
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              buildEmailTextField(),
              buildPasswordTextField(),
              buildLoginButton(),
              buildForgotPasswordButton(),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 74.0, bottom: 20.0),
                child: Text(
                  "Dont have account Yet?",
                  style: subTitleWhiteLightOSR(),
                ),
              ),
              buildSignupButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmailTextField() {
    return Container(
      color: Colors.white,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(Validators.emailPattern).hasMatch(value)) {
            return 'Please enter a valid email';
          }
        },
        onSaved: (String value) {
          email = value;
        },
        decoration: InputDecoration(
          labelText: "Your Email",
          labelStyle: hintStyleGreyLightOSR(),
          contentPadding: EdgeInsets.all(10),
          border: InputBorder.none,
        ),
        style: textBlackOSR(),
      ),
    );
  }

  Widget buildPasswordTextField() {
    return Container(
      margin: EdgeInsets.only(top: 4.0),
      color: Colors.white,
      child: TextFormField(
        keyboardType: TextInputType.text,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return 'Password should be atleast 6 char long';
          }
        },
        onSaved: (String value) {
          password = value;
        },
        decoration: InputDecoration(
          labelText: "Your Password",
          labelStyle: hintStyleGreyLightOSR(),
          contentPadding: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: 10.0,
            bottom: 10.0,
          ),
          border: InputBorder.none,
        ),
        style: textBlackOSR(),
        obscureText: true,
      ),
    );
  }

  Widget buildLoginButton() {
    return RawMaterialButton(
      onPressed: isLoading ? null : login,
      child: Container(
        alignment: AlignmentDirectional.center,
        margin: const EdgeInsetsDirectional.only(top: 10.0),
        height: 56.0,
        width: screenWidth(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              const Color(0xFFFFFFFF).withOpacity(0.25),
              const Color(0xFFFFFFFF).withOpacity(0.25)
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN TO YOUR ACCOUNT",
              style: subTitleWhiteLightOSR(),
            ),
            Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0)),
            isLoading
                ? Image.asset(
                    'lib/assets/icon/spinner.gif',
                    width: 19.0,
                    height: 19.0,
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }

  Widget buildForgotPasswordButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 0.0, bottom: 20.0),
      child: FlatButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ResetPassword(),
              ),
            );
          },
          child: Text(
            'Forgot Password?',
            style: hintStyleLightOSB(),
          )),
    );
  }

  Widget buildSignupButton() {
    return RawMaterialButton(
      child: Container(
        alignment: AlignmentDirectional.center,
        height: 56.0,
        width: screenWidth(context),
        decoration: BoxDecoration(border: Border.all(color: Colors.white70)),
        child: Text(
          " Sign-Up Now",
          style: subTitleWhiteShadeLightOSR(),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RegisterForm(),
          ),
        );
      },
    );
  }
}
