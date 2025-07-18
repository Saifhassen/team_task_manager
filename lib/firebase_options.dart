// GENERATED FILE - DO NOT MODIFY BY HAND

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCRndpndw77iHHqAFToAov2OPjRiJAOH50',
    authDomain: 'task-manager-app-dbc4b.firebaseapp.com',
    projectId: 'task-manager-app-dbc4b',
    storageBucket: 'task-manager-app-dbc4b.firebasestorage.app',
    messagingSenderId: '868121009788',
    appId: '1:868121009788:web:c4bd62003a9999d10933f9',
    measurementId: 'G-FQRY24NCH6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRndpndw77iHHqAFToAov2OPjRiJAOH50',
    authDomain: 'task-manager-app-dbc4b.firebaseapp.com',
    projectId: 'task-manager-app-dbc4b',
    storageBucket: 'task-manager-app-dbc4b.firebasestorage.app',
    messagingSenderId: '868121009788',
    appId: '1:868121009788:web:c4bd62003a9999d10933f9',
    measurementId: 'G-FQRY24NCH6',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRndpndw77iHHqAFToAov2OPjRiJAOH50',
    authDomain: 'task-manager-app-dbc4b.firebaseapp.com',
    projectId: 'task-manager-app-dbc4b',
    storageBucket: 'task-manager-app-dbc4b.firebasestorage.app',
    messagingSenderId: '868121009788',
    appId: '1:868121009788:web:c4bd62003a9999d10933f9',
    measurementId: 'G-FQRY24NCH6',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRndpndw77iHHqAFToAov2OPjRiJAOH50',
    authDomain: 'task-manager-app-dbc4b.firebaseapp.com',
    projectId: 'task-manager-app-dbc4b',
    storageBucket: 'task-manager-app-dbc4b.firebasestorage.app',
    messagingSenderId: '868121009788',
    appId: '1:868121009788:web:c4bd62003a9999d10933f9',
    measurementId: 'G-FQRY24NCH6',
  );
}