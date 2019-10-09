import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import '../../widgets/no-data.dart';
import 'package:async_loader/async_loader.dart';
import '../../screens/mains/product-details.dart';

class Favorites extends StatefulWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextb,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        title: new Text('Favorites', style: titleBoldWhiteOSS()),
        centerTitle: true,
      ),
      body: AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getFavouriteList(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          if (data.length > 0) {
            return _buildFavTile(data);
          } else {
            return buildEmptyPage();
          }
        },
      ),
    );
  }

  static Widget buildEmptyPage() {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: NoData(message: 'Your Favourite list is empty!'),
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
                          Text('\$' +
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
                                      setState(() {
                                        isProcessing = true;
                                        selectedItemId = favs[index]['_id'];
                                      });
                                      ProfileService.removeFavouritById(
                                              favs[index]['_id'])
                                          .then((onValue) {
                                        Toast.show(
                                            "Product remove to Favourite list",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                        if (onValue) {
                                          setState(() {
                                            isProcessing = false;
                                            favs.removeAt(index);
                                          });
                                        }
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
