//
//  AppDelegate.swift
//  Parra Feedback SDK Demo
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import ParraCore
import ParraFeedback

struct AuthResponse: Codable {
    let accessToken: String
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let currentUserId = "9B5CDA6B-7538-4A2A-9611-7308D56DFFA1"
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        Parra.setAuthenticationProvider { (completion: @escaping (Result<ParraCredential, Error>) -> Void) in
            var request = URLRequest(
                url: URL(string: "http://localhost:8080/v1/parra/auth/token")!,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: 10
            )
            request.httpMethod = "POST"
            request.httpBody = try! JSONEncoder().encode(["user": ["id": currentUserId]])
            
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let response = try jsonDecoder.decode(AuthResponse.self, from: data!)
                        
                        completion(.success(ParraCredential(token: response.accessToken)))
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
