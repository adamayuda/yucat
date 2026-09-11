import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Answers one question for the Dart side: is this copy of the app running
  /// from TestFlight rather than the App Store?
  ///
  /// iOS names the app receipt `sandboxReceipt` for a TestFlight install and
  /// `receipt` for an App Store one, so a *single* binary can tell the two
  /// apart at runtime. That matters here because the TestFlight build is the
  /// same build submitted for review — a compile-time flag would mean shipping
  /// a binary nobody tested, or shipping the QA tools to real users.
  private static let channelName = "com.adam.yucat/build_env"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // `applicationRegistrar`, not `pluginRegistry` — the bridge vends the
    // binary messenger through the former (see FlutterEngine.h: it "provides
    // access to application-level services, such as the engine's
    // FlutterBinaryMessenger"), and this is an app-level channel, not a plugin.
    let channel = FlutterMethodChannel(
      name: AppDelegate.channelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isTestFlight":
        result(AppDelegate.isTestFlightBuild())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// A sandbox receipt means TestFlight — or a simulator / dev build, which is
  /// harmless: those already show the QA tools via `kDebugMode`.
  ///
  /// No receipt at all (the file is not written until the app is installed
  /// through the store) is treated as **not** TestFlight, so production stays
  /// the fail-safe default.
  private static func isTestFlightBuild() -> Bool {
    guard let url = Bundle.main.appStoreReceiptURL else { return false }
    return url.lastPathComponent == "sandboxReceipt"
  }
}
