// 🤖 Generated wholely or partially with Google Antigravity
import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let clipboardChannelName = "com.opennote.app/clipboard"
  private var clipboardChannel: FlutterMethodChannel?

  /// Registers all pubspec-referenced Flutter plugins in the given registry
  static func registerPlugins(with registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      // The following code will be called upon WorkmanagerPlugin's registration.
      AppDelegate.registerPlugins(with: registry)
    }

    // At least 12 hours between background fetches
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(12 * 60 * 60))

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    AppDelegate.registerPlugins(with: engineBridge.pluginRegistry)
    registerClipboardChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  private func registerClipboardChannel(messenger: FlutterBinaryMessenger) {
    guard clipboardChannel == nil else { return }
    let channel = FlutterMethodChannel(
      name: Self.clipboardChannelName,
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleClipboardCall(call, result: result)
    }
    clipboardChannel = channel
  }

  private func handleClipboardCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "copyImage":
      handleCopyImage(call, result: result)
    case "pasteImage":
      handlePasteImage(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleCopyImage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let imageData: Data?
    if let typedData = call.arguments as? FlutterStandardTypedData {
      imageData = typedData.data
    } else if let args = call.arguments as? [String: Any],
              let typedData = args["bytes"] as? FlutterStandardTypedData {
      imageData = typedData.data
    } else {
      imageData = nil
    }

    guard let data = imageData, !data.isEmpty else {
      result(FlutterError(code: "INVALID_ARGS", message: "Image bytes are required", details: nil))
      return
    }

    if let image = UIImage(data: data) {
      UIPasteboard.general.image = image
    } else {
      UIPasteboard.general.setData(data, forPasteboardType: "public.png")
    }
    result(true)
  }

  private func handlePasteImage(result: @escaping FlutterResult) {
    let pasteboard = UIPasteboard.general
    let supportedTypes: [(uti: String, ext: String)] = [
      ("public.png", ".png"),
      ("public.jpeg", ".jpeg"),
      ("com.compuserve.gif", ".gif"),
      ("org.webmproject.webp", ".webp"),
    ]

    for candidate in supportedTypes {
      if let data = pasteboard.data(forPasteboardType: candidate.uti), !data.isEmpty {
        result([
          "bytes": FlutterStandardTypedData(bytes: data),
          "extension": candidate.ext,
        ])
        return
      }
    }

    if let pngData = pasteboard.image?.pngData(), !pngData.isEmpty {
      result([
        "bytes": FlutterStandardTypedData(bytes: pngData),
        "extension": ".png",
      ])
      return
    }

    result(nil)
  }
}
