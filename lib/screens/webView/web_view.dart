import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final title;
  final url;

  WebViewPage({this.title, this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isPageLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Visibility(
            visible: true,
            child: WebView(
              onPageFinished: (finish) {
                if (mounted)
                  setState(() {
                    isPageLoading = false;
                  });
              },
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
          Visibility(
            visible: isPageLoading,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
