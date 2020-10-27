import 'package:flutter/material.dart';

const PRIMARY = const Color(0xFFB6236C);
final primaryLight = const Color(0xFFD489AC);
final secondary = const Color(0xFF2AA1BF);
final border = const Color(0xF707070);
final bgcolor = const Color(0xFF8FD3F4);
final blacktext = const Color(0xFF272A3F);

final green = const Color(0xFF5ECB56);
final red = const Color(0xFFff5757);

final bgColor = const Color(0xFFefefef);

final darkTexta = const Color(0xFF333333);
final darkTextb = const Color(0xFF343434);
final darkTextc = const Color(0xFFbab6b8);

final greyTexta = const Color(0xFF888888);
final greyTextb = const Color(0xFF8996A0);
final greyTextc = const Color(0xFF8c8d8e);
final greyTextd = const Color(0xFFcccccc);

final whiteTextb = const Color(0xFFf8f8f8);
final whitec = const Color(0xFFf5f5f5);

final facebook = const Color(0xFF3A589E);
final twitter = const Color(0xFF33CCFF);
final marigold = const Color(0xFFFECC04);
final yellow = const Color(0xFFFEC004);

final greyc = const Color(0xFFF1F3F4);

final blued = const Color(0xFFF7E93A7);

//----------------------------------- font family for main.dart ---------------------------

const FONT_FAMILY = 'Roboto';

//--------------------------------- screen height & width ----------------------------------

double screenHeight(context) {
  return MediaQuery.of(context).size.height;
}

double screenWidth(context) {
  return MediaQuery.of(context).size.width;
}

//.................................. open - sans Light ....................................

TextStyle titleBoldOSL() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: darkTextb,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle textbarlowSemiBoldwhite() {
  return TextStyle(
    fontSize: 17.0,
    fontFamily: 'BarlowSemiBold',
    color: Colors.white,
    fontWeight: FontWeight.w700,
  );
}

TextStyle textbarlowSemiBoldBlack() {
  return TextStyle(
    fontSize: 17.0,
    fontFamily: 'BarlowSemiBold',
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );
}

TextStyle textbarlowSemiBoldWhite() {
  return TextStyle(
    fontSize: 17.0,
    fontFamily: 'BarlowSemiBold',
    color: Colors.white,
    fontWeight: FontWeight.w700,
  );
}

TextStyle hintSfsemiboldb() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: blacktext,
    fontFamily: 'SfUiDSemiBold',
  );
}

TextStyle textOSL() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: darkTextb,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle textred() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13.0,
    color: red,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle textOS() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13.0,
    color: darkTextb,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle textOSl() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: darkTextb,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleGreyLightOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: Colors.white70,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleLightOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: Colors.white70,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallWhiteLightOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: Colors.white,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStylesmallWhiteLightOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: Colors.white,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallWhiteBoldOSL() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: Colors.white,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallLightOSL() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: darkTextc,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallOSL() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 14.0,
    color: darkTextc,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallTextOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.grey.shade500,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallTextWhiteOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.white,
    letterSpacing: 1.0,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallDarkOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: darkTextb,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleSmallDarkBoldOSL() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13.0,
    color: darkTextb,
    fontFamily: 'OpenSansLight',
  );
}

//.................................. open - sans Regular....................................

TextStyle titleBoldOSR() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle titleLightWhiteOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20.0,
    color: Colors.white,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle titleWhiteOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    color: Colors.white,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle textOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle subTitleWhiteLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: Colors.white,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle subTitleWhiteShadeLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: Colors.white70,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle textLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleGreyLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: greyTexta,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleGreyLightOSRDescription() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: Colors.white,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: darkTextc,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallDarkLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallWhiteOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle smallTitleWhiteOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: Colors.white,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallOSR() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 12.0,
    color: darkTextc,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallTextOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.grey.shade500,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallDarkOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallTextDarkOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintDarkOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 11.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallDarkBoldOSR() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallWhiteLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.white70,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleWhiteLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallGReyLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: greyTextd,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 14.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle textBlackOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: darkTextb,
    fontFamily: 'OpenSansRegular',
  );
}

//.................................. open - sans Semibold....................................

TextStyle hintStyleSmallOSS() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 14.0,
    color: darkTextc,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle hintStyleSmallDarkOSS() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: darkTextb,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle hintStyleDarkOSS() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12.0,
    color: darkTextb,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle hintStyleWhiteLightOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: Colors.white,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle hintStyleSmallWhiteLightOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle hintStyleSmallWhiteLightOSSStrike() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSansSemibold',
    decoration: TextDecoration.lineThrough,
  );
}

TextStyle hintStyleSmallLightOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.grey.shade500,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle subTitleLightOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: Colors.white,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle subTitleDarkBoldOSS() {
  return TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16.0,
    color: darkTexta,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle subTitleDarkLightOSS() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: darkTexta,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle titleBoldWhiteOSS() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    color: Colors.white,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle titleLightWhiteOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 18.0,
    color: Colors.white,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle titleDarkOSS() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: darkTextb,
    letterSpacing: 1.0,
    fontFamily: 'OpenSansSemibold',
  );
}

//.................................. open - sans bold....................................

