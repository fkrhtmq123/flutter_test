import UIKit
import Flutter
import GoogleMaps

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // google map
    GMSServices.provideAPIKey("AIzaSyCtZOwp1Tat12kLaRBOsco92jdKFnS2EpM")
    // Use Firebase library to configure APIs
    FirebaseApp.configure()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
