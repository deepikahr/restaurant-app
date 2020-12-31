import 'dart:io';

import 'package:RestaurantSaas/main.dart';
import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:RestaurantSaas/services/initialize_i18n.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:async/async.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../services/localizations.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';

SentryError sentryError = new SentryError();

class ProfileApp extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  ProfileApp({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  _ProfileAppState createState() => _ProfileAppState();
}

class _ProfileAppState extends State<ProfileApp> {
  @override
  Widget build(BuildContext context) {
    return new Profile(
        locale: widget.locale, localizedValues: widget.localizedValues);
  }
}

class Profile extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  Profile({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  File file;
  File _imageFile;

  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> profileData;
  bool isLoading = false, isPicUploading = false, isImageUploading = false;
  var selectedLanguage, selectedLocale;
  Map<String, Map<String, String>> localizedValues;

  String selectedLanguages;

  List<String> languages = ['English', 'Spanish'];

  bool isFirstTime = true;

  Future<Map<String, dynamic>> getProfileInfo() async {
    return await ProfileService.getUserInfo();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selectedLanguage = prefs.getString('selectedLanguage');
      });
      if (selectedLanguage == 'en') {
        selectedLocale = 'English';
      } else if (selectedLanguage == 'es') {
        selectedLocale = 'Spanish';
      }
    }
  }

  void _saveProfileInfo() {
    if (_formKey.currentState.validate()) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      _formKey.currentState.save();

      var body = {
        "name": profileData['name'],
        "contactNumber": profileData['contactNumber'],
        "locationName": "",
        "zip": "",
        "state": "",
        "address": "",
        "country": profileData['country'],
      };
      ProfileService.setUserInfo(profileData['_id'], body).then((onValue) {
        try {
          Toast.show(MyLocalizations.of(context).yourProfileSuccessfullyUpdated,
              context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
      });
    } else {
      return;
    }
  }

  void selectGallary() async {
    // ignore: deprecated_member_use
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        _imageFile = file;
        if (mounted) {
          setState(() {
            isPicUploading = true;
          });
        }
        if (_imageFile != null) {
          var stream = new http.ByteStream(
              // ignore: deprecated_member_use
              DelegatingStream.typed(_imageFile.openRead()));
          ProfileService.uploadProfileImage(
            _imageFile,
            stream,
            profileData['_id'],
          );
          if (mounted) {
            setState(() {
              profileData['logo'] = file;
              isPicUploading = false;
            });
          }
          Toast.show(
              MyLocalizations.of(context).yourProfilePictureSuccessfullyUpdated,
              context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM);
        }
      });
    }
  }

  void selectCamera() async {
    // ignore: deprecated_member_use
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    if (mounted) {
      setState(() {
        _imageFile = file;
        if (mounted) {
          setState(() {
            isPicUploading = true;
          });
        }
        if (_imageFile != null) {
          var stream = new http.ByteStream(
              // ignore: deprecated_member_use
              DelegatingStream.typed(_imageFile.openRead()));
          ProfileService.uploadProfileImage(
            _imageFile,
            stream,
            profileData['_id'],
          );

          if (mounted) {
            setState(() {
              isPicUploading = false;
            });
          }
          Toast.show(
              MyLocalizations.of(context).yourProfilePictureSuccessfullyUpdated,
              context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM);
        }
      });
    }
  }

  void removeProfilePic() async {
    if (mounted) {
      setState(() {
        isImageUploading = true;
      });
    }
    await ProfileService.deleteUserProfilePic().then((onValue) {
      try {
        Toast.show(onValue['response_data']['message'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

        if (mounted) {
          setState(() {
            profileData['logo'] = null;
            _imageFile = null;
            isImageUploading = false;
          });
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  alertBox() {
    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(MyLocalizations.of(context).alert),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            selectGallary();
                          },
                          child: new Text(
                              MyLocalizations.of(context).choosefromphotos),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            selectCamera();
                          },
                          child:
                              new Text(MyLocalizations.of(context).takephoto),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: profileData['logo'] != null
                            ? InkWell(
                                onTap: () {
                                  removeProfilePic();
                                  Navigator.pop(context);
                                },
                                child: new Text(
                                    MyLocalizations.of(context).removephoto),
                              )
                            : Container(),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(MyLocalizations.of(context).cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    AsyncLoader _asyncLoader = AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getProfileInfo(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message:
                  MyLocalizations.of(context).pleaseCheckInternetConnection,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          print('profiel ${data['logo']}');
          profileData = data;
          return ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 35),
                    Stack(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: 120.0,
                          width: 120.0,
                          decoration: new BoxDecoration(
                            border: new Border.all(
                                color: secondary.withOpacity(0.5), width: 1.0),
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
                      Positioned(
                        right: 2.0,
                        bottom: 10.0,
                        child: Container(
                          height: 30.0,
                          width: 30.0,
                          child: new FloatingActionButton(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            onPressed: alertBox,
                            child: new Icon(
                              Icons.edit,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(height: 20),
                    Text(
                      data['name'].toString(),
                      style: textMuliSemiboldsec(),
                    ),
                    SizedBox(height: 5),
                    Text(
                      data['email'].toString(),
                      style: textMuliRegular(),
                    ),
                    SizedBox(height: 5),
                    Text(
                      data['contactNumber'].toString(),
                      style: textMuliRegular(),
                    ),
                    SizedBox(height: 25),
                    Container(
                      color: bg,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(MyLocalizations.of(context).selectLanguages,
                                style: textMuliSemiboldsec()),
                            DropdownButtonHideUnderline(
                              child: DropdownButton(
                                hint: Text(selectedLocale == null
                                    ? 'English'
                                    : selectedLocale),
                                value: selectedLanguages,
                                onChanged: (newValue) async {
                                  await initializeI18n().then((value) async {
                                    localizedValues = value;
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (newValue == 'English') {
                                      prefs.setString('selectedLanguage', 'en');
                                    } else {
                                      prefs.setString('selectedLanguage', 'es');
                                    }
                                    main();
                                    Navigator.pop(context);
                                  });
                                },
                                items: languages.map((lang) {
                                  return DropdownMenuItem(
                                    child: new Text(lang),
                                    value: lang,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: bg,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 8),
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: TextFormField(
                          cursorColor: primary,
                          style: textMuliRegular(),
                          onSaved: (value) {
                            data['name'] = value;
                          },
                          initialValue: data['name'],
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'UserName',
                            labelStyle: textMuliSemiboldgrey(),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.5)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.5)),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: bg,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 8),
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: TextFormField(
                          cursorColor: primary,
                          style: textMuliRegular(),
                          onSaved: (value) {
                            data['contactNumber'] = value;
                          },
                          validator: (String value) {
                            if (value.isEmpty || value.length < 9) {
                              return MyLocalizations.of(context)
                                  .pleaseEnterValidMobileNumber;
                            } else
                              return null;
                          },
                          initialValue: data['contactNumber'].toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: textMuliSemiboldgrey(),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.5)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.5)),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: bg,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 8),
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: TextFormField(
                          cursorColor: primary,
                          style: textMuliRegular(),
                          onSaved: (value) {
                            data['country'] = value;
                          },
                          initialValue: data['country'],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Country',
                            labelStyle: textMuliSemiboldgrey(),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.5)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.5)),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: secondary.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            ],
          );
        });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWithTitle(context, MyLocalizations.of(context).profile),
      body: _asyncLoader,
      bottomNavigationBar: Container(
        height: 41,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
            ]),
        child: RaisedButton(
            color: primary,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            onPressed: _saveProfileInfo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  MyLocalizations.of(context).save,
                  style: textMuliSemiboldwhite(),
                ),
                isLoading
                    ? Image.asset(
                        'lib/assets/icon/spinner.gif',
                        width: 19.0,
                        height: 19.0,
                      )
                    : Container()
              ],
            )),
      ),
    );
  }
}
