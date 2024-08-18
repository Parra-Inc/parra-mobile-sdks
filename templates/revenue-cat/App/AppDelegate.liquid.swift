//
//  AppDelegate.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI
import RevenueCat

class AppDelegate: ParraAppDelegate<ParraSceneDelegate> {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

#if DEBUG
        Purchases.logLevel = .debug
#endif
      
        Purchases.configure(
            withAPIKey: "{{ revenue_cat.api_key }}"
        )

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}
