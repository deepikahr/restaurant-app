import 'package:flutter/material.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../services/localizations.dart';

SentryError sentryError = new SentryError();

class AddAddressPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  final LocationResult loactionAddress;
  AddAddressPage(
      {Key key, this.locale, this.localizedValues, this.loactionAddress})
      : super(key: key);
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  List<String> addressType = ['Home', "Work", "Others"];
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
    "flatNo": null,
    "apartmentName": null,
    "landmark": null,
    "postalCode": null,
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
      address['address'] = widget.loactionAddress.address;
      var location = {
        "lat": widget.loactionAddress.latLng.latitude,
        "long": widget.loactionAddress.latLng.longitude
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
    return Scaffold(
      backgroundColor: bgColor,
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
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: new Text(
          MyLocalizations.of(context).deliveryAddress,
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
      ),
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
                                  widget.loactionAddress.address,
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
                              MyLocalizations.of(context).flatNumber,
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
                                          MyLocalizations.of(context)
                                              .flatNumber,
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
                                          MyLocalizations.of(context)
                                              .flatNumber;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (String value) {
                                    address['flatNo'] = value;
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
                              MyLocalizations.of(context).apartmentName,
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
                                          MyLocalizations.of(context)
                                              .apartmentName,
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
                                          MyLocalizations.of(context)
                                              .apartmentName;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (String value) {
                                    address['apartmentName'] = value;
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
                              MyLocalizations.of(context).postalCode,
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
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                      counterText: "",
                                      hintText: MyLocalizations.of(context)
                                              .enterYour +
                                          "  " +
                                          MyLocalizations.of(context)
                                              .postalCode,
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
                                          MyLocalizations.of(context)
                                              .postalCode;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (String value) {
                                    address['postalCode'] = value;
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
                                  activeColor: Colors.green,
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
                                color: PRIMARY,
                                borderRadius: BorderRadius.circular(50.0),
                              ),
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
                                color: PRIMARY,
                                borderRadius: BorderRadius.circular(50.0),
                              ),
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
