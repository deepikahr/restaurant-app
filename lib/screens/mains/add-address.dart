import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> address = {
    'name': null,
    'contactNumber': null,
    'zip': null,
    'locationName': null,
    'city': null,
    'state': null,
    'country': null,
    'addressType': 'Home',
    'address': null,
    'isSelected': false
  };
  bool isLoading = false;

  _saveAddress() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState.save();
      ProfileService.addAddress(address).then((onValue) {
        setState(() {
          isLoading = false;
          Navigator.of(context).pop(address);
        });
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
        title: new Text(
          'Delivery Address',
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
                          'tell us where to deliver',
                          style: titleDarkOSS(),
                        ),
                        new Text(
                          'by creating a new adress',
                          style: textOSR(),
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'Name',
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
                                      bottom: BorderSide(color: Colors.grey))),
                              child: new TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Recipient name',
                                    hintStyle: hintStyleSmallLightOSR(),
                                    border: InputBorder.none),
                                style: textOSR(),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Please enter name';
                                  } else {
                                    address['name'] = value;
                                  }
                                },
                              ),
                            ))
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'Contact No',
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
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: 'Enter Contact no',
                                hintStyle: hintStyleSmallLightOSR(),
                                border: InputBorder.none),
                            style: textOSR(),
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please enter contact number';
                              } else {
                                address['contactNumber'] = value;
                              }
                            },
                          ),
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'Pin Code',
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
                                      bottom: BorderSide(color: Colors.grey))),
                              child: new TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Enter your pincode',
                                    hintStyle: hintStyleSmallLightOSR(),
                                    border: InputBorder.none),
                                style: textOSR(),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your pincode';
                                  } else {
                                    address['zip'] = value;
                                  }
                                },
                              ),
                            ))
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'Area',
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
                                      bottom: BorderSide(color: Colors.grey))),
                              child: new TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Enter your Street/area',
                                    hintStyle: hintStyleSmallLightOSR(),
                                    border: InputBorder.none),
                                style: textOSR(),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your area name';
                                  } else {
                                    address['locationName'] = value;
                                  }
                                },
                              ),
                            ))
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'City',
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
                                      bottom: BorderSide(color: Colors.grey))),
                              child: new TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Your city',
                                  hintStyle: hintStyleSmallLightOSR(),
                                  border: InputBorder.none,
                                ),
                                style: textOSR(),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your city name';
                                  } else {
                                    address['city'] = value;
                                  }
                                },
                              ),
                            ))
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'State',
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
                                      bottom: BorderSide(color: Colors.grey))),
                              child: new TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Your state name',
                                  hintStyle: hintStyleSmallLightOSR(),
                                  border: InputBorder.none,
                                ),
                                style: textOSR(),
                                validator: (String value) {
                                  address['state'] = value;
                                },
                              ),
                            ))
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'Country',
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
                                      bottom: BorderSide(color: Colors.grey))),
                              child: new TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Your country name',
                                  hintStyle: hintStyleSmallLightOSR(),
                                  border: InputBorder.none,
                                ),
                                style: textOSR(),
                                validator: (String value) {
                                  address['country'] = value;
                                },
                              ),
                            ))
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Row(
                          children: <Widget>[
                            new Text(
                              'Address',
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
                                      bottom: BorderSide(color: Colors.grey))),
                              child: new TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Enter Your address',
                                  hintStyle: hintStyleSmallLightOSR(),
                                  border: InputBorder.none,
                                ),
                                style: textOSR(),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Enter your address first';
                                  } else {
                                    address['address'] = value;
                                  }
                                },
                              ),
                            ))
                          ],
                        ),
                        Container(
                          color: bgColor,
                          height: 50.0,
                          child: Text(""),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              width: screenWidth(context),
              top: screenHeight(context) * 0.78,
              child: new Padding(
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
                              borderRadius: BorderRadius.circular(50.0)),
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
                              borderRadius: BorderRadius.circular(50.0)),
                          child: new Text("ADD ADDRESS",
                              style: subTitleWhiteBOldOSB()),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
