import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import '../../services/localizations.dart';

class AddCardPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  AddCardPage({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int expiryMonth, expiryYear, cardCvv;
  String cardHolderName, cardNumber;

  // add card data
  void addCardData() async {
    if (!isLoading && _formKey.currentState.validate()) {
      _formKey.currentState.save();
      var body = {
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cardCvv': cardCvv,
        'cardType': 'CARD',
      };
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      await ProfileService.addCard(body).then((onValue) {
        try {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          if (onValue['data'] != null &&
              onValue['data']['_id'] != null &&
              onValue['response_code'] == 200) {
            Navigator.pop(context, onValue['data']);
          } else {
            showDialog<Null>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: new Text(MyLocalizations.of(context).alert),
                    content: new SingleChildScrollView(
                      child: new ListBody(
                        children: <Widget>[
                          new Text('${onValue['message']}'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(MyLocalizations.of(context).ok),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          }
        } catch (error, stackTrace) {
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: new Text(
          MyLocalizations.of(context).addCard,
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(9.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: new Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 1.0),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 9,
                            child: TextFormField(
                              decoration: new InputDecoration(
                                hintText:
                                    MyLocalizations.of(context).nameonCard,
                                // hintStyle: greySmallTextHN(),
                                contentPadding: EdgeInsets.all(12.0),
                                border: InputBorder.none,
                              ),
                              // style: darkTextSmallHN(),
                              keyboardType: TextInputType.text,
                              validator: (String value) {
                                final RegExp nameExp =
                                    new RegExp(r'^[A-Za-z ]+$');
                                if (value.isEmpty || !nameExp.hasMatch(value)) {
                                  return MyLocalizations.of(context)
                                      .pleaseenteryourfullname;
                                } else
                                  return null;
                              },
                              onSaved: (String value) {
                                cardHolderName = value;
                              },
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 1,
                            child: Icon(
                              Icons.person,
                              color: Colors.black87,
                              size: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 14.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 1.0),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 9,
                            child: TextFormField(
                              decoration: new InputDecoration(
                                hintText: MyLocalizations.of(context)
                                    .creditCardNumber,
                                contentPadding: EdgeInsets.all(12.0),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 16,
                              validator: (String value) {
                                if (value.length != 16)
                                  return MyLocalizations.of(context)
                                      .cardNumbermustbeof16digit;
                                else
                                  return null;
                              },
                              onSaved: (String value) {
                                cardNumber = value;
                              },
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 1,
                            child: Icon(
                              Icons.credit_card,
                              color: Colors.black87,
                              size: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 14.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black87, width: 1.0),
                              color: Colors.white,
                            ),
                            child: TextFormField(
                              decoration: new InputDecoration(
                                hintText: MyLocalizations.of(context).mm,
                                contentPadding: EdgeInsets.all(12.0),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                              validator: (String value) {
                                int month = int.parse(value);
                                if ((value.length != 2) || (month > 12))
                                  return MyLocalizations.of(context)
                                      .invalidmonth;
                                else {
                                  return null;
                                }
                              },
                              onSaved: (String value) {
                                expiryMonth = int.parse(value);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 14.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black87, width: 1.0),
                              color: Colors.white,
                            ),
                            child: TextFormField(
                              decoration: new InputDecoration(
                                hintText: MyLocalizations.of(context).yyyy,
                                contentPadding: EdgeInsets.all(12.0),
                                border: InputBorder.none,
                              ),
                              // style: darkTextSmallHN(),
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              validator: (String value) {
                                int year = int.parse(value);
                                if ((DateTime.now().year > year) ||
                                    (year > 2050)) {
                                  return MyLocalizations.of(context)
                                      .invalidyear;
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (String value) {
                                expiryYear = int.parse(value);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 14.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 1.0),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 9,
                            child: TextFormField(
                              decoration: new InputDecoration(
                                hintText: MyLocalizations.of(context).cvv,
                                contentPadding: EdgeInsets.all(12.0),
                                border: InputBorder.none,
                              ),
                              maxLength: 3,
                              validator: (String value) {
                                if (value.length != 3)
                                  return MyLocalizations.of(context)
                                      .cardNumbermustbeof3digit;
                                else
                                  return null;
                              },
                              onSaved: (String value) {
                                cardCvv = int.parse(value);
                              },
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 1,
                            child: Icon(
                              Icons.credit_card,
                              color: Colors.black87,
                              size: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: addCardData,
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(color: PRIMARY),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                MyLocalizations.of(context).addCard,
                style: titleBoldWhiteOSS(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
              ),
              isLoading
                  ? Image.asset(
                      'lib/assets/icon/spinner.gif',
                      width: 19.0,
                      height: 19.0,
                    )
                  : Text('')
            ],
          ),
        ),
      ),
    );
  }
}
