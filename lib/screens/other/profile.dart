import 'package:RestaurantSaas/styles/styles.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import '../../services/sentry-services.dart';
import 'package:RestaurantSaas/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;


SentryError sentryError = new SentryError();

class ProfileApp extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  String locale;
  ProfileApp({Key key, this.locale, this.localizedValues}) : super(key: key);
  @override
  _ProfileAppState createState() => _ProfileAppState();
}

class _ProfileAppState extends State<ProfileApp> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      locale: Locale(widget.locale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        MyLocalizationsDelegate(widget.localizedValues),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: languages.map((language) => Locale(language, '')),
      home: Profile(locale: widget.locale, localizedValues: widget.localizedValues),
    );
  }
}


class Profile extends StatefulWidget {

  final Map<String, Map<String, String>> localizedValues;
  String locale;
  Profile({Key key, this.locale, this.localizedValues}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  File file;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> profileData;
  bool isLoading = false;
  Image selectedImage;
  String base64Image;
  bool isPicUploading = false, isImageUploading = false;

  Future<Map<String, dynamic>> getProfileInfo() async {
    return await ProfileService.getUserInfo();
  }

  Map<String, Map<String, String>> localizedValues;

  @override
  void initState() {
    super.initState();
    getData();
  }

  var selectedLanguage, selectedLocale;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage');
    });
    if(selectedLanguage == 'en'){
      selectedLocale = 'English';
    }else if(selectedLanguage == 'fr'){
      selectedLocale = 'French';
    }else if(selectedLanguage == 'zh'){
      selectedLocale = 'Chinese';
    }else if(selectedLanguage == 'ka'){
      selectedLocale = 'Kannada';
    }
    print('selectedLanguage profile............$selectedLanguage ${widget.localizedValues}');
  }




  void _saveProfileInfo() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState.save();
      print("save button $profileData");
      var body = {
        "name": profileData['name'],
        "contactNumber": profileData['contactNumber'],
        "country": profileData['country'],
        "locationName": profileData['locationName'],
        "zip": profileData['zip'],
        "state": profileData['state'],
        "address": profileData['address'],
      };
      ProfileService.setUserInfo(profileData['_id'], body).then((onValue) {
        try{
          print(onValue);
          Toast.show("Your profile Successfully UPDATED", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pop();
        }
        catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
      });
    }
  }

  File _imageFile;

  void selectGallary() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    // base64Image = base64Encode(file.readAsBytesSync());
    setState(()  {
      _imageFile = file;
      setState(() {
        isPicUploading = true;
      });
      if (_imageFile != null) {
        var stream =
            new http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
        Map<String, dynamic> body = {"baseKey": base64Image};
        Map<String, dynamic> imageData;
        ProfileService.uploadProfileImage(
          _imageFile,
          stream,
          profileData['_id'],
        );
        setState(() {
          isPicUploading = false;
        });
        Toast.show("Your profile Picture Successfully UPDATED", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    });
  }

  void selectCamera() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    // base64Image = base64Encode(file.readAsBytesSync());
    setState(() async {
      _imageFile = file;
      setState(() {
        isPicUploading = true;
      });
      if (_imageFile != null) {
        var stream =
            new http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
        Map<String, dynamic> body = {"baseKey": base64Image};
        Map<String, dynamic> imageData;
        await ProfileService.uploadProfileImage(
          _imageFile,
          stream,
          profileData['_id'],
        );

        setState(() {
          isPicUploading = false;
        });
        Toast.show("Your profile Picture Successfully UPDATED", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    });
  }

  void removeProfilePic() async {
    setState(() {
      isImageUploading = true;
    });
    await ProfileService.deleteUserProfilePic().then((onValue) {
      // print(onValue['statusCode']);
      // print(onValue['message']);
      // if (onValue['statusCode'] == 200) {
      try{
        Toast.show(onValue['message'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        profileData['logo'] = null;
        _imageFile = null;
        setState(() {
          isImageUploading = false;
        });
      }
      // }
      catch (error, stackTrace) {
      sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  String selectedLanguages, selectedLang;

  List<String> languages = ['english', 'french', 'chinese', 'kannada'];



  @override
  Widget build(BuildContext context) {

    AsyncLoader _asyncLoader = AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getProfileInfo(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: 'Please check your internet connection!',
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          profileData = data;
          return ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: InkWell(
                          // onTap: _onWillPop,
                          onTap: () {
                            containerForSheet<String>(
                              context: context,
                              child: CupertinoActionSheet(
                                title: const Text('Change profile picture'),
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                    child: const Text('Choose from photos'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      selectGallary();
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: const Text('Take photo'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      selectCamera();
                                    },
                                  ),
                                  profileData['logo'] != null
                                      ? CupertinoActionSheetAction(
                                          child: const Text('Remove photo'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            removeProfilePic();
                                          },
                                        )
                                      : Container(),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  child: const Text('Cancel'),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },

                          child: Container(
                            height: 120.0,
                            width: 120.0,
                            decoration: new BoxDecoration(
                              border: new Border.all(
                                  color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                            child: _imageFile == null
                                ? profileData['logo'] != null
                                    ? new CircleAvatar(
                                        backgroundImage: new NetworkImage(
                                            "${profileData['logo']}"),
                                      )
                                    : new CircleAvatar(
                                        backgroundImage: new AssetImage(
                                            'lib/assets/imgs/na.jpg'))
                                : isPicUploading
                                    ? CircularProgressIndicator()
                                    : new CircleAvatar(
                                        backgroundImage:
                                            new FileImage(_imageFile),
                                        radius: 80.0,
                                      ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   right: 2.0,
                      //   bottom: 40.0,
                      //   child: Container(
                      //     height: 40.0,
                      //     width: 40.0,
                      //     child: new FloatingActionButton(
                      //       foregroundColor: Colors.black,
                      //       backgroundColor: Colors.white,
                      //       onPressed: () => _onWillPop(),
                      //       tooltip: 'Photo',
                      //       child: new Icon(Icons.edit),
                      //     ),
                      //   ),
                      // ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: ListTile(
                            title: Text(MyLocalizations.of(context).selectLanguages),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                hint: Text(selectedLocale == null  ? 'english' : selectedLocale),
                                value: selectedLanguages,
                                onChanged: (newValue) async {
                                  if(newValue == 'english'){
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString('selectedLanguage', 'en');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => EntryPage(widget.locale, widget.localizedValues),
                                      ),
                                    );
                                  }else if(newValue == 'chinese'){
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString('selectedLanguage', 'zh');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => EntryPage(widget.locale, widget.localizedValues),
                                      ),
                                    );
                                  }
                                  else if(newValue == 'kannada'){
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setString('selectedLanguage', 'ka');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => EntryPage(widget.locale, widget.localizedValues),
                                    ),
                                  );
                                }else {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString('selectedLanguage', 'fr');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => EntryPage(widget.locale, widget.localizedValues),
                                      ),
                                    );
                                  }
                                },
                                items: languages.map((lang) {
                                  return DropdownMenuItem(
                                    child: new Text(lang),
                                    value: lang,
                                  );
                                }).toList(),
                              ),
                            ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['name'] = value;
                          },
                          initialValue: data['name'],
                          decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context).fullName,
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          maxLength: 10,
                          onSaved: (value) {
                            data['contactNumber'] = value;
                          },
                          initialValue: data['contactNumber'].toString(),
                          decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context).mobileNumber,
                            hintStyle: textOS(),
                            counterText: "",
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['locationName'] = value;
                          },
                          initialValue: data['locationName'],
                          decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context).subUrban,
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['state'] = value;
                          },
                          initialValue: data['state'],
                          decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context).state,
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['country'] = value;
                          },
                          initialValue: data['country'],
                          decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context).country,
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          maxLength: 6,
                          onSaved: (value) {
                            data['zip'] = value;
                          },
                          initialValue:
                              data['zip'] != null ? data['zip'].toString() : '',
                          decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context).postalCode,
                            hintStyle: textOS(),
                            counterText: "",
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: new Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: new TextFormField(
                              onSaved: (value) {
                                data['address'] = value;
                              },
                              initialValue: data['address'],
                              decoration: new InputDecoration(
                                  labelText: MyLocalizations.of(context).address,
                                  hintStyle: textOS(),
                                  fillColor: Colors.black,
                                  border: InputBorder.none),
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: PRIMARY,
          title: Text(MyLocalizations.of(context).profile),
          leading: BackButton(),
        ),
        body: _asyncLoader,
        bottomNavigationBar: _buildBottomBar(),

    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: new Row(
        children: <Widget>[
          Expanded(
            child: new Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              height: 40.0,
              child: FlatButton(
                child: Text(
                  MyLocalizations.of(context).cancel,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          new Padding(padding: EdgeInsets.all(5.0)),
          Expanded(
            child: new Container(
              height: 40.0,
              color: PRIMARY,
              child: isLoading
                  ? Image.asset(
                      'lib/assets/icon/spinner.gif',
                      width: 19.0,
                      height: 19.0,
                    )
                  : FlatButton(
                      child: Text(
                        MyLocalizations.of(context).save,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _saveProfileInfo();
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }
}
