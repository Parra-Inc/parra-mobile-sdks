//
//  AppDelegate.swift
//  Parra Feedback SDK Demo
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import ParraCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let myAppAccessToken = "9B5CDA6B-7538-4A2A-9611-7308D56DFFA1"
                
        Parra.setAuthenticationProvider { (completion: @escaping (Result<ParraCredential, Error>) -> Void) in
            var request = URLRequest(
                // Replace this with your Parra access token generation endpoint
                url: URL(string: "http://localhost:8080/v1/parra/auth/token")!
            )

            request.httpMethod = "POST"
            // Replace this with your app's way of authenticating users
            request.setValue("Bearer \(myAppAccessToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let response = try JSONDecoder().decode([String: String].self, from: data!)
                        
                        completion(.success(ParraCredential(token: response["access_token"]!)))
                    } catch let error {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
                
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
