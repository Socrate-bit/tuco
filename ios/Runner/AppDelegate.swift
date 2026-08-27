import Flutter
import Speech
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppleSpeechPlugin") {
      AppleSpeechPlugin.register(with: registrar)
    }
  }
}

/// Native bridge for Apple's Speech framework: transcribes a recorded audio
/// file so the live-conversation flow can feed the text to SpeechSuper.
///
/// Kept in AppDelegate.swift so it compiles without editing the Xcode project.
class AppleSpeechPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "app/apple_speech", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(AppleSpeechPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "transcribeFile" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let args = call.arguments as? [String: Any],
      let path = args["path"] as? String,
      let localeId = args["localeId"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "path/localeId required", details: nil))
      return
    }
    transcribe(path: path, localeId: localeId, result: result)
  }

  private func transcribe(
    path: String, localeId: String, result: @escaping FlutterResult
  ) {
    SFSpeechRecognizer.requestAuthorization { status in
      DispatchQueue.main.async {
        guard status == .authorized else {
          result(FlutterError(
            code: "not_authorized",
            message: "Speech recognition not authorized (\(status.rawValue))",
            details: nil))
          return
        }
        let locale = Locale(identifier: localeId)
        guard let recognizer = SFSpeechRecognizer(locale: locale),
          recognizer.isAvailable
        else {
          result(FlutterError(
            code: "unavailable",
            message: "Recognizer unavailable for \(localeId)", details: nil))
          return
        }
        let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: path))
        request.shouldReportPartialResults = false
        // Prefer on-device recognition when the model is installed (offline,
        // private); otherwise fall back to Apple's server recognition.
        if recognizer.supportsOnDeviceRecognition {
          request.requiresOnDeviceRecognition = true
        }
        // recognitionTask fires more than once; guard so we reply exactly once.
        var replied = false
        recognizer.recognitionTask(with: request) { recResult, error in
          if replied { return }
          if let error = error {
            replied = true
            result(FlutterError(
              code: "recognition_failed",
              message: error.localizedDescription, details: nil))
            return
          }
          guard let recResult = recResult, recResult.isFinal else { return }
          replied = true
          result(recResult.bestTranscription.formattedString)
        }
      }
    }
  }
}
