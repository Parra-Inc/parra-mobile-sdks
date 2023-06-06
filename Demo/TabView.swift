//
//  TabView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TabView: View {
    let onLogout: () -> Void
    
    var body: some View {
        SwiftUI.TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
            
            AccountView(onLogout: onLogout)
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Account")
                }
        }
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            
        }
    }
}
