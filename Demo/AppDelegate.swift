//
//  AppDelegate.swift
//  Parra Feedback SDK Demo
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import ParraCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard NSClassFromString("XCTestCase") == nil else {
            return true
        }
        let userId = "377f8230-cca3-4732-8a5c-00ce7d0c67b4"
        let baseUrl = URL(string: "https://api.parra.io")!
        let tenantId = "f2d60da7-8aea-4882-9ee7-307e0ff18728"
        let publicApiKeyId = "1cec7de9-1818-4929-98f0-64d35c9f9388"
        let parraPublicAuthTokenUrl = URL(string: "v1/tenants/\(tenantId)/issuers/public/auth/token", relativeTo: baseUrl)!

        Parra.initialize(
            config: .default,
            authProvider: .default(tenantId: tenantId) {
                var request = URLRequest(url: parraPublicAuthTokenUrl)

                request.httpMethod = "POST"

                let json: [String: Any] = ["user_id": userId]  // TODO: - Replace me with the id of the user in your system
                let jsonData = try! JSONSerialization.data(withJSONObject: json)
                let authData = ("api_key:" + publicApiKeyId).data(using: .utf8)!.base64EncodedString()
                
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.setValue("Basic \(authData)", forHTTPHeaderField: "Authorization")

                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode([String: String].self, from: data)

                return response["access_token"]!
            }
        )
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
