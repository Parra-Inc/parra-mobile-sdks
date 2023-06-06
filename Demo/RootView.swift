//
//  RootView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @State var isLoggedIn = true
    
    var body: some View {
        if isLoggedIn {
            TabView {
                isLoggedIn = false
            }
        } else {
            AuthView {
                print("LOGIN")
                isLoggedIn = true
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
