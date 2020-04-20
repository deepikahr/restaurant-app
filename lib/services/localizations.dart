import 'dart:async' show Future;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'constant.dart';

class MyLocalizations {
  final Map<String, Map<String, String>> localizedValues;
  MyLocalizations(this.locale, this.localizedValues);

  final Locale locale;

  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  String get hello {
    return localizedValues[locale.languageCode]['hello'];
  }

  String get home {
    return localizedValues[locale.languageCode]['home'];
  }

  String get cart {
    return localizedValues[locale.languageCode]['cart'];
  }

  String get myOrders {
    return localizedValues[locale.languageCode]['myOrders'];
  }

  String get favourites {
    return localizedValues[locale.languageCode]['favourites'];
  }

  String get profile {
    return localizedValues[locale.languageCode]['profile'];
  }

  String get aboutUs {
    return localizedValues[locale.languageCode]['aboutUs'];
  }

  String get login {
    return localizedValues[locale.languageCode]['login'];
  }

  String get logout {
    return localizedValues[locale.languageCode]['logout'];
  }

  String get restaurantsNearYou {
    return localizedValues[locale.languageCode]['restaurantsNearYou'];
  }

  String get topRatedRestaurants {
    return localizedValues[locale.languageCode]['topRatedRestaurants'];
  }

  String get newlyArrivedRestaurants {
    return localizedValues[locale.languageCode]['newlyArrivedRestaurants'];
  }

  String get viewAll {
    return localizedValues[locale.languageCode]['viewAll'];
  }

  String get reviews {
    return localizedValues[locale.languageCode]['reviews'];
  }

  String get branches {
    return localizedValues[locale.languageCode]['branches'];
  }

  String get selectLanguages {
    return localizedValues[locale.languageCode]['selectLanguages'];
  }

  String get shortDescription {
    return localizedValues[locale.languageCode]['shortDescription'];
  }

  String get emailId {
    return localizedValues[locale.languageCode]['emailId'];
  }

  String get fullName {
    return localizedValues[locale.languageCode]['fullName'];
  }

  String get mobileNumber {
    return localizedValues[locale.languageCode]['mobileNumber'];
  }

  String get subUrban {
    return localizedValues[locale.languageCode]['subUrban'];
  }

  String get state {
    return localizedValues[locale.languageCode]['state'];
  }

  String get country {
    return localizedValues[locale.languageCode]['country'];
  }

  String get postalCode {
    return localizedValues[locale.languageCode]['postalCode'];
  }

  String get address {
    return localizedValues[locale.languageCode]['address'];
  }

  String get cancel {
    return localizedValues[locale.languageCode]['cancel'];
  }

  String get save {
    return localizedValues[locale.languageCode]['save'];
  }

  String get yourEmail {
    return localizedValues[locale.languageCode]['yourEmail'];
  }

  String get yourPassword {
    return localizedValues[locale.languageCode]['yourPassword'];
  }

  String get loginToYourAccount {
    return localizedValues[locale.languageCode]['loginToYourAccount'];
  }

  String get forgotPassword {
    return localizedValues[locale.languageCode]['forgotPassword'];
  }

  String get dontHaveAccountYet {
    return localizedValues[locale.languageCode]['dontHaveAccountYet'];
  }

  String get signInNow {
    return localizedValues[locale.languageCode]['signInNow'];
  }

  String get pleaseEnterValidEmail {
    return localizedValues[locale.languageCode]['pleaseEnterValidEmail'];
  }

  String get pleaseEnterValidPassword {
    return localizedValues[locale.languageCode]['pleaseEnterValidPassword'];
  }

  String get pleaseEnterValidName {
    return localizedValues[locale.languageCode]['pleaseEnterValidName'];
  }

  String get pleaseEnterValidMobileNumber {
    return localizedValues[locale.languageCode]['pleaseEnterValidMobileNumber'];
  }

  String get loginSuccessful {
    return localizedValues[locale.languageCode]['loginSuccessful'];
  }

  String get password {
    return localizedValues[locale.languageCode]['password'];
  }

  String get acceptTerms {
    return localizedValues[locale.languageCode]['acceptTerms'];
  }

  String get registerNow {
    return localizedValues[locale.languageCode]['registerNow'];
  }

  String get register {
    return localizedValues[locale.languageCode]['register'];
  }

  String get resetPassword {
    return localizedValues[locale.languageCode]['resetPassword'];
  }

