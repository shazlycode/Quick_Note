import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return
          // 'ca-app-pub-3940256099942544/6300978111';
          'ca-app-pub-4877259958230721/7633593227';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4877259958230721/7633593227';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return
          // 'ca-app-pub-3940256099942544/1033173712';
          'ca-app-pub-4877259958230721/8296061918';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4877259958230721/8296061918';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return '<YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID>';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
}
