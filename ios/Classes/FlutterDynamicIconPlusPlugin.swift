import Flutter
import UIKit
import SwiftTryCatch

public class FlutterDynamicIconPlusPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_dynamic_icon_plus", binaryMessenger: registrar.messenger())
    let instance = FlutterDynamicIconPlusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case MethodNames.supportsAlternateIcons:
        if #available(iOS 10.3, *){
            result(UIApplication.shared.supportsAlternateIcons)
        }
        else {
            result(FlutterError(code: "Unavailable", message: "Method supportsAlternateIcons unsupported on iOS version < 10.3", details: nil))
        }
    case MethodNames.getAlternateIconName:
        if #available(iOS 10.3, *){
            result(UIApplication.shared.alternateIconName)
        }
        else {
            result(FlutterError(code: "Unavailable", message: "Method getAlternateIconName unsupported on iOS version < 10.3", details: nil))
        }
    case MethodNames.setAlternateIconName:
        if #available(iOS 10.3, *){
            SwiftTryCatch.try {
                let args = call.arguments as! [String: Any]
                var iconName = args[Arguments.iconName]
                if(iconName == nil){
                    iconName = nil
                }
                
                UIApplication.shared.setAlternateIconName(iconName as? String) { error in
                    if let error {
                        result(
                            FlutterError(
                                code: "Failed to set icon \(error.localizedDescription)",
                                        message: error.localizedDescription,
                                        details: nil))
                    } else {
                        result(nil)
                    }
                }
            } catch: { (exception) in
                let errorReason = exception?.reason ?? "Unknown Error setAlternateIconName"
                print("\(errorReason)")
                result(
                    FlutterError(
                        code: "Failed to set icon: \(errorReason)",
                        message: errorReason,
                        details: nil))
            } finally: {
                result(nil)
            }
        }
        else {
            result(FlutterError(code: "Unavailable", message: "Method setAlternateIconName unsupported on iOS version < 10.3", details: nil))
        }
    case MethodNames.getApplicationIconBadgeNumber:
        if #available(iOS 10.3, *){
            result(NSNumber(value: UIApplication.shared.applicationIconBadgeNumber))
        }
        else {
            result(FlutterError(code: "Unavailable", message: "Method getApplicationIconBadgeNumber unsupported on iOS version < 10.3", details: nil))
        }
    case MethodNames.setApplicationIconBadgeNumber:
        let args = call.arguments as! [String: Any]
        if #available(iOS 10.3, *){
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: .badge) { granted, error in
                    if granted {
                        SwiftTryCatch.try {
                            let batchIconNumber = (args[Arguments.batchIconNumber] as? NSNumber)?.intValue ?? 0
                            UIApplication.shared.applicationIconBadgeNumber = batchIconNumber
                            result(nil)
                        } catch: { (exception) in
                            let errorReason = exception?.reason ?? "Unknown Error setApplicationIconBadgNumber"
                            print("\(errorReason)")
                            result(
                                FlutterError(
                                    code: "Failed to set batch icon number",
                                    message: errorReason,
                                    details: nil))
                        } finally: {
                            result(nil)
                        }
                    }
                    else {
                        SwiftTryCatch.try {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                             (granted, error) in
                                let batchIconNumber = (args[Arguments.batchIconNumber] as? NSNumber)?.intValue ?? 0
                                UIApplication.shared.applicationIconBadgeNumber = batchIconNumber
                                result(nil)
                            }
                        } catch: { (exception) in
                            let errorReason = exception?.reason ?? "Unknown Error setApplicationIconBadgeNumber"
                            print("\(errorReason)")
                            result(
                                FlutterError(
                                    code: "Failed to set icon",
                                    message: errorReason,
                                    details: nil))
                        } finally: {
                            result(nil)
                        }
                    }
                }
            }
            else {
                result(
                    FlutterError(
                        code: "Failed to set batch icon number",
                        message: "Permission denied by the user",
                        details: nil))
            }
        }
        else {
            SwiftTryCatch.try {
                let notificationSettings = UIUserNotificationSettings(types: .badge, categories: nil)

                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
                let batchIconNumber = (args[Arguments.batchIconNumber] as? NSNumber)?.intValue ?? 0
                UIApplication.shared.applicationIconBadgeNumber = batchIconNumber
                result(nil)
            } catch: { (exception) in
                let errorReason = exception?.reason ?? "Unknown Error setApplicationIconBadgeNumber"
                print(errorReason)
                result(
                    FlutterError(
                        code: "Failed to set batch icon number",
                        message: errorReason,
                        details: nil))
            } finally : {
                result(nil)
            }
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