  String get resetPasswordOtp {
    return localizedValues[locale.languageCode]['resetPasswordOtp'];
  }

  String get resetMessage {
    return localizedValues[locale.languageCode]['resetMessage'];
  }

  String get verifyOtp {
    return localizedValues[locale.languageCode]['verifyOtp'];
  }

  String get otpErrorMessage {
    return localizedValues[locale.languageCode]['otpErrorMessage'];
  }

  String get otpMessage {
    return localizedValues[locale.languageCode]['otpMessage'];
  }

  String get createPassword {
    return localizedValues[locale.languageCode]['createPassword'];
  }

  String get createPasswordMessage {
    return localizedValues[locale.languageCode]['createPasswordMessage'];
  }

  String get connectionError {
    return localizedValues[locale.languageCode]['connectionError'];
  }

  String get favoritesListEmpty {
    return localizedValues[locale.languageCode]['favoritesListEmpty'];
  }

  String get removedFavoriteItem {
    return localizedValues[locale.languageCode]['removedFavoriteItem'];
  }

  String get cartEmpty {
    return localizedValues[locale.languageCode]['cartEmpty'];
  }

  String get upcoming {
    return localizedValues[locale.languageCode]['upcoming'];
  }

  String get history {
    return localizedValues[locale.languageCode]['history'];
  }

  String get noCompletedOrders {
    return localizedValues[locale.languageCode]['noCompletedOrders'];
  }

  String get orders {
    return localizedValues[locale.languageCode]['orders'];
  }

  String get status {
    return localizedValues[locale.languageCode]['status'];
  }

  String get view {
    return localizedValues[locale.languageCode]['view'];
  }

  String get track {
    return localizedValues[locale.languageCode]['track'];
  }

  String get total {
    return localizedValues[locale.languageCode]['total'];
  }

  String get paymentMode {
    return localizedValues[locale.languageCode]['paymentMode'];
  }

  String get chargesIncluding {
    return localizedValues[locale.languageCode]['chargesIncluding'];
  }

  String get trackOrder {
    return localizedValues[locale.languageCode]['trackOrder'];
  }

  String get orderProgress {
    return localizedValues[locale.languageCode]['orderProgress'];
  }

  String get daysAgo {
    return localizedValues[locale.languageCode]['daysAgo'];
  }

  String get weeksAgo {
    return localizedValues[locale.languageCode]['weeksAgo'];
  }

  String get dayAgo {
    return localizedValues[locale.languageCode]['dayAgo'];
  }

  String get weekAgo {
    return localizedValues[locale.languageCode]['weekAgo'];
  }

  String get usersReview {
    return localizedValues[locale.languageCode]['usersReview'];
  }

  String get outletsDelivering {
    return localizedValues[locale.languageCode]['outletsDelivering'];
  }

  String get noLocationsFound {
    return localizedValues[locale.languageCode]['noLocationsFound'];
  }

  String get noProducts {
    return localizedValues[locale.languageCode]['noProducts'];
  }

  String get goToCart {
    return localizedValues[locale.languageCode]['goToCart'];
  }

  String get location {
    return localizedValues[locale.languageCode]['location'];
  }

  String get open {
    return localizedValues[locale.languageCode]['open'];
  }

  String get freeDeliveryAbove {
    return localizedValues[locale.languageCode]['freeDeliveryAbove'];
  }

  String get deliveryChargesOnly {
    return localizedValues[locale.languageCode]['deliveryChargesOnly'];
  }

  String get freeDeliveryAvailable {
    return localizedValues[locale.languageCode]['freeDeliveryAvailable'];
  }

  String get size {
    return localizedValues[locale.languageCode]['size'];
  }

  String get price {
    return localizedValues[locale.languageCode]['price'];
  }

  String get selectSize {
    return localizedValues[locale.languageCode]['selectSize'];
  }

  String get completeOrder {
    return localizedValues[locale.languageCode]['completeOrder'];
  }

  String get addNote {
    return localizedValues[locale.languageCode]['addNote'];
  }

  String get applyCoupon {
    return localizedValues[locale.languageCode]['applyCoupon'];
  }

  String get subTotal {
    return localizedValues[locale.languageCode]['subTotal'];
  }

  String get deliveryCharges {
    return localizedValues[locale.languageCode]['deliveryCharges'];
  }

  String get grandTotal {
    return localizedValues[locale.languageCode]['grandTotal'];
  }

