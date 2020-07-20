import 'package:flutter/material.dart';
import 'package:flutter_map_picker/flutter_map_picker.dart';

import '../../services/localizations.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';

SentryError sentryError = new SentryError();

class AddAddressPage extends StatefulWidget {
  final Map localizedValues;
  final String locale;
  final PlacePickerResult loactionAddress;

  AddAddressPage(
      {Key key, this.locale, this.localizedValues, this.loactionAddress})
      : super(key: key);

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController addressController = TextEditingController();
  bool isLoading = false;
  List<String> addressType = ["Home", "Work", "Others"];
  int selectedAddressType = 0;

  setSelectedRadio(int val) async {
    if (mounted) {
      setState(() {
        selectedAddressType = val;
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

      var location = {
        "lat": widget.loactionAddress.latLng.latitude,
        "long": widget.loactionAddress.latLng.longitude
      };
      address['location'] = location;
      address['addressType'] = addressType[selectedAddressType];
      address['address'] = addressController.text;

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
  void initState() {
    addressController.text = widget.loactionAddress.address;
    super.initState();
  }

  @override
  void dispose() {
    addressController.clear();
    super.dispose();
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
          MyLocalizations.of(context).getLocalizations("DELIIVER_ADDRESS"),
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
                          MyLocalizations.of(context)
                              .getLocalizations("WHERE_TO_DELIVER"),
                          style: titleDarkOSS(),
                        ),
                        new Text(
                          MyLocalizations.of(context)
                              .getLocalizations("BY_CREATING"),
                          style: textOSR(),
                        ),
                        new Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),
                        new Row(
                          children: <Widget>[
                            new Text(
                              MyLocalizations.of(context)
                                  .getLocalizations("ADDRESS"),
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
                                  controller: addressController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                      hintText: MyLocalizations.of(context)
                                          .getLocalizations("ADDRESS"),
                                      hintStyle: hintStyleSmallLightOSR(),
                                      border: InputBorder.none),
                                  style: textOSR(),
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return MyLocalizations.of(context)
                                          .getLocalizations("ADDRESS");
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (String value) {
                                    address['address'] = addressController.text;
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
                              MyLocalizations.of(context)
                                  .getLocalizations("LANDMARK"),
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
                                          .getLocalizations("ENTER_LANDMARK"),
                                      hintStyle: hintStyleSmallLightOSR(),
                                      border: InputBorder.none),
                                  style: textOSR(),
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return MyLocalizations.of(context)
                                          .getLocalizations("RIGISTER_NOW");
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
                              MyLocalizations.of(context)
                                  .getLocalizations("CONTACT_NUMBER"),
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
                                    .getLocalizations("CONTACT_NUMBER"),
                                counterText: "",
                                hintStyle: hintStyleSmallLightOSR(),
                                border: InputBorder.none),
                            style: textOSR(),
                            validator: (String value) {
                              if (value.isEmpty) {
                                return MyLocalizations.of(context)
                                    .getLocalizations("ENTER_CONTACT_NUMBER");
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
                              MyLocalizations.of(context)
                                  .getLocalizations("ADDRESS_TYPE"),
                              style: hintStyleSmallDarkBoldOSR(),
                            ),
                          ],
                        ),
                        ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: addressType.length,
                          itemBuilder: (BuildContext context, int i) {
                            String addressTypeData;
                            if (addressType[i] == "Home") {
                              addressTypeData = MyLocalizations.of(context)
                                  .getLocalizations("HOME");
                            } else if (addressType[i] == "Work") {
                              addressTypeData = MyLocalizations.of(context)
                                  .getLocalizations("WORK");
                            } else if (addressType[i] == "Others") {
                              addressTypeData = MyLocalizations.of(context)
                                  .getLocalizations("OTHERS");
                            } else {
                              addressTypeData = addressType[i];
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Radio(
                                  value: i,
                                  groupValue: selectedAddressType,
                                  activeColor: PRIMARY,
                                  onChanged: (value) {
                                    setSelectedRadio(value);
                                  },
                                ),
                                Text(addressTypeData),
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
                                MyLocalizations.of(context)
                                    .getLocalizations("SUBMIT"),
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
