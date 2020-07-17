import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../services/localizations.dart';

SentryError sentryError = new SentryError();

class Rating extends StatefulWidget {
  final String productId, orderId, locationId, restaurantId;
  final Map localizedValues;
  final String locale;
  Rating(
      {Key key,
      this.productId,
      this.orderId,
      this.locationId,
      this.restaurantId,
      this.locale,
      this.localizedValues})
      : super(key: key);

  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _rating = 0;
  String comment;
  bool isLoading = false;

  void _rateProduct() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String, dynamic> body = {
        'comment': comment,
        'location': widget.locationId,
        'order': widget.orderId,
        'product': widget.productId,
        'rating': _rating,
        'restaurantID': widget.restaurantId
      };
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      await ProfileService.postProductRating(body).then((onValue) {
        try {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
        } catch (error, stackTrace) {
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
      });
    }
  }

  void rate(int rating) {
    if (mounted) {
      setState(() {
        _rating = rating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(
          MyLocalizations.of(context).getLocalizations("RATE_YOUR_ORDER"),
        ),
        backgroundColor: PRIMARY,
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: 0.0,
            child: new Image(
              image: new AssetImage("lib/assets/imgs/chicken.png"),
              width: screenWidth(context),
              height: screenHeight(context),
              fit: BoxFit.cover,
              color: const Color.fromRGBO(0, 0, 0, 0.78),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          new SingleChildScrollView(
            child: new Form(
              child: new Theme(
                data: new ThemeData(
                  brightness: Brightness.dark,
                  accentColor: PRIMARY,
                  inputDecorationTheme: new InputDecorationTheme(
                    labelStyle: textOSL(),
                  ),
                ),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: new EdgeInsets.only(top: 40.0, bottom: 20.0),
                      height: 100.0,
                      width: 180.0,
                      child: new Icon(
                        Icons.face,
                        size: 100.0,
                      ),
                    ),
                    new Text(
                      MyLocalizations.of(context).getLocalizations("WERE_GLAD"),
                      style: hintStyleLightOSL(),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: new EdgeInsets.only(top: 15.0, bottom: 20.0),
                      child: new Text(
                        MyLocalizations.of(context).getLocalizations("RATE_IT"),
                        style: hintStyleLightOSL(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(bottom: 20.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new GestureDetector(
                            child: new Icon(Icons.star,
                                color: _rating >= 1 ? PRIMARY : greyTextd),
                            onTap: () => rate(1),
                          ),
                          new GestureDetector(
                            child: new Icon(Icons.star,
                                color: _rating >= 2 ? PRIMARY : greyTextd),
                            onTap: () => rate(2),
                          ),
                          new GestureDetector(
                            child: new Icon(Icons.star,
                                color: _rating >= 3 ? PRIMARY : greyTextd),
                            onTap: () => rate(3),
                          ),
                          new GestureDetector(
                            child: new Icon(Icons.star,
                                color: _rating >= 4 ? PRIMARY : greyTextd),
                            onTap: () => rate(4),
                          ),
                          new GestureDetector(
                            child: new Icon(Icons.star,
                                color: _rating >= 5 ? PRIMARY : greyTextd),
                            onTap: () => rate(5),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: new Container(
                        margin: new EdgeInsets.only(
                            top: 10.0, bottom: 30.0, left: 40.0, right: 40.0),
                        padding: new EdgeInsets.only(
                            bottom: 15.0, left: 20.0, right: 20.0),
                        decoration: new BoxDecoration(
                          border: new Border.all(
                              color: Colors.white70, style: BorderStyle.solid),
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(5.0),
                            topRight: const Radius.circular(5.0),
                            bottomRight: const Radius.circular(5.0),
                            bottomLeft: const Radius.circular(5.0),
                          ),
                        ),
                        child: new TextFormField(
                          decoration: new InputDecoration(
                            hintStyle: hintStyleLightOSL(),
                            hintText: MyLocalizations.of(context)
                                .getLocalizations("FEEDBACK_IMP"),
                          ),
                          style: hintStyleSmallWhiteBoldOSL(),
                          maxLines: 5,
                          validator: (String value) {
                            if (value.isEmpty || value.length < 1) {
                              return '';
                            } else
                              return null;
                          },
                          onSaved: (String value) {
                            comment = value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 20.0,
                        end: 20.0,
                      ),
                      child: isLoading
                          ? RawMaterialButton(
                              fillColor: PRIMARY,
                              constraints:
                                  const BoxConstraints(minHeight: 45.0),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                              ),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'lib/assets/icon/spinner.gif',
                                    width: 30.0,
                                    height: 30.0,
                                  ),
                                ],
                              ),
                              onPressed: () {},
                              splashColor: secondary,
                            )
                          : RawMaterialButton(
                              fillColor: PRIMARY,
                              constraints:
                                  const BoxConstraints(minHeight: 45.0),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                              ),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'lib/assets/icon/spoon.png',
                                    width: 20.0,
                                    height: 20.0,
                                  ),
                                  Text(
                                    MyLocalizations.of(context)
                                        .getLocalizations("SUBMIT"),
                                    style: hintStyleGreyLightOSL(),
                                  ),
                                ],
                              ),
                              onPressed: _rateProduct,
                              splashColor: secondary,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
