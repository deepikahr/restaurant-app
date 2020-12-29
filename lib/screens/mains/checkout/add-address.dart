import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:flutter/material.dart';

import '../../../services/localizations.dart';
import '../../../services/profile-service.dart';
import '../../../services/sentry-services.dart';
import '../../../styles/styles.dart';

SentryError sentryError = new SentryError();

class AddAddressPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  final Map<String, dynamic> loactionAddress;

  AddAddressPage(
      {Key key, this.locale, this.localizedValues, this.loactionAddress})
      : super(key: key);

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  List<String> addressType;
  int selectedRadio = 0, selectedRadioFirst;

  setSelectedRadio(int val) async {
    if (mounted) {
      setState(() {
        selectedRadioFirst = val;
      });
    }
  }

  Map<String, dynamic> address = {
    "location": {"lat": 0, "long": 0},
    "address": null,
    "landmark": null,
    "contactNumber": null,
    "addressType": null
  };

  _saveAddress() async {
    if (_formKey.currentState.validate()) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      address['address'] = widget.loactionAddress['address'];
      var location = {
        "lat": widget.loactionAddress['lat'],
        "long": widget.loactionAddress['long']
      };
      address['location'] = location;
      address['addressType'] = addressType[
          selectedRadioFirst == null ? selectedRadio : selectedRadioFirst];

      _formKey.currentState.save();
      ProfileService.addAddress(address).then((onValue) {
        try {
          if (mounted) {
            setState(() {
              isLoading = false;
              Navigator.of(context).pop(onValue);
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
    addressType = [
      MyLocalizations.of(context).home,
      MyLocalizations.of(context).work,
      MyLocalizations.of(context).others
    ];
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithTitle(context,  MyLocalizations.of(context).deliveryAddress,),
      body: Form(
        key: _formKey,
        child: Stack(
          children: <Widget>[
            Container(
              height: screenHeight(context),
              child: ListView(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
                    child: new Column(
                      children: <Widget>[
                        new Text(
                          MyLocalizations.of(context).whereToDeliver,
                          style: titleDarkOSS(),
                        ),
                        new Text(
                          MyLocalizations.of(context).byCreating,
                          style: textOSR(),
                        ),
                        new Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),
                        new Row(
                          children: <Widget>[
                            new Text(
                              MyLocalizations.of(context).address,
                              style: hintStyleSmallDarkBoldOSR(),
                            ),
                          ],
                        ),
                        new Row(
                          children: <Widget>[
                            Expanded(
                              child: new Container(
                                decoration: BoxDecoration(
                                  border: BorderDirectional(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: new Text(
                                  widget.loactionAddress['address'],
                                ),
                              ),
                            )
                          ],
                        ),
                        new Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),
                        new Row(
                          children: <Widget>[
                            new Text(
                              MyLocalizations.of(context).landmark,
                              style: hintStyleSmallDarkBoldOSR(),
                            ),
                          ],
                        ),
                        new Row(
                          children: <Widget>[
                            Expanded(
                              child: new Container(
                                decoration: BoxDecoration(
                                  border: BorderDirectional(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: new TextFormField(
                                  decoration: InputDecoration(
                                      hintText: MyLocalizations.of(context)
                                              .enterYour +
                                          "  " +
                                          MyLocalizations.of(context).landmark,
                                      hintStyle: hintStyleSmallLightOSR(),
                                      border: InputBorder.none),
                                  style: textOSR(),
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return MyLocalizations
                                                  .of(context)
                                              .please +
                                          " " +
                                          MyLocalizations.of(context)
                                              .enterYour +
                                          "  " +
                                          MyLocalizations.of(context).landmark;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (String value) {
                                    address['landmark'] = value;
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        new Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),
                        new Row(
                          children: <Widget>[
                            new Text(
                              MyLocalizations.of(context).mobileNumber,
                              style: hintStyleSmallDarkBoldOSR(),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: BorderDirectional(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: TextFormField(
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: MyLocalizations.of(context)
                                        .enterYour +
                                    "  " +
                                    MyLocalizations.of(context).mobileNumber,
                                counterText: "",
                                hintStyle: hintStyleSmallLightOSR(),
                                border: InputBorder.none),
                            style: textOSR(),
                            validator: (String value) {
                              if (value.isEmpty) {
                                return MyLocalizations.of(context).please +
                                    " " +
                                    MyLocalizations.of(context).enterYour +
                                    "  " +
                                    MyLocalizations.of(context).mobileNumber;
                              } else {
                                return null;
                              }
                            },
                            onSaved: (String value) {
                              address['contactNumber'] = value;
                            },
                          ),
                        ),
                        new Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),
                        new Row(
                          children: <Widget>[
                            new Text(
                              MyLocalizations.of(context).addressType,
                              style: hintStyleSmallDarkBoldOSR(),
                            ),
                          ],
                        ),
                        ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: addressType.length == null
                              ? 0
                              : addressType.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Radio(
                                  value: i,
                                  groupValue: selectedRadioFirst == null
                                      ? selectedRadio
                                      : selectedRadioFirst,
                                  activeColor: primary,
                                  onChanged: (value) {
                                    setSelectedRadio(value);
                                  },
                                ),
                                Text('${addressType[i]}'),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {
                        _saveAddress();
                      },
                      child: isLoading
                          ? Container(
                              alignment: AlignmentDirectional.center,
                              width: screenWidth(context),
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: primary,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.29), blurRadius: 5)
                                    ]),

                              child: Image.asset(
                                'lib/assets/icon/spinner.gif',
                                width: 19.0,
                                height: 19.0,
                              ),
                            )
                          : Container(
                              alignment: AlignmentDirectional.center,
                              width: screenWidth(context),
                              height: 44.0,
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.29), blurRadius: 5)
                            ]),
                              child: new Text(
                                MyLocalizations.of(context).addAddress,
                                style: subTitleWhiteBOldOSB(),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