  String get cookNote {
    return localizedValues[locale.languageCode]['cookNote'];
  }

  String get note {
    return localizedValues[locale.languageCode]['note'];
  }

  String get add {
    return localizedValues[locale.languageCode]['add'];
  }

  String get pleaseEnter {
    return localizedValues[locale.languageCode]['pleaseEnter'];
  }

  String get coupon {
    return localizedValues[locale.languageCode]['coupon'];
  }

  String get noCoupon {
    return localizedValues[locale.languageCode]['noCoupon'];
  }

  String get noResource {
    return localizedValues[locale.languageCode]['noResource'];
  }

  String get noCuisines {
    return localizedValues[locale.languageCode]['noCuisines'];
  }

  String get apply {
    return localizedValues[locale.languageCode]['apply'];
  }

  String get reviewOrder {
    return localizedValues[locale.languageCode]['reviewOrder'];
  }

  String get date {
    return localizedValues[locale.languageCode]['date'];
  }

  String get totalOrder {
    return localizedValues[locale.languageCode]['totalOrder'];
  }

  String get contactInformation {
    return localizedValues[locale.languageCode]['contactInformation'];
  }

  String get selectAddress {
    return localizedValues[locale.languageCode]['selectAddress'];
  }

  String get addAddress {
    return localizedValues[locale.languageCode]['addAddress'];
  }

  String get orderDetails {
    return localizedValues[locale.languageCode]['orderDetails'];
  }

  String get orderSummary {
    return localizedValues[locale.languageCode]['orderSummary'];
  }

  String get totalIncluding {
    return localizedValues[locale.languageCode]['totalIncluding'];
  }

  String get placeOrderNow {
    return localizedValues[locale.languageCode]['placeOrderNow'];
  }

  String get paymentMethod {
    return localizedValues[locale.languageCode]['paymentMethod'];
  }

  String get selectDateTime {
    return localizedValues[locale.languageCode]['selectDateTime'];
  }

  String get selectAddressFirst {
    return localizedValues[locale.languageCode]['selectAddressFirst'];
  }

  String get errorMessage {
    return localizedValues[locale.languageCode]['errorMessage'];
  }

  String get deliveryNotAvailable {
    return localizedValues[locale.languageCode]['deliveryNotAvailable'];
  }

  String get notDeliverToThisPostcode {
    return localizedValues[locale.languageCode]['notDeliverToThisPostcode'];
  }

  String get deliverToThisPostcode {
    return localizedValues[locale.languageCode]['deliverToThisPostcode'];
  }

  String get pickUp {
    return localizedValues[locale.languageCode]['pickUp'];
  }

  String get dineIn {
    return localizedValues[locale.languageCode]['dineIn'];
  }

  String get thankYou {
    return localizedValues[locale.languageCode]['thankYou'];
  }

  String get orderPlaced {
    return localizedValues[locale.languageCode]['orderPlaced'];
  }

  String get thankYouMessage {
    return localizedValues[locale.languageCode]['thankYouMessage'];
  }

  String get backTo {
    return localizedValues[locale.languageCode]['backTo'];
  }

  String get rateYourOrder {
    return localizedValues[locale.languageCode]['rateYourOrder'];
  }

  String get wereGlad {
    return localizedValues[locale.languageCode]['wereGlad'];
  }

  String get rateIt {
    return localizedValues[locale.languageCode]['rateIt'];
  }

  String get feedbackImportant {
    return localizedValues[locale.languageCode]['feedbackImportant'];
  }

  String get submit {
    return localizedValues[locale.languageCode]['submit'];
  }

  String get writeReview {
    return localizedValues[locale.languageCode]['writeReview'];
  }

  String get deliveryAddress {
    return localizedValues[locale.languageCode]['deliveryAddress'];
  }

  String get whereToDeliver {
    return localizedValues[locale.languageCode]['whereToDeliver'];
  }

  String get byCreating {
    return localizedValues[locale.languageCode]['byCreating'];
  }

  String get please {
    return localizedValues[locale.languageCode]['please'];
  }

  String get enterYour {
    return localizedValues[locale.languageCode]['enterYour'];
  }

  String get city {
    return localizedValues[locale.languageCode]['city'];
  }

  String get item {
    return localizedValues[locale.languageCode]['item'];
  }

  String get type {
    return localizedValues[locale.languageCode]['type'];
  }

  String get pickUpTime {
    return localizedValues[locale.languageCode]['pickUpTime'];
  }

