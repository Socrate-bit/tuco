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
        request.shouldReportPartialResults = true
        // Prefer on-device recognition when the model is installed (offline,
        // private); otherwise fall back to Apple's server recognition.
        if recognizer.supportsOnDeviceRecognition {
          request.requiresOnDeviceRecognition = true
        }
        // On-device recognition RESETS its transcription after a silence pause
        // (and can emit one "final" result per utterance), so a single result
        // only covers the audio since the last pause. Bank every segment and
        // reply with all of them joined, so nothing said before a pause is lost.
        var banked = ""   // segments finalized or reset away
        var current = ""  // latest volatile transcription
        var replied = false
        var pendingReply: DispatchWorkItem?

        func bankCurrent() {
          guard !current.isEmpty else { return }
          banked = banked.isEmpty ? current : banked + " " + current
          current = ""
        }
        func fullText() -> String {
          (banked.isEmpty ? current : current.isEmpty ? banked : banked + " " + current)
            .trimmingCharacters(in: .whitespaces)
        }

        recognizer.recognitionTask(with: request) { recResult, error in
          DispatchQueue.main.async {
            if replied { return }
            if let error = error {
              replied = true
              pendingReply?.cancel()
              // The recognizer can error on a trailing silence after having
              // delivered text — return what we have rather than failing.
              let text = fullText()
              if text.isEmpty {
                result(FlutterError(
                  code: "recognition_failed",
                  message: error.localizedDescription, details: nil))
              } else {
                result(text)
              }
              return
            }
            guard let recResult = recResult else { return }
            let text = recResult.bestTranscription.formattedString
            // Reset detected: the new text restarts instead of extending the
            // previous one — bank what we had before adopting it.
            if !current.isEmpty && text.count < current.count
              && !current.hasPrefix(text) {
              bankCurrent()
            }
            current = text
            if recResult.isFinal {
              bankCurrent()
              // Debounce the reply: another segment's results may still follow
              // when the recognizer finalizes utterance by utterance.
              pendingReply?.cancel()
              let work = DispatchWorkItem {
                replied = true
                result(fullText())
              }
              pendingReply = work
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
            }
          }
        }
      }
    }
  }
}
