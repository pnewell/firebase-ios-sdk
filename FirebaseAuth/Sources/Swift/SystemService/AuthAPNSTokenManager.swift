// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if !os(macOS) && !os(watchOS)
  import Foundation

  private import UIKit

  // TODO: This may be needed for extension detecting support
  // private import FirebaseCoreExtension

  #if SWIFT_PACKAGE
    private import GoogleUtilities_Environment
  #else
    private import GoogleUtilities
  #endif // SWIFT_PACKAGE

  // Protocol to help with unit tests.
  protocol AuthAPNSTokenApplication {
    func registerForRemoteNotifications()
  }

  extension UIApplication: AuthAPNSTokenApplication {}

  /// A class to manage APNs token in memory.
  @available(iOS 13, tvOS 13, macOS 10.15, macCatalyst 13, watchOS 7, *)
  class AuthAPNSTokenManager: NSObject {
    /// The timeout for registering for remote notification.
    ///
    /// Only tests should access this property.
    var timeout: TimeInterval = 5

    /// Initializes the instance.
    /// - Parameter application: The  `UIApplication` to request the token from.
    /// - Returns: The initialized instance.
    init(withApplication application: AuthAPNSTokenApplication) {
      self.application = application
    }

    /// Attempts to get the APNs token.
    /// - Parameter callback: The block to be called either immediately or in future, either when a
    /// token becomes available, or when timeout occurs, whichever happens earlier.
    ///
    /// This function is internal to make visible for tests.
    func getTokenInternal(callback: @escaping (AuthAPNSToken?, Error?) -> Void) {
      if let token = tokenStore {
        callback(token, nil)
        return
      }
      if pendingCallbacks.count > 0 {
        pendingCallbacks.append(callback)
        return
      }
      pendingCallbacks = [callback]

      DispatchQueue.main.async {
        self.application.registerForRemoteNotifications()
      }
      let applicableCallbacks = pendingCallbacks
      let deadline = DispatchTime.now() + timeout
      kAuthGlobalWorkQueue.asyncAfter(deadline: deadline) {
        // Only cancel if the pending callbacks remain the same, i.e., not triggered yet.
        if applicableCallbacks.count == self.pendingCallbacks.count {
          self.callback(withToken: nil, error: nil)
        }
      }
    }

    func getToken() async throws -> AuthAPNSToken {
      return try await withCheckedThrowingContinuation { continuation in
        self.getTokenInternal { token, error in
          if let token {
            continuation.resume(returning: token)
          } else {
            continuation.resume(throwing: error!)
          }
        }
      }
    }

    /// The APNs token, if one is available.
    ///
    /// Setting a token with AuthAPNSTokenTypeUnknown will automatically converts it to
    /// a token with the automatically detected type.
    var token: AuthAPNSToken? {
      get {
        tokenStore
      }
      set(setToken) {
        guard let setToken else {
          tokenStore = nil
          return
        }
        var newToken = setToken
        if setToken.type == AuthAPNSTokenType.unknown {
          let detectedTokenType = isProductionApp() ? AuthAPNSTokenType.prod : AuthAPNSTokenType
            .sandbox
          newToken = AuthAPNSToken(withData: setToken.data, type: detectedTokenType)
        }
        tokenStore = newToken
        callback(withToken: newToken, error: nil)
      }
    }

    /// Should only be written to in tests
    var tokenStore: AuthAPNSToken?

    /// Cancels any pending `getTokenWithCallback:` request.
    /// - Parameter error: The error to return .
    func cancel(withError error: Error) {
      callback(withToken: nil, error: error)
    }

    /// Enable unit test faking.
    var application: AuthAPNSTokenApplication
    private var pendingCallbacks: [(AuthAPNSToken?, Error?) -> Void] = []

    private func callback(withToken token: AuthAPNSToken?, error: Error?) {
      let pendingCallbacks = self.pendingCallbacks
      self.pendingCallbacks = []
      for callback in pendingCallbacks {
        callback(token, error)
      }
    }

    private func isProductionApp() -> Bool {
      let defaultAppTypeProd = true
      if GULAppEnvironmentUtil.isSimulator() {
        AuthLog.logInfo(code: "I-AUT000006", message: "Assuming prod APNs token type on simulator.")
        return defaultAppTypeProd
      }
      // Apps distributed via AppStore or TestFlight use the Production APNS certificates.
      if GULAppEnvironmentUtil.isFromAppStore() {
        return defaultAppTypeProd
      }

      // TODO: resolve https://github.com/firebase/firebase-ios-sdk/issues/10921
      if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
        // Distributed via TestFlight
        return defaultAppTypeProd
      }

      let path = Bundle.main.bundlePath + "embedded.mobileprovision"
      guard let url = URL(string: path) else {
        AuthLog.logInfo(code: "I-AUT000007", message: "\(path) does not exist")
        return defaultAppTypeProd
      }
      do {
        let profileData = try Data(contentsOf: url)

        // The "embedded.mobileprovision" sometimes contains characters with value 0, which signals
        // the end of a c-string and halts the ASCII parser, or with value > 127, which violates
        // strict 7-bit ASCII. Replace any 0s or invalid characters in the input.
        let byteArray = [UInt8](profileData)
        var outBytes: [UInt8] = []
        for byte in byteArray {
          if byte == 0 || byte > 127 {
            outBytes.append(46) // ASCII '.'
          } else {
            outBytes.append(byte)
          }
        }
        guard let embeddedProfile = String(bytes: outBytes, encoding: .utf8) else {
          AuthLog.logInfo(code: "I-AUT000008",
                          message: "Error while reading embedded mobileprovision. " +
                            "Failed to convert to String")
          return defaultAppTypeProd
        }

        let scanner = Scanner(string: embeddedProfile)
        if scanner.scanUpToString("<plist") != nil {
          guard let plistContents = scanner.scanUpToString("</plist>"),
                let data = plistContents.data(using: .utf8) else {
            return defaultAppTypeProd
          }

          do {
            let plistData = try PropertyListSerialization.propertyList(from: data, format: nil)
            guard let plistMap = plistData as? [String: Any] else {
              AuthLog.logInfo(code: "I-AUT000008",
                              message: "Error while converting assumed plist to dictionary.")
              return defaultAppTypeProd
            }
            if plistMap["ProvisionedDevices"] != nil {
              AuthLog.logInfo(code: "I-AUT000011",
                              message: "Provisioning profile has specifically provisioned devices, " +
                                "most likely a Dev profile.")
            }
            guard let apsEnvironment = plistMap["Entitlements.aps-environment"] as? String else {
              AuthLog.logInfo(code: "I-AUT000013",
                              message: "No aps-environment set. If testing on a device APNS is not " +
                                "correctly configured. Please recheck your provisioning profiles.")
              return defaultAppTypeProd
            }
            AuthLog.logDebug(code: "I-AUT000012",
                             message: "APNS Environment in profile: \(apsEnvironment)")

            if apsEnvironment == "development" {
              return false
            }

          } catch {
            AuthLog.logInfo(code: "I-AUT000008",
                            message: "Error while converting assumed plist to dict " +
                              "\(error.localizedDescription)")
          }
        }
      } catch {
        AuthLog.logInfo(code: "I-AUT000008",
                        message: "Error while reading embedded mobileprovision \(error)")
      }
      return defaultAppTypeProd
    }
  }
#endif
