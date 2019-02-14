import 'package:flutter/material.dart';
import '../../widgets/coupon-card.dart';
import '../../styles/styles.dart';
import '../../services/main-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';

class CouponsList extends StatefulWidget {
  final String locationId;

  CouponsList({Key key, this.locationId}) : super(key: key);

  @override
  _CouponsListState createState() => _CouponsListState();
}

class _CouponsListState extends State<CouponsList> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();

  Future<dynamic> getCouponsByLocationId() async {
    return await MainService.getCouponsByLocationId(widget.locationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextb,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        title: new Text('Coupons', style: titleBoldWhiteOSS()),
        centerTitle: true,
      ),
      body: AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getCouponsByLocationId(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          if (data is Map<String, dynamic> && data['message'] != null) {
            return buildEmptyPage(data['message']);
          } else if (data.length > 0) {
            return ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return CouponCard(
                    coupon: data[index],
                  );
                });
          }
        },
      ),
    );
  }

  static Widget buildEmptyPage(String msg) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: NoData(message: msg),
    );
  }
}
