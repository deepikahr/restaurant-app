import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:flutter/material.dart';

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
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          HomePageState().goToProductListPage(
                              context,
                              searchedList[index],
                              true,
                              localizedValues,
                              locale);
                        },
                        child: Text('hhhh'),
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
