//
//  AuthView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI
struct ToggleSegmentControl: View {
    @State private var loginOrSignUp = "Login"
    var colors = ["Login", "Sign Up"]

    var body: some View {
        VStack {
            Picker("Login or sign up?", selection: $loginOrSignUp) {
                ForEach(colors, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct AuthView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var onLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ToggleSegmentControl()
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Button(action: onLogin) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView {
            
        }
    }
}
