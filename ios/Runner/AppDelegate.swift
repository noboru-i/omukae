import UIKit
import Flutter
import GoogleMaps

import geofencing

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCmLvpVVGJFiO8ibRJUpB-XJYdxWuzcjO4")
    GeneratedPluginRegistrant.register(with: self)
    GeofencingPlugin.setPluginRegistrantCallback({ (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
