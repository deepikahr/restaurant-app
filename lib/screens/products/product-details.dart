// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:toast/toast.dart';
//
// import '../../services/common.dart';
// import '../../services/counter-service.dart';
// import '../../services/localizations.dart';
// import '../../services/profile-service.dart';
// import '../../services/sentry-services.dart';
// import '../../styles/styles.dart';
// import 'cart.dart';
//
// SentryError sentryError = new SentryError();
//
// class ProductDetailsPage extends StatefulWidget {
//   final Map<String, dynamic> product, locationInfo, taxInfo, tableInfo;
//   final String restaurantName, restaurantId, restaurantAddress;
//   final Map<String, Map<String, String>> localizedValues;
//   final String locale;
//
//   ProductDetailsPage(
//       {Key key,
//       this.product,
//       this.locationInfo,
//       this.restaurantName,
//       this.restaurantId,
//       this.taxInfo,
//       this.tableInfo,
//       this.restaurantAddress,
//       this.locale,
//       this.localizedValues})
//       : super(key: key);
//
//   @override
//   _ProductDetailsPageState createState() => _ProductDetailsPageState();
// }
//
// class _ProductDetailsPageState extends State<ProductDetailsPage> {
//   int selectedSizeIndex = 0;
//   int quantity = 1, cartCount;
//   double price = 0;
//   Map<String, dynamic> cartProduct;
//   List<dynamic> tempProducts = [];
//   bool isLoading = true;
//   bool isFavourite = false;
//   bool isAdded = false;
//   String favouriteId;
//   bool isLoggedIn = false;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   void _changeProductQuantity(bool increase) {
//     if (increase) {
//       if (mounted) {
//         setState(() {
//           quantity++;
//         });
//       }
//     } else {
//       if (quantity > 1) {
//         if (mounted) {
//           setState(() {
//             quantity--;
//           });
//         }
//       }
//     }
//     _calculatePrice();
//   }
//
//   void _calculatePrice() {
//     price = 0;
//     Map<String, dynamic> variant =
//         widget.product['variants'][selectedSizeIndex];
//     price = price + variant['price'];
//
//     if (mounted) {
//       setState(() {
//         price = price * quantity;
//       });
//     }
//     List<dynamic> extraIngredientsList = List<dynamic>();
//     if (widget.product['extraIngredients'].length > 0 &&
//         widget.product['extraIngredients'][0] != null) {
//       widget.product['extraIngredients'].forEach((item) {
//         if (item != null && item['isSelected'] != null && item['isSelected']) {
//           price = price + item['price'];
//           extraIngredientsList.add(item);
//         }
//       });
//     }
//     cartProduct = {
//       'Discount': variant['Discount'],
//       'MRP': variant['MRP'],
//       'note': null,
//       'Quantity': quantity,
//       'price': variant['price'],
//       'extraIngredients': extraIngredientsList,
//       'imageUrl': widget.product['imageUrl'],
//       'productId': widget.product['_id'],
//       'size': variant['size'],
//       'title': widget.product['title'],
//       'restaurant': widget.restaurantName,
//       'restaurantID': widget.restaurantId,
//       'totalPrice': price,
//       'restaurantAddress': widget.restaurantAddress
//     };
//   }
//
//   @override
//   void initState() {
//     Common.getToken().then((onValue) {
//       try {
//         if (onValue != null) {
//           if (mounted) {
//             setState(() {
//               isLoggedIn = true;
//               _checkFavourite();
//             });
//           }
//         }
//       } catch (error, stackTrace) {
//         sentryError.reportError(error, stackTrace);
//       }
//     }).catchError((onError) {
//       sentryError.reportError(onError, null);
//     });
//
//     _calculatePrice();
//     super.initState();
//     getGlobalSettingsData();
//   }
//
//   String currency = '';
//
//   getGlobalSettingsData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     currency = prefs.getString('currency');
//   }
//
//   void _checkFavourite() async {
//     ProfileService.checkFavourite(widget.product['_id']).then((onValue) {
//       try {
//         if (mounted) {
//           if (mounted) {
//             setState(() {
//               isLoading = false;
//               if (onValue['_id'] != null) {
//                 favouriteId = onValue['_id'];
//               }
//               if (onValue['resflag'] != null) {
//                 isFavourite = onValue['resflag'];
//               } else {
//                 isFavourite = false;
//               }
//             });
//           }
//         }
//       } catch (error, stackTrace) {
//         sentryError.reportError(error, stackTrace);
//       }
//     }).catchError((onError) {
//       sentryError.reportError(onError, null);
//     });
//   }
//
//   void showSnackbar(message) {
//     final snackBar = SnackBar(
//       content: Text(message),
//       duration: Duration(milliseconds: 3000),
//     );
//     _scaffoldKey.currentState.showSnackBar(snackBar);
//   }
//
//   void _addToFavourite() async {
//     if (mounted) {
//       setState(() {
//         isLoading = true;
//       });
//     }
//     if (isFavourite) {
//       ProfileService.removeFavouritById(favouriteId).then((onValue) {
//         try {
//           Toast.show(
//               MyLocalizations.of(context).productRemovedFromFavourite, context,
//               duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//           if (onValue != null) {
//             if (mounted) {
//               setState(() {
//                 favouriteId = null;
//                 isLoading = false;
//                 isFavourite = false;
//               });
//             }
//           }
//         } catch (error, stackTrace) {
//           sentryError.reportError(error, stackTrace);
//         }
//       }).catchError((onError) {
//         sentryError.reportError(onError, null);
//       });
//     } else {
//       ProfileService.addToFavourite(widget.product['_id'], widget.restaurantId,
//               widget.locationInfo['_id'])
//           .then((onValue) {
//         try {
//           Toast.show(
//               MyLocalizations.of(context).productaddedtoFavourites, context,
//               duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//           if (mounted) {
//             setState(() {
//               favouriteId = onValue['_id'];
//               isLoading = false;
//               isFavourite = true;
//             });
//           }
//         } catch (error, stackTrace) {
//           sentryError.reportError(error, stackTrace);
//         }
//       }).catchError((onError) {
//         sentryError.reportError(onError, null);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CounterService().getCounter().then((res) {
//       try {
//         if (mounted) {
//           setState(() {
//             cartCount = res;
//           });
//         }
//       } catch (error, stackTrace) {
//         sentryError.reportError(error, stackTrace);
//       }
//     }).catchError((onError) {
//       sentryError.reportError(onError, null);
//     });
//
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primary,
//         elevation: 0.0,
//         title: Text(
//           "${widget.product['title'][0].toUpperCase()}${widget.product['title'].substring(1)}",
//           style: textbarlowSemiBoldWhite(),
//         ),
//         centerTitle: true,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//         ),
//         actions: <Widget>[
//           GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (BuildContext context) => CartPage(
//                       locale: widget.locale,
//                       localizedValues: widget.localizedValues,
//                       taxInfo: widget.taxInfo,
//                       locationInfo: widget.locationInfo,
//                     ),
//                   ),
//                 );
//               },
//               child: Stack(
//                 children: <Widget>[
//                   Container(
//                       padding: EdgeInsets.only(top: 20.0, right: 10),
//                       child: Icon(Icons.shopping_cart)),
//                   Positioned(
//                       right: 3,
//                       top: 5,
//                       child: (cartCount == null || cartCount == 0)
//                           ? Text(
//                               '',
//                               style: TextStyle(fontSize: 14.0),
//                             )
//                           : Container(
//                               height: 20,
//                               width: 20,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.black,
//                               ),
//                               child: Text('${cartCount.toString()}',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontFamily: "bold",
//                                       fontSize: 11)),
//                             )),
//                 ],
//               )),
//           Padding(padding: EdgeInsets.only(left: 7.0)),
//           // buildLocationIcon(),
//           // Padding(padding: EdgeInsets.only(left: 7.0)),
//         ],
//       ),
//       body: Container(
//         alignment: AlignmentDirectional.topCenter,
//         color: Colors.white,
//         child: SingleChildScrollView(
//           child: ListView(
//             physics: ScrollPhysics(),
//             shrinkWrap: true,
//             children: <Widget>[
//               _buildProductTopImg(
//                 widget.product['imageUrl'],
//                 widget.product['description'],
//               ),
//               _buildHeadingBlock(
//                 MyLocalizations.of(context).size +
//                     ' & ' +
//                     MyLocalizations.of(context).price,
//                 MyLocalizations.of(context).selectSize,
//               ),
//               widget.product['variants'].length > 0
//                   ? _buildSingleSelectionBlock(widget.product['variants'])
//                   : Container(
//                       height: 0.0,
//                       width: 0.0,
//                     ),
//               Padding(
//                 padding: EdgeInsets.only(bottom: 5.0),
//                 child: widget.product['extraIngredients'].length > 0
//                     ? _buildHeadingBlock(
//                         MyLocalizations.of(context).extra,
//                         MyLocalizations.of(context)
//                             .whichextraingredientswouldyouliketoadd,
//                       )
//                     : Container(
//                         height: 0.0,
//                         width: 0.0,
//                       ),
//               ),
//               widget.product['extraIngredients'] != null
//                   ? _buildMultiSelectionBlock(
//                       widget.product['extraIngredients'])
//                   : Container(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         height: 110.0,
//         child: Column(
//           children: <Widget>[
//             _buildProductAddCounter(),
//             widget.locationInfo['deliveryInfo'] != null
//                 ? _buildAddToCartButton()
//                 : Padding(
//                     padding: const EdgeInsetsDirectional.only(
//                         start: 20.0, end: 20.0, bottom: 1.0),
//                     child: RawMaterialButton(
//                       padding:
//                           EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
//                       fillColor: primary,
//                       constraints: const BoxConstraints(minHeight: 44.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: new BorderRadius.circular(50.0),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           new Text(
//                             MyLocalizations.of(context).deliveryisNotAvailable,
//                             style: hintStyleWhiteLightOSB(),
//                           ),
//                         ],
//                       ),
//                       onPressed: null,
//                       splashColor: secondary,
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductTopImg(String imgUrl, String description) {
//     return Stack(
//       alignment: AlignmentDirectional.center,
//       fit: StackFit.passthrough,
//       children: <Widget>[
//         Image(
//           image: imgUrl != null
//               ? NetworkImage(imgUrl)
//               : AssetImage("lib/assets/headers/menu.png"),
//           fit: BoxFit.fill,
//           height: 200.0,
//         ),
//         isLoggedIn
//             ? Positioned(
//                 top: 0,
//                 left: 0,
//                 child: isLoading
//                     ? Image.asset(
//                         'lib/assets/icon/spinner.gif',
//                         width: 40.0,
//                         height: 40.0,
//                       )
//                     : InkWell(
//                         onTap: _addToFavourite,
//                         child: Icon(
//                           Icons.favorite,
//                           color: isFavourite ? primary : Colors.white,
//                           size: 40.0,
//                         ),
//                       ),
//               )
//             : Container(height: 0, width: 0),
//       ],
//     );
//   }
//
//   Widget _buildHeadingBlock(String title, String subtitle) {
//     return Padding(
//       padding: EdgeInsets.only(left: 10.0, right: 10.0),
//       child: Container(
//         color: whiteTextb,
//         height: 58.0,
//         child: new Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Padding(padding: EdgeInsets.only(top: 4.0)),
//             Text(
//               title,
//               style: titleDarkBoldOSB(),
//             ),
//             Text(
//               subtitle,
//               style: hintStyleSmallTextDarkOSR(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMultiSelectionBlock(List<dynamic> extras) {
//     return Container(
//       child: ListView.builder(
//         physics: ScrollPhysics(),
//         shrinkWrap: true,
//         itemCount: extras.length,
//         itemBuilder: (BuildContext context, int index) {
//           if (extras[index] != null && extras[index]['isSelected'] == null)
//             extras[index]['isSelected'] = false;
//           return extras[index] != null
//               ? Container(
//                   color: Colors.white,
//                   width: screenWidth(context),
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 10.0),
//                     child: Row(
//                       children: <Widget>[
//                         Checkbox(
//                           value: extras[index]['isSelected'],
//                           onChanged: (bool value) {
//                             if (mounted) {
//                               setState(() {
//                                 extras[index]['isSelected'] =
//                                     !extras[index]['isSelected'];
//                               });
//                               _calculatePrice();
//                             }
//                           },
//                           activeColor: primary,
//                         ),
//                         Text(
//                           extras[index]['name'] != null
//                               ? extras[index]['name']
//                               : '',
//                           style: hintStyleSmallDarkLightOSR(),
//                         ),
//                         Expanded(
//                           child: Padding(
//                               padding: const EdgeInsets.only(right: 15.0),
//                               child: new Text(
//                                 currency +
//                                     (extras[index]['price']).toStringAsFixed(2),
//                                 textAlign: TextAlign.end,
//                                 style: hintStyleTitleBlueOSR(),
//                               )),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : Container(
//                   color: Colors.white,
//                   width: screenWidth(context),
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 10.0),
//                   ),
//                 );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSingleSelectionBlock(List<dynamic> sizes) {
//     return Container(
//       color: greyc,
//       child: ListView.builder(
//         physics: ScrollPhysics(),
//         shrinkWrap: true,
//         padding: EdgeInsets.only(right: 0.0),
//         itemCount: sizes.length == null ? 0 : sizes.length,
//         itemBuilder: (BuildContext context, int index) {
//           if (sizes[index]['isSelected'] == null)
//             sizes[index]['isSelected'] = false;
//           return Container(
//             color: Colors.white,
//             width: screenWidth(context),
//             child: RadioListTile(
//               value: index,
//               groupValue: selectedSizeIndex,
//               selected: sizes[index]['isSelected'],
//               onChanged: (int selected) {
//                 if (mounted) {
//                   setState(() {
//                     selectedSizeIndex = selected;
//                     sizes[index]['isSelected'] = !sizes[index]['isSelected'];
//                   });
//                   _calculatePrice();
//                 }
//               },
//               activeColor: primary,
//               title: sizes[index]['size'] != null
//                   ? new Text(
//                       sizes[index]['size'],
//                       style: hintStyleSmallDarkLightOSR(),
//                     )
//                   : Text(''),
//               secondary: sizes[index]['price'] != null
//                   ? new Text(
//                       currency + sizes[index]['price'].toStringAsFixed(2),
//                       textAlign: TextAlign.end,
//                       style: hintStyleTitleBlueOSR(),
//                     )
//                   : Text(''),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildProductAddCounter() {
//     return Padding(
//       padding: const EdgeInsetsDirectional.only(
//         start: 20.0,
//         end: 20.0,
//         bottom: 10.0,
//       ),
//       child: RawMaterialButton(
//         onPressed: null,
//         padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
//         fillColor: primaryLight,
//         constraints: const BoxConstraints(minHeight: 44.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: new BorderRadius.circular(50.0),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             InkWell(
//               onTap: () {
//                 _changeProductQuantity(false);
//               },
//               child: Container(
//                 child: Image(
//                   image: AssetImage('lib/assets/icon/minus.png'),
//                   width: 26.0,
//                 ),
//               ),
//             ),
//             new Container(
//               alignment: AlignmentDirectional.center,
//               width: 26.0,
//               height: 26.0,
//               decoration: new BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: primary,
//               ),
//               child: new Text(quantity.toString(),
//                   textAlign: TextAlign.center, style: hintStyleLightOSB()),
//             ),
//             InkWell(
//               onTap: () {
//                 _changeProductQuantity(true);
//               },
//               child: Container(
//                   child: Image(
//                 image: AssetImage('lib/assets/icon/addbtn.png'),
//                 width: 26.0,
//               )),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddToCartButton() {
//     return Padding(
//       padding:
//           const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 1.0),
//       child: RawMaterialButton(
//         padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
//         fillColor: primary,
//         constraints: const BoxConstraints(minHeight: 44.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: new BorderRadius.circular(50.0),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               isAdded ? 'Added to cart' : MyLocalizations.of(context).addToCart,
//               style: hintStyleWhiteLightOSB(),
//             ),
//             Text(
//               currency + price.toStringAsFixed(2),
//               style: titleLightWhiteOSR(),
//             ),
//           ],
//         ),
//         onPressed: _checkIfCartIsAvailable,
//         splashColor: secondary,
//       ),
//     );
//   }
//
//   void _checkIfCartIsAvailable() {
//     Common.getCart().then((onValue) {
//       try {
//         if (onValue == null) {
//           _goToCart();
//         } else {
//           if (onValue['location'] == widget.locationInfo['_id']) {
//             _goToCart();
//           } else {
//             _showClearCartAlert();
//           }
//         }
//       } catch (error, stackTrace) {
//         sentryError.reportError(error, stackTrace);
//       }
//     }).catchError((onError) {
//       sentryError.reportError(onError, null);
//     });
//   }
//
//   void _goToCart() async {
//     addProduct();
// //    Navigator.push(
// //      context,
// //      MaterialPageRoute(
// //        builder: (BuildContext context) => CartPage(
// //          localizedValues: widget.localizedValues,
// //          locale: widget.locale,
// //          product: cartProduct,
// //          taxInfo: widget.taxInfo,
// //          locationInfo: widget.locationInfo,
// //        ),
// //      ),
// //    );
//   }
//
//   Future<void> _showClearCartAlert() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(MyLocalizations.of(context).clearcart + '?'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text(MyLocalizations.of(context)
//                         .youhavesomeitemsalreadyinyourcartfromotherlocationremovetoaddthis +
//                     '!'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             FlatButton(
//               child: Text(MyLocalizations.of(context).yes),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Common.removeCart();
//                 _goToCart();
//               },
//             ),
//             FlatButton(
//               child: Text(MyLocalizations.of(context).no),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void addProduct() async {
//     await Common.getProducts().then((productsList) {
//       if (productsList != null) {
//         tempProducts = productsList;
//         tempProducts.add(cartProduct);
//         for (int i = 0; i < tempProducts.length; i++) {}
//         Common.addProduct(tempProducts).then((value) {
//           setState(() {
//             isAdded = true;
//           });
//           Toast.show(
//               MyLocalizations.of(context).producthasbeenaddedtocart, context,
//               duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//         });
//       } else {
//         tempProducts.add(cartProduct);
//         Common.addProduct(tempProducts).then((value) {
//           setState(() {
//             isAdded = true;
//           });
//           Toast.show(
//               MyLocalizations.of(context).producthasbeenaddedtocart, context,
//               duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//         });
//       }
//       try {} catch (error, stackTrace) {
//         sentryError.reportError(error, stackTrace);
//       }
//     }).catchError((onError) {
//       sentryError.reportError(onError, null);
//     });
//   }
// }
