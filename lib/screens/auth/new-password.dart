import 'package:RestaurantSaas/main.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/auth-service.dart';
import '../../services/sentry-services.dart';
import '../../services/localizations.dart';

SentryError sentryError = new SentryError();

class NewPassword extends StatefulWidget {
  final String otpToken;
  final String locale;
  final Map<String, Map<String, String>> localizedValues;
  NewPassword({Key key, this.otpToken, this.locale, this.localizedValues})
      : super(key: key);
  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  bool isLoading = false;
  String newPassword;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void createPassword() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      AuthService.createNewPassword({'newPass': newPassword}, widget.otpToken)
          .then((onValue) {
        print(onValue);
        try {
          if (onValue['token'] != null) {
            showSnackbar(onValue['message']);
            Future.delayed(const Duration(milliseconds: 3000), () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => EntryPage(
                      widget.locale,
                      widget.localizedValues,
                    ),
                  ),
                  (Route<dynamic> route) => route.isFirst);
            });
          } else {
            showSnackbar(onValue['message']);
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
        title: Text(MyLocalizations.of(context).createPassword),
        centerTitle: true,
        backgroundColor: PRIMARY,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Image(
                image: AssetImage("lib/assets/bgImgs/background.png"),
                fit: BoxFit.fill,
                height: screenHeight(context),
                width: screenWidth(context),
              ),
              Form(
                key: _formKey,
                child: _buildNewPasswordField(),
              ),
              _buildSubmitButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 14.0, end: 14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 100),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(top: 30.0, bottom: 30.0),
            child: Center(
              child: Text(
                MyLocalizations.of(context).createPassword + '!',
                textAlign: TextAlign.center,
                style: subTitleWhiteLightOSR(),
              ),
            ),
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
                      labelText: MyLocalizations.of(context).password,
                      hintStyle: hintStyleGreyLightOSR(),
                      contentPadding: EdgeInsets.all(12.0),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.text,
                    validator: (String value) {
                      if (value.isEmpty || value.length < 6) {
                        return MyLocalizations.of(context)
                            .pleaseEnterValidPassword;
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      newPassword = value;
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
              MyLocalizations.of(context).createPasswordMessage,
              textAlign: TextAlign.center,
              style: subTitleWhiteLightOSR(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      width: screenWidth(context),
      top: screenHeight(context) * 0.76,
      child: Container(
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
                    MyLocalizations.of(context).createPassword,
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
          onPressed: createPassword,
        ),
      ),
    );
  }
}
