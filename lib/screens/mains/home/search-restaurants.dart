import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:RestaurantSaas/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RestaurantSearch extends SearchDelegate<String> {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  VoidCallback showBottomSheetCallback;
  final List<dynamic> restaurantList;
  List<dynamic> searchedList = List();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RestaurantSearch({this.localizedValues, this.locale, this.restaurantList});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.black,
          ),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            color: Colors.black,
            icon: AnimatedIcons.menu_arrow,
            progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return (searchedList?.length ?? 0) > 0
        ? StatefulBuilder(builder: (context, setState) {
            return ListView.builder(
                itemCount: searchedList?.length ?? 0,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          HomePageState().goToProductListPage(
                              context,
                              searchedList[index],
                              true,
                              localizedValues,
                              locale);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              searchedList[index]['restaurantID']['logo'] != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  searchedList[index]['restaurantID']['logo'],
                                  width: 138,
                                  height: 108,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Image.asset(
                                'lib/assets/images/dominos.png',
                                width: 138,
                                height: 108,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SizedBox(height: 3),
                                  Text(
                                    searchedList[index]['restaurantID']
                                    ['restaurantName'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textMuliSemiboldsm(),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                  searchedList[index]['locationName'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: textMuliRegularxs(),
                                  ),
                                  // SizedBox(height: 3),
                                  // Text(
                                  //   '${searchedList[index]['locationCount']} ${MyLocalizations.of(context).branches}',
                                  //   overflow: TextOverflow.ellipsis,
                                  //   maxLines: 2,
                                  //   style: textMuliRegularxs(),
                                  // ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        padding: EdgeInsets.only(left: 12, right: 12),
                                        color: Color(0xFF39B24A),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            Text(
                                              ' ${searchedList[index]['restaurantID']['rating'].toString()}',
                                              style: textMuliSemiboldwhitexs(),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        '(${searchedList[index]['restaurantID']['reviewCount']} ${MyLocalizations.of(context).reviews})',
                                        style:hintStyleSmallTextOSL()
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        // HomePageState.buildCardBottom(
                        //     searchedList[index]['locationName'],
                        //     searchedList[index]['restaurantID']['logo'],
                        //     searchedList[index]['restaurantID']
                        //         ['restaurantName'],
                        //     double.parse(searchedList[index]['restaurantID']
                        //             ['rating']
                        //         .toString()),
                        //     searchedList[index]['locationCount'],
                        //     searchedList[index]['restaurantID']['reviewCount'],
                        //     MyLocalizations.of(context).reviews,
                        //     MyLocalizations.of(context).branches
                        // ),
                      ),
                    ],
                  );
                });
          })
        : Center(child: Text(MyLocalizations.of(context).noResultsFound));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        if (query.length >= 2) {
          searchList(query, setState);
        }
        return buildResults(context);
      },
    );
  }

  void searchList(String query, StateSetter setState) {
    if ((searchedList.length ?? 0) > 0) {
      setState(() {
        searchedList.clear();
      });
    }
    if ((restaurantList?.length ?? 0) > 0) {
      restaurantList.map((restaurant) {
        String restaurantName =
            restaurant['restaurantID']['restaurantName'] ?? '';
        if (restaurantName != null) {
          if (restaurantName.toLowerCase().startsWith(query.toLowerCase())) {
            setState(() {
              searchedList.add(restaurant);
            });
          }
        }
      }).toList();
    }
  }
}
