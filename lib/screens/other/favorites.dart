import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import '../../widgets/no-data.dart';
import 'package:async_loader/async_loader.dart';
import '../../screens/mains/product-details.dart';
import '../../services/sentry-services.dart';
import '../../services/localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();

class Favorites extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  Favorites({Key key, this.locale, this.localizedValues}) : super(key: key);
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();

  bool isProcessing = false;
  String selectedItemId;

  getFavouriteList() async {
    return await ProfileService.getFavouritList();
  }

  @override
  void initState() {
    super.initState();
    getGlobalSettingsData();
  }

  String currency = '';

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextb,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
        backgroundColor: PRIMARY,
        title: new Text(MyLocalizations.of(context).favourites,
            style: titleBoldWhiteOSS()),
        centerTitle: true,
      ),
      body: AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getFavouriteList(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          if (data.length > 0) {
            return _buildFavTile(data);
          } else {
            return buildEmptyPage(context);
          }
        },
      ),
    );
  }

  static Widget buildEmptyPage(context) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: NoData(message: MyLocalizations.of(context).favoritesListEmpty),
    );
  }

  Widget _buildFavTile(List<dynamic> favs) {
    return ListView.builder(
      itemCount: favs.length,
      physics: ScrollPhysics(),
      shrinkWrap: true,
      reverse: true,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ProductDetailsPage(
                    product: favs[index]['product'],
                    restaurantName: favs[index]['restaurantID']
                        ['restaurantName'],
                    restaurantId: favs[index]['restaurantID']['_id'],
                    locationInfo: favs[index]['location'],
                    taxInfo: favs[index]['restaurantID']['taxInfo']),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: bgColor,
                height: 70.0,
                margin: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: Image(
                        image: NetworkImage(favs[index]['product']['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              favs[index]['restaurantID']['restaurantName'],
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              favs[index]['product']['title'],
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              favs[index]['product']['description'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('$currency' +
                              favs[index]['product']['variants'][0]['price']
                                  .toStringAsFixed(2)),
                          Divider(),
                          (isProcessing && favs[index]['_id'] == selectedItemId)
                              ? Image.asset(
                                  'lib/assets/icon/spinner.gif',
                                  width: 33.0,
                                  height: 33.0,
                                )
                              : InkWell(
                                  onTap: () {
                                    if (!isProcessing) {
                                      if (mounted) {
                                        setState(() {
                                          isProcessing = true;
                                          selectedItemId = favs[index]['_id'];
                                        });
                                      }
                                      ProfileService.removeFavouritById(
                                              favs[index]['_id'])
                                          .then((onValue) {
                                        try {
                                          Toast.show(
                                              MyLocalizations.of(context)
                                                  .removedFavoriteItem,
                                              context,
                                              duration: Toast.LENGTH_LONG,
                                              gravity: Toast.BOTTOM);
                                          if (onValue) {
                                            if (mounted) {
                                              setState(() {
                                                isProcessing = false;
                                                favs.removeAt(index);
                                              });
                                            }
                                          }
                                        } catch (error, stackTrace) {
                                          sentryError.reportError(
                                              error, stackTrace);
                                        }
                                      }).catchError((onError) {
                                        sentryError.reportError(onError, null);
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.favorite,
                                    size: 35.0,
                                    color: PRIMARY,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