TextStyle subTitleLightOSB() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: Colors.white,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle subTitleWhiteBOldOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: Colors.white,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle titleDarkBoldOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20.0,
    color: darkTextb,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle titleWhiteBoldOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20.0,
    color: Colors.white,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle hintStyleSmallOSB() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 14.0,
    color: darkTextb,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle titleWhiteOSB() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22.0,
    color: Colors.white,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle titleDarkOSB() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22.0,
    color: darkTextb,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle titleBigDarkOSB() {
  return TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 26.0,
    color: darkTextb,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle hintStyleOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: darkTextb,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle hintStyleLightOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13.0,
    color: Colors.white,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle hintStyleSmallDarkOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12.0,
    color: darkTextb,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle hintStyleSmallLightOSB() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.grey.shade500,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle hintStyleWhiteLightOSB() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSansBold',
  );
}

//.................................. open - sans extra bold....................................

TextStyle subTitleLightOSEB() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: Colors.white,
    fontFamily: 'OpenSansExtraBold',
  );
}

TextStyle hintStyleSmallOSEB() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 14.0,
    color: darkTextb,
    fontFamily: 'OpenSansExtraBold',
  );
}

TextStyle hintStyleGreyOSEB() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 16.0,
    color: greyTextb,
    fontFamily: 'OpenSansExtraBold',
  );
}

TextStyle hintStyleSmallLightOSEB() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: Colors.grey.shade500,
    fontFamily: 'OpenSansExtraBold',
  );
}

//.................................. Proxima Nova Regular ....................................

TextStyle hintStyleSmallPNR() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 14.0,
    color: darkTextc,
    fontFamily: 'ProximaNovaRegular',
  );
}

TextStyle titleWhitePNR() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    color: Colors.white,
    letterSpacing: 1.0,
    fontFamily: 'ProximaNovaRegular',
  );
}

TextStyle titleDarkPNR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 18.0,
    color: Colors.white,
    fontFamily: 'ProximaNovaRegular',
  );
}

TextStyle hintStyleLightPNR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: darkTextb,
    fontFamily: 'ProximaNovaRegular',
  );
}

TextStyle hintStyleWhitePNR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: Colors.white,
    fontFamily: 'ProximaNovaRegular',
  );
}

//......................................... black - text ........................................................

TextStyle titleBold() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    color: Colors.black,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle titleBlackLightOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: Colors.black,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle titleBlackLightOSBCoupon() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: Colors.amber,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle titleBlackLight() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15.0,
    color: Colors.black,
  );
}

TextStyle titleBlackBoldOSB() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 17.0,
    color: Colors.black,
    fontFamily: 'OpenSansBold',
  );
}

//.............................................. green - text .............................................................

TextStyle hintStyleSmallGreenLightOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: green,
    fontFamily: 'OpenSansSemibold',
  );
}

//.............................................. primary - text .............................................................

TextStyle hintStylePrimaryLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: PRIMARY,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallPrimaryLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: PRIMARY,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallTextPrimaryLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: PRIMARY,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStylePrimaryOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: PRIMARY,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleSmallPrimaryOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12.0,
    color: PRIMARY,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStylePrimaryOSS() {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12.0,
    color: PRIMARY,
    fontFamily: 'OpenSansSemibold',
  );
}

TextStyle textPrimaryOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
    color: PRIMARY,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle textPrimaryBoldOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: PRIMARY,
    fontFamily: 'OpenSansBold',
  );
}

TextStyle titlePrimaryPNR() {
  return TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 22.0,
    color: PRIMARY,
    fontFamily: 'ProximaNovaRegular',
  );
}

//.............................................. yellow - text .............................................................

TextStyle hintStyleSmallYellowLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: yellow,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleYellowOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 10.0,
    color: yellow,
    fontFamily: 'OpenSansRegular',
  );
}

//.............................................. red - text .............................................................

TextStyle hintStyleSmallRedLightOSR() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13.0,
    color: Colors.red,
    fontFamily: 'OpenSansRegular',
  );
}

TextStyle hintStyleRedOSS() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 10.0,
    color: Colors.red,
    fontFamily: 'OpenSansRegular',
  );
}

//......................................... blue - text   ...........................................

TextStyle hintStyleBlueOSL() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    color: blued,
    fontFamily: 'OpenSansLight',
  );
}

TextStyle hintStyleTitleBlueOSR() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: blued,
    fontFamily: 'OpenSansREgular',
  );
}

// ------------------------------------greyTextd----------------------------------------

// -- copied from umiversity for homepage card ----------------------------------

TextStyle category() {
  return new TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: primaryLight,
  );
}

TextStyle titleStyle() {
  return new TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 16.0,
    color: PRIMARY,
  );
}

TextStyle subBoldTitle() {
  return new TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12.0,
    color: primaryLight,
  );
}

TextStyle priceDescription() {
  return new TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15.0,
    color: Colors.black38,
  );
}

TextStyle hintSfLightsm() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13.0,
    color: Color(0xFF6E7990),
    fontFamily: 'SfUiDLight',
  );
}

TextStyle hintSfLightbig() {
  return TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: blacktext,
    fontFamily: 'SfUiDLight',
  );
}

final List<Color> gradientColor = [
  const Color(0xffF0417C),
  const Color(0xFFFF3636),
];

TextStyle textsemiblack() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: Colors.black,
    fontFamily: 'BarlowSemibold',
  );
}

TextStyle textsemiboldblack() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 17.0,
    color: Colors.black,
    fontFamily: 'BarlowSemibold',
  );
}

TextStyle textbarlowRegular() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 10.0,
    color: Colors.black.withOpacity(0.60),
    fontFamily: 'BarlowRegular',
  );
}

TextStyle textregulargreen() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: PRIMARY,
    fontFamily: 'BarlowSemibold',
  );
}
