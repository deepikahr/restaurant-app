// To parse this JSON data, do
//
//     final restaurantNear = restaurantNearFromJson(jsonString);

import 'dart:convert';

RestaurantNear restaurantNearFromJson(String str) =>
    RestaurantNear.fromJson(json.decode(str));

String restaurantNearToJson(RestaurantNear data) => json.encode(data.toJson());

class RestaurantNear {
  RestaurantNear({
    this.dataArr,
    this.banners,
  });

  List<DataArr> dataArr;
  List<Banner> banners;

  factory RestaurantNear.fromJson(Map<String, dynamic> json) => RestaurantNear(
        dataArr: json["dataArr"] == null
            ? null
            : List<DataArr>.from(
                json["dataArr"].map((x) => DataArr.fromJson(x))),
        banners: json["Banners"] == null
            ? null
            : List<Banner>.from(json["Banners"].map((x) => Banner.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dataArr": dataArr == null
            ? null
            : List<dynamic>.from(dataArr.map((x) => x.toJson())),
        "Banners": banners == null
            ? null
            : List<dynamic>.from(banners.map((x) => x.toJson())),
      };
}

class Banner {
  Banner({
    this.id,
    this.type,
    this.bannerImage,
    this.locationId,
    this.v,
    this.externalLink,
  });

  String id;
  String type;
  BannerImage bannerImage;
  String locationId;
  int v;
  ExternalLink externalLink;

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
        id: json["_id"] == null ? null : json["_id"],
        type: json["type"] == null ? null : json["type"],
        bannerImage: json["bannerImage"] == null
            ? null
            : BannerImage.fromJson(json["bannerImage"]),
        locationId: json["locationId"] == null ? null : json["locationId"],
        v: json["__v"] == null ? null : json["__v"],
        externalLink: json["externalLink"] == null
            ? null
            : ExternalLink.fromJson(json["externalLink"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "type": type == null ? null : type,
        "bannerImage": bannerImage == null ? null : bannerImage.toJson(),
        "locationId": locationId == null ? null : locationId,
        "__v": v == null ? null : v,
        "externalLink": externalLink == null ? null : externalLink.toJson(),
      };
}

class BannerImage {
  BannerImage({
    this.imageUrl,
    this.publicId,
    this.filePath,
  });

  String imageUrl;
  String publicId;
  String filePath;

  factory BannerImage.fromJson(Map<String, dynamic> json) => BannerImage(
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
        publicId: json["public_Id"] == null ? null : json["public_Id"],
        filePath: json["filePath"] == null ? null : json["filePath"],
      );

  Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl == null ? null : imageUrl,
        "public_Id": publicId == null ? null : publicId,
        "filePath": filePath == null ? null : filePath,
      };
}

class ExternalLink {
  ExternalLink({
    this.title,
    this.link,
  });

  String title;
  String link;

  factory ExternalLink.fromJson(Map<String, dynamic> json) => ExternalLink(
        title: json["title"] == null ? null : json["title"],
        link: json["link"] == null ? null : json["link"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "link": link == null ? null : link,
      };
}

class DataArr {
  DataArr({
    this.list,
    this.range,
    this.distance,
  });

  ListClass list;
  int range;
  double distance;

  factory DataArr.fromJson(Map<String, dynamic> json) => DataArr(
        list: json["list"] == null ? null : ListClass.fromJson(json["list"]),
        range: json["range"] == null ? null : json["range"],
        distance: json["distance"] == null ? null : json["distance"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "list": list == null ? null : list.toJson(),
        "range": range == null ? null : range,
        "distance": distance == null ? null : distance,
      };
}

class ListClass {
  ListClass({
    this.id,
    this.rating,
    this.ratingCount,
    this.enable,
    this.message,
    this.isForHome,
    this.restaurantId,
    this.tax,
    this.alwaysReachable,
    this.featured,
    this.taxExist,
    this.locationName,
    this.contactPerson,
    this.contactNumber,
    this.email,
    this.alternateEmail,
    this.address,
    this.city,
    this.zip,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.aboutUs,
    this.createdAt,
    this.v,
    this.workingHours,
    this.homeUrl,
    this.alternateTelephone,
    this.cuisine,
  });

  String id;
  int rating;
  int ratingCount;
  bool enable;
  String message;
  bool isForHome;
  RestaurantId restaurantId;
  List<dynamic> tax;
  bool alwaysReachable;
  bool featured;
  bool taxExist;
  String locationName;
  String contactPerson;
  int contactNumber;
  String email;
  String alternateEmail;
  String address;
  String city;
  int zip;
  String state;
  Country country;
  double latitude;
  double longitude;
  String aboutUs;
  DateTime createdAt;
  int v;
  WorkingHours workingHours;
  String homeUrl;
  String alternateTelephone;
  List<ListCuisine> cuisine;

  factory ListClass.fromJson(Map<String, dynamic> json) => ListClass(
        id: json["_id"] == null ? null : json["_id"],
        rating: json["rating"] == null ? null : json["rating"],
        ratingCount: json["ratingCount"] == null ? null : json["ratingCount"],
        enable: json["enable"] == null ? null : json["enable"],
        message: json["message"] == null ? null : json["message"],
        isForHome: json["isForHome"] == null ? null : json["isForHome"],
        restaurantId: json["restaurantID"] == null
            ? null
            : RestaurantId.fromJson(json["restaurantID"]),
        tax: json["tax"] == null
            ? null
            : List<dynamic>.from(json["tax"].map((x) => x)),
        alwaysReachable:
            json["alwaysReachable"] == null ? null : json["alwaysReachable"],
        featured: json["featured"] == null ? null : json["featured"],
        taxExist: json["taxExist"] == null ? null : json["taxExist"],
        locationName:
            json["locationName"] == null ? null : json["locationName"],
        contactPerson:
            json["contactPerson"] == null ? null : json["contactPerson"],
        contactNumber:
            json["contactNumber"] == null ? null : json["contactNumber"],
        email: json["email"] == null ? null : json["email"],
        alternateEmail:
            json["alternateEmail"] == null ? null : json["alternateEmail"],
        address: json["address"] == null ? null : json["address"],
        city: json["city"] == null ? null : json["city"],
        zip: json["zip"] == null ? null : json["zip"],
        state: json["state"] == null ? null : json["state"],
        country:
            json["country"] == null ? null : countryValues.map[json["country"]],
        latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
        longitude:
            json["longitude"] == null ? null : json["longitude"].toDouble(),
        aboutUs: json["aboutUs"] == null ? null : json["aboutUs"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        v: json["__v"] == null ? null : json["__v"],
        workingHours: json["workingHours"] == null
            ? null
            : WorkingHours.fromJson(json["workingHours"]),
        homeUrl: json["homeUrl"] == null ? null : json["homeUrl"],
        alternateTelephone: json["alternateTelephone"] == null
            ? null
            : json["alternateTelephone"],
        cuisine: json["cuisine"] == null
            ? null
            : List<ListCuisine>.from(
                json["cuisine"].map((x) => ListCuisine.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "rating": rating == null ? null : rating,
        "ratingCount": ratingCount == null ? null : ratingCount,
        "enable": enable == null ? null : enable,
        "message": message == null ? null : message,
        "isForHome": isForHome == null ? null : isForHome,
        "restaurantID": restaurantId == null ? null : restaurantId.toJson(),
        "tax": tax == null ? null : List<dynamic>.from(tax.map((x) => x)),
        "alwaysReachable": alwaysReachable == null ? null : alwaysReachable,
        "featured": featured == null ? null : featured,
        "taxExist": taxExist == null ? null : taxExist,
        "locationName": locationName == null ? null : locationName,
        "contactPerson": contactPerson == null ? null : contactPerson,
        "contactNumber": contactNumber == null ? null : contactNumber,
        "email": email == null ? null : email,
        "alternateEmail": alternateEmail == null ? null : alternateEmail,
        "address": address == null ? null : address,
        "city": city == null ? null : city,
        "zip": zip == null ? null : zip,
        "state": state == null ? null : state,
        "country": country == null ? null : countryValues.reverse[country],
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "aboutUs": aboutUs == null ? null : aboutUs,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "__v": v == null ? null : v,
        "workingHours": workingHours == null ? null : workingHours.toJson(),
        "homeUrl": homeUrl == null ? null : homeUrl,
        "alternateTelephone":
            alternateTelephone == null ? null : alternateTelephone,
        "cuisine": cuisine == null
            ? null
            : List<dynamic>.from(cuisine.map((x) => x.toJson())),
      };
}

enum Country { INDIA, BOLIVIA }

final countryValues =
    EnumValues({"Bolivia": Country.BOLIVIA, "India": Country.INDIA});

class ListCuisine {
  ListCuisine({
    this.cuisineName,
    this.id,
    this.cuisineImg,
  });

  String cuisineName;
  String id;
  dynamic cuisineImg;

  factory ListCuisine.fromJson(Map<String, dynamic> json) => ListCuisine(
        cuisineName: json["cuisineName"] == null ? null : json["cuisineName"],
        id: json["_id"] == null ? null : json["_id"],
        cuisineImg: json["cuisineImg"],
      );

  Map<String, dynamic> toJson() => {
        "cuisineName": cuisineName == null ? null : cuisineName,
        "_id": id == null ? null : id,
        "cuisineImg": cuisineImg,
      };
}

class RestaurantId {
  RestaurantId({
    this.id,
    this.taxInfo,
    this.rating,
    this.reviewCount,
    this.restaurantName,
    this.logo,
    this.shippingType,
    this.deliveryCharge,
    this.minimumOrderAmount,
    this.cuisine,
    this.deliveryRange,
  });

  String id;
  TaxInfo taxInfo;
  int rating;
  int reviewCount;
  String restaurantName;
  String logo;
  ShippingType shippingType;
  int deliveryCharge;
  int minimumOrderAmount;
  List<RestaurantIdCuisine> cuisine;
  int deliveryRange;

  factory RestaurantId.fromJson(Map<String, dynamic> json) => RestaurantId(
        id: json["_id"] == null ? null : json["_id"],
        taxInfo:
            json["taxInfo"] == null ? null : TaxInfo.fromJson(json["taxInfo"]),
        rating: json["rating"] == null ? null : json["rating"],
        reviewCount: json["reviewCount"] == null ? null : json["reviewCount"],
        restaurantName:
            json["restaurantName"] == null ? null : json["restaurantName"],
        logo: json["logo"] == null ? null : json["logo"],
        shippingType: json["shippingType"] == null
            ? null
            : shippingTypeValues.map[json["shippingType"]],
        deliveryCharge:
            json["deliveryCharge"] == null ? null : json["deliveryCharge"],
        minimumOrderAmount: json["minimumOrderAmount"] == null
            ? null
            : json["minimumOrderAmount"],
        cuisine: json["cuisine"] == null
            ? null
            : List<RestaurantIdCuisine>.from(
                json["cuisine"].map((x) => RestaurantIdCuisine.fromJson(x))),
        deliveryRange:
            json["deliveryRange"] == null ? null : json["deliveryRange"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "taxInfo": taxInfo == null ? null : taxInfo.toJson(),
        "rating": rating == null ? null : rating,
        "reviewCount": reviewCount == null ? null : reviewCount,
        "restaurantName": restaurantName == null ? null : restaurantName,
        "logo": logo == null ? null : logo,
        "shippingType": shippingType == null
            ? null
            : shippingTypeValues.reverse[shippingType],
        "deliveryCharge": deliveryCharge == null ? null : deliveryCharge,
        "minimumOrderAmount":
            minimumOrderAmount == null ? null : minimumOrderAmount,
        "cuisine": cuisine == null
            ? null
            : List<dynamic>.from(cuisine.map((x) => x.toJson())),
        "deliveryRange": deliveryRange == null ? null : deliveryRange,
      };
}

class RestaurantIdCuisine {
  RestaurantIdCuisine({
    this.id,
  });

  Id id;

  factory RestaurantIdCuisine.fromJson(Map<String, dynamic> json) =>
      RestaurantIdCuisine(
        id: json["_id"] == null ? null : idValues.map[json["_id"]],
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : idValues.reverse[id],
      };
}

enum Id {
  THE_5_F118_D8_F6_E08020011_C58790,
  THE_5_F1_A9_E681_CBFB90011_F4_BD2_B,
  THE_5_F118_CC76_E08020011_C5878_E
}

final idValues = EnumValues({
  "5f118cc76e08020011c5878e": Id.THE_5_F118_CC76_E08020011_C5878_E,
  "5f118d8f6e08020011c58790": Id.THE_5_F118_D8_F6_E08020011_C58790,
  "5f1a9e681cbfb90011f4bd2b": Id.THE_5_F1_A9_E681_CBFB90011_F4_BD2_B
});

enum ShippingType { FIXED, FLEXIBLE }

final shippingTypeValues = EnumValues(
    {"fixed": ShippingType.FIXED, "flexible": ShippingType.FLEXIBLE});

class TaxInfo {
  TaxInfo({
    this.taxName,
    this.taxRate,
  });

  dynamic taxName;
  int taxRate;

  factory TaxInfo.fromJson(Map<String, dynamic> json) => TaxInfo(
        taxName: json["taxName"],
        taxRate: json["taxRate"] == null ? null : json["taxRate"],
      );

  Map<String, dynamic> toJson() => {
        "taxName": taxName,
        "taxRate": taxRate == null ? null : taxRate,
      };
}

class WorkingHours {
  WorkingHours({
    this.isAlwaysOpen,
    this.daySchedule,
  });

  bool isAlwaysOpen;
  List<DaySchedule> daySchedule;

  factory WorkingHours.fromJson(Map<String, dynamic> json) => WorkingHours(
        isAlwaysOpen:
            json["isAlwaysOpen"] == null ? null : json["isAlwaysOpen"],
        daySchedule: json["daySchedule"] == null
            ? null
            : List<DaySchedule>.from(
                json["daySchedule"].map((x) => DaySchedule.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isAlwaysOpen": isAlwaysOpen == null ? null : isAlwaysOpen,
        "daySchedule": daySchedule == null
            ? null
            : List<dynamic>.from(daySchedule.map((x) => x.toJson())),
      };
}

class DaySchedule {
  DaySchedule({
    this.timeSchedule,
    this.day,
    this.isClosed,
  });

  List<TimeSchedule> timeSchedule;
  String day;
  bool isClosed;

  factory DaySchedule.fromJson(Map<String, dynamic> json) => DaySchedule(
        timeSchedule: json["timeSchedule"] == null
            ? null
            : List<TimeSchedule>.from(
                json["timeSchedule"].map((x) => TimeSchedule.fromJson(x))),
        day: json["day"] == null ? null : json["day"],
        isClosed: json["isClosed"] == null ? null : json["isClosed"],
      );

  Map<String, dynamic> toJson() => {
        "timeSchedule": timeSchedule == null
            ? null
            : List<dynamic>.from(timeSchedule.map((x) => x.toJson())),
        "day": day == null ? null : day,
        "isClosed": isClosed == null ? null : isClosed,
      };
}

class TimeSchedule {
  TimeSchedule({
    this.closingTime,
    this.closeTimeIn12Hr,
    this.closeTimeMeridian,
    this.openTime,
    this.openTimeIn12Hr,
    this.openTimeMeridian,
  });

  String closingTime;
  String closeTimeIn12Hr;
  TimeMeridian closeTimeMeridian;
  String openTime;
  String openTimeIn12Hr;
  TimeMeridian openTimeMeridian;

  factory TimeSchedule.fromJson(Map<String, dynamic> json) => TimeSchedule(
        closingTime: json["closingTime"] == null ? null : json["closingTime"],
        closeTimeIn12Hr:
            json["closeTimeIn12Hr"] == null ? null : json["closeTimeIn12Hr"],
        closeTimeMeridian: json["closeTimeMeridian"] == null
            ? null
            : timeMeridianValues.map[json["closeTimeMeridian"]],
        openTime: json["openTime"] == null ? null : json["openTime"],
        openTimeIn12Hr:
            json["openTimeIn12Hr"] == null ? null : json["openTimeIn12Hr"],
        openTimeMeridian: json["openTimeMeridian"] == null
            ? null
            : timeMeridianValues.map[json["openTimeMeridian"]],
      );

  Map<String, dynamic> toJson() => {
        "closingTime": closingTime == null ? null : closingTime,
        "closeTimeIn12Hr": closeTimeIn12Hr == null ? null : closeTimeIn12Hr,
        "closeTimeMeridian": closeTimeMeridian == null
            ? null
            : timeMeridianValues.reverse[closeTimeMeridian],
        "openTime": openTime == null ? null : openTime,
        "openTimeIn12Hr": openTimeIn12Hr == null ? null : openTimeIn12Hr,
        "openTimeMeridian": openTimeMeridian == null
            ? null
            : timeMeridianValues.reverse[openTimeMeridian],
      };
}

enum TimeMeridian { EMPTY, AM, PM }

final timeMeridianValues = EnumValues(
    {"AM": TimeMeridian.AM, "": TimeMeridian.EMPTY, "PM": TimeMeridian.PM});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
