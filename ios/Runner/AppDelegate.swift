import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let storageChannel = FlutterMethodChannel(name: "com.spendwise.app/storage",
                                              binaryMessenger: controller.binaryMessenger)
    storageChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getFreeStorageSpace" {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
          if let freeSpace = attrs[.systemFreeSize] as? Int64 {
            result(freeSpace)
            return
          }
        }
        result(FlutterError(code: "UNAVAILABLE", message: "Storage space unavailable", details: nil))
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