  String get tableNo {
    return localizedValues[locale.languageCode]['tableNo'];
  }

  String get orderID {
    return localizedValues[locale.languageCode]['orderID'];
  }

  String get rate {
    return localizedValues[locale.languageCode]['rate'];
  }

  String get name {
    return localizedValues[locale.languageCode]['name'];
  }

  String get contactNo {
    return localizedValues[locale.languageCode]['contactNo'];
  }

  String get orderType {
    return localizedValues[locale.languageCode]['orderType'];
  }

  String get restaurant {
    return localizedValues[locale.languageCode]['restaurant'];
  }

  String get totalincludingGST {
    return localizedValues[locale.languageCode]['totalincludingGST'];
  }

  String get success {
    return localizedValues[locale.languageCode]['success'];
  }

  String get otp {
    return localizedValues[locale.languageCode]['otp'];
  }

  String get pleaseAccepttermsandconditions {
    return localizedValues[locale.languageCode]
        ['pleaseAccepttermsandconditions'];
  }

  String get alert {
    return localizedValues[locale.languageCode]['alert'];
  }

  String get ok {
    return localizedValues[locale.languageCode]['ok'];
  }

  String get addCard {
    return localizedValues[locale.languageCode]['addCard'];
  }

  String get nameonCard {
    return localizedValues[locale.languageCode]['nameonCard'];
  }

  String get pleaseenteryourfullname {
    return localizedValues[locale.languageCode]['pleaseenteryourfullname'];
  }

  String get creditCardNumber {
    return localizedValues[locale.languageCode]['creditCardNumber'];
  }

  String get cardNumbermustbeof16digit {
    return localizedValues[locale.languageCode]['cardNumbermustbeof16digit'];
  }

  String get mm {
    return localizedValues[locale.languageCode]['mm'];
  }

  String get invalidmonth {
    return localizedValues[locale.languageCode]['invalidmonth'];
  }

  String get yyyy {
    return localizedValues[locale.languageCode]['yyyy'];
  }

  String get invalidyear {
    return localizedValues[locale.languageCode]['invalidyear'];
  }

  String get cvv {
    return localizedValues[locale.languageCode]['cvv'];
  }

  String get cardNumbermustbeof3digit {
    return localizedValues[locale.languageCode]['cardNumbermustbeof3digit'];
  }

  String get selectOrderType {
    return localizedValues[locale.languageCode]['selectOrderType'];
  }

  String get restaurantAddress {
    return localizedValues[locale.languageCode]['restaurantAddress'];
  }

  String get dELIVERY {
    return localizedValues[locale.languageCode]['dELIVERY'];
  }

  String get clickToSlot {
    return localizedValues[locale.languageCode]['clickToSlot'];
  }

  String get dateandTime {
    return localizedValues[locale.languageCode]['dateandTime'];
  }

  String get time {
    return localizedValues[locale.languageCode]['time'];
  }

  String get selectDate {
    return localizedValues[locale.languageCode]['selectDate'];
  }

  String get closed {
    return localizedValues[locale.languageCode]['closed'];
  }

  String get pleaseSelectDatefirstforpickup {
    return localizedValues[locale.languageCode]
        ['pleaseSelectDatefirstforpickup'];
  }

  String get storeisClosedPleaseTryAgainduringouropeninghours {
    return localizedValues[locale.languageCode]
        ['storeisClosedPleaseTryAgainduringouropeninghours'];
  }

  String get somethingwentwrongpleaserestarttheapp {
    return localizedValues[locale.languageCode]
        ['somethingwentwrongpleaserestarttheapp'];
  }

  String get logoutSuccessfully {
    return localizedValues[locale.languageCode]['logoutSuccessfully'];
  }

  String get nearBy {
    return localizedValues[locale.languageCode]['nearBy'];
  }

  String get topRated {
    return localizedValues[locale.languageCode]['topRated'];
  }

  String get newlyArrived {
    return localizedValues[locale.languageCode]['newlyArrived'];
  }

  String get cod {
    return localizedValues[locale.languageCode]['cod'];
  }

  String get noPaymentMethods {
    return localizedValues[locale.languageCode]['noPaymentMethods'];
  }

  String get selectCard {
    return localizedValues[locale.languageCode]['selectCard'];
  }

  String get noSavedCardsPleaseaddone {
    return localizedValues[locale.languageCode]['noSavedCardsPleaseaddone'];
  }

