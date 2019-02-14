import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../other/thank-you.dart';
import '../../services/profile-service.dart';
import '../../services/common.dart';
// import '../../services/constant.dart';
// import 'package:stripe_payment/stripe_payment.dart';
// import 'package:razorpay_plugin/razorpay_plugin.dart';

class PaymentMethod extends StatefulWidget {
  final Map<String, dynamic> cart;

  PaymentMethod({Key key, this.cart}) : super(key: key);

  @override
  _PaymentMethodState createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  int selectedPaymentIndex = 0;
  bool isLoading = false;
  List<Map<String, dynamic>> paymentTypes = [
    {
      'type': 'Cash On Delivery',
      'icon': Icons.attach_money,
      'gateway': 'COD',
      'isSelected': true
    },
    // {
    //   'type': 'Stripe Payment',
    //   'icon': Icons.credit_card,
    //   'gateway': 'Stripe',
    //   'isSelected': false
    // },
    // {
    //   'type': 'PayPal Payment',
    //   'icon': Icons.credit_card,
    //   'gateway': 'PayPal',
    //   'isSelected': false
    // },
    // {
    //   'type': 'RazorPay Payment',
    //   'icon': Icons.credit_card,
    //   'gateway': 'RazorPay',
    //   'isSelected': false
    // }
  ];

  void _placeOrder() async {
    await Common.getPositionInfo().then((onValue) {
      widget.cart['position'] = onValue;
    });
    if (widget.cart['paymentOption'] == 'RazorPay') {
      // // Map<String, String> notesr= {'orderInfo': json.encode(widget.cart)};
      // Map<String, String> options = {
      //   'name': widget.cart['restaurant'],
      //   'currency': 'USD',
      //   'display_currency': 'USD',
      //   'image': 'https://www.73lines.com/web/image/12427',
      //   'description': 'Order Placed from ' + APP_NAME,
      //   'amount': (100 * widget.cart['grandTotal']).toStringAsFixed(2),
      //   'email': widget.cart['shippingAddress']['contactNumber'].toString(),
      //   'contact': widget.cart['shippingAddress']['contactNumber'].toString(),
      //   'theme': '#FF0000',
      //   'api_key': 'rzp_test_HjcXUWgYjGPIf9',
      //   // 'notes': notes.toString()
      // };
      // Map<dynamic, dynamic> paymentResponse =
      //     await Razorpay.showPaymentForm(options);
      // widget.cart['payment'] = {'paymentStatus': true};
      // widget.cart['paymentStatus'] = 'Success';
      // if (paymentResponse['code'] == 1) {
      //   _orderInfo();
      // }
    } else {
      _orderInfo();
    }
  }

  void _orderInfo() {
    ProfileService.placeOrder(widget.cart).then((onValue) {
      if (onValue != null && onValue['message'] != null) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => ThankYou()),
            (Route<dynamic> route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextb,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: new Text(
          'Payment Method',
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
      ),
      body: _buildPaymentMethodSelector(),
      bottomNavigationBar: Container(
        height: 70.0,
        color: PRIMARY,
        child: isLoading
            ? Image.asset(
                'lib/assets/icon/spinner.gif',
                width: 10.0,
                height: 10.0,
              )
            : GestureDetector(
                onTap: () {
                  if (!isLoading) {
                    setState(() {
                      isLoading = true;
                    });
                    _placeOrder();
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.only(top: 10.0)),
                    new Text(
                      "PLACE ORDER NOW",
                      style: subTitleWhiteLightOSR(),
                    ),
                    new Padding(padding: EdgeInsets.only(top: 5.0)),
                    new Text(
                      'Total: \$' +
                          widget.cart['grandTotal'].toStringAsFixed(2),
                      style: titleWhiteBoldOSB(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return ListView.builder(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(right: 0.0),
      itemCount: paymentTypes.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.all(8.0),
          color: Colors.white,
          child: RadioListTile(
            value: index,
            groupValue: selectedPaymentIndex,
            selected: paymentTypes[index]['isSelected'],
            onChanged: (int selected) {
              if (!isLoading) {
                setState(() {
                  selectedPaymentIndex = selected;
                  paymentTypes[index]['isSelected'] =
                      !paymentTypes[index]['isSelected'];
                  widget.cart['paymentOption'] = paymentTypes[index]['gateway'];
                });
              }
            },
            activeColor: PRIMARY,
            title: Text(
              paymentTypes[index]['type'],
              style: TextStyle(color: PRIMARY),
            ),
            secondary: Icon(
              paymentTypes[index]['icon'],
              color: PRIMARY,
              size: 16.0,
            ),
          ),
        );
      },
    );
  }
}