  String get pleaseEnterCVV {
    return localizedValues[locale.languageCode]['pleaseEnterCVV'];
  }

  String get cVVmustbeof3digits {
    return localizedValues[locale.languageCode]['cVVmustbeof3digits'];
  }

  String get paymentFailed {
    return localizedValues[locale.languageCode]['paymentFailed'];
  }

  String get yourordercancelledPleasetryagain {
    return localizedValues[locale.languageCode]
        ['yourordercancelledPleasetryagain'];
  }

  String get productRemovedFromFavourite {
    return localizedValues[locale.languageCode]['productRemovedFromFavourite'];
  }

  String get productaddedtoFavourites {
    return localizedValues[locale.languageCode]['productaddedtoFavourites'];
  }

  String get whichextraingredientswouldyouliketoadd {
    return localizedValues[locale.languageCode]
        ['whichextraingredientswouldyouliketoadd'];
  }

  String get extra {
    return localizedValues[locale.languageCode]['extra'];
  }

  String get deliveryisNotAvailable {
    return localizedValues[locale.languageCode]['deliveryisNotAvailable'];
  }

  String get description {
    return localizedValues[locale.languageCode]['description'];
  }

  String get clearcart {
    return localizedValues[locale.languageCode]['clearcart'];
  }

  String get youhavesomeitemsalreadyinyourcartfromotherlocationremovetoaddthis {
    return localizedValues[locale.languageCode]
        ['youhavesomeitemsalreadyinyourcartfromotherlocationremovetoaddthis'];
  }

  String get yes {
    return localizedValues[locale.languageCode]['yes'];
  }

  String get no {
    return localizedValues[locale.languageCode]['no'];
  }

  String get nodeliveryavailable {
    return localizedValues[locale.languageCode]['nodeliveryavailable'];
  }

  String get freedeliveryabove {
    return localizedValues[locale.languageCode]['freedeliveryabove'];
  }

  String get freedeliveryavailable {
    return localizedValues[locale.languageCode]['freedeliveryavailable'];
  }

  String get storeisClosed {
    return localizedValues[locale.languageCode]['storeisClosed'];
  }

  String get openingTime {
    return localizedValues[locale.languageCode]['openingTime'];
  }

  String get sorry {
    return localizedValues[locale.languageCode]['sorry'];
  }

  String get restaurants {
    return localizedValues[locale.languageCode]['restaurants'];
  }

  String get restaurantSass {
    return localizedValues[locale.languageCode]['restaurantSass'];
  }

  String get grilledChickenLoremipsumdolorsitametconsecteturadipiscingelit {
    return localizedValues[locale.languageCode]
        ['grilledChickenLoremipsumdolorsitametconsecteturadipiscingelit'];
  }

  String get seddoeiusmodtemporincididuntutlaboreetdolormagna {
    return localizedValues[locale.languageCode]
        ['seddoeiusmodtemporincididuntutlaboreetdolormagna'];
  }

  String get pleaseSelectTimefirstforpickup {
    return localizedValues[locale.languageCode]
        ['pleaseSelectTimefirstforpickup'];
  }

  String get pleaseSelectAddshippingaddressfirst {
    return localizedValues[locale.languageCode]
        ['pleaseSelectAddshippingaddressfirst'];
  }

  String get noDeliverycharge {
    return localizedValues[locale.languageCode]['noDeliverycharge'];
  }

  String get flatNumber {
    return localizedValues[locale.languageCode]['flatNumber'];
  }

  String get apartmentName {
    return localizedValues[locale.languageCode]['apartmentName'];
  }

  String get landmark {
    return localizedValues[locale.languageCode]['landmark'];
  }

  String get addressType {
    return localizedValues[locale.languageCode]['addressType'];
  }

  String get choosefromphotos {
    return localizedValues[locale.languageCode]['choosefromphotos'];
  }

  String get takephoto {
    return localizedValues[locale.languageCode]['takephoto'];
  }

  String get removephoto {
    return localizedValues[locale.languageCode]['removephoto'];
  }

  greetTo(name) {
    return localizedValues[locale.languageCode]['greetTo']
        .replaceAll('{{name}}', name);
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  Map<String, Map<String, String>> localizedValues;

  MyLocalizationsDelegate(this.localizedValues);

  @override
  bool isSupported(Locale locale) => LANGUAGES.contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(
        MyLocalizations(locale, localizedValues));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
