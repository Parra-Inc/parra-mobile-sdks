//
//  AccountTab.swift
//  Demo
//
//  Created by Ian MacCallum on 5/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI
import WhatsNewKit
import SwiftUI
import WhatsNewKit

// MARK: - ExamplesView


// MARK: - View

// MARK: - AttributeContainer+foregroundColor

private extension AttributeContainer {
    
    /// A AttributeContainer with a given foreground color
    /// - Parameter color: The foreground color
    static func foregroundColor(
        _ color: Color
    ) -> Self {
        var container = Self()
        container.foregroundColor = color
        return container
    }
    
}

// MARK: - View


struct AccountRowView: View {
    var leadingImageName: String?
    var trailingImageName: String?
    var title: String
    var subtitle: String?
    
    var body: some View {
        HStack(alignment: .center) {
            if let leadingImageName {
                Image(systemName: leadingImageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 8)
            }
            
            
            VStack(alignment: .leading) {
                Text(title)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if let trailingImageName {
                Image(systemName: trailingImageName)
                    .resizable()
                    .frame(width: 7, height: 12)
            }
        }
    }
}

let sampleWhatsNew: WhatsNew = .init(
    version: "1.0.0",
    title: .init(
        text: .init(
            "What's New in "
            + AttributedString(
                "Parra",
                attributes: .foregroundColor(.cyan)
            )
        )
    ),
    features: [
        .init(
            image: .init(
                systemName: "rectangle.portrait.bottomthird.inset.filled",
                foregroundColor: .cyan
            ),
            title: "Conversation Views",
            subtitle: "Choose a side-by-side or face-to-face conversation view."
        ),
        .init(
            image: .init(
                systemName: "mic",
                foregroundColor: .cyan
            ),
            title: "Auto Translate",
            subtitle: "Respond in conversations without tapping the microphone button."
        ),
        .init(
            image: .init(
                systemName: "iphone",
                foregroundColor: .cyan
            ),
            title: "System-Wide Translation",
            subtitle: "Translate selected text anywhere on your iPhone."
        )
    ],
    primaryAction: .init(
        title: "Dismiss",
        backgroundColor: .cyan
    ),
    secondaryAction: .init(
        title: "Learn more",
        foregroundColor: .cyan,
        action: .openURL(
            .init(string: "https://apple.com/privacy")
        )
    )
)

struct AccountView: View {
    let onLogout: () -> Void
    
    @State var feedbackPresented = false
    @State var changelogPresented = false
    
    @State
    var whatsNew: WhatsNew?
    
    func openWhatsNew() {
        whatsNew = sampleWhatsNew
    }

    /// The currently presented WhatsNew object
    
    var body: some View {
        NavigationView {
            List {
                Section() {
                    NavigationLink {
                        
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .foregroundColor(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(Color(uiColor: UIColor(hex: 0xFAFAFA)))

                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(uiColor: UIColor(hex: 0xC4C4C4)))
                            }
                            Text("Ian MacCallum").font(.title2)
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section() {
                    Button(action: {
                        openWhatsNew()
                    }) {
                        Text("🎉 What's new!")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .sheet(isPresented: $changelogPresented) {
                        ParraFeedbackFormView()
                    }
                }
                
                Section() {
                    NavigationLink {
                        Text("Detail")
                    } label: {
                        AccountRowView(title: "Notifications")
                    }
                }
                                
                Section() {

                    NavigationLink {
                    } label: {
                        Text("Get help")
                    }


                    Button(action: {
                        feedbackPresented = true
                    }) {
                        Text("Leave feedback")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .sheet(isPresented: $feedbackPresented) {
                        ParraFeedbackFormView()
                    }
                    
                    Button(action: {
                        // Restore purchases
                    }) {
                        Text("Rate us")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                
                Section() {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        AccountRowView(title: "Privacy policy")
                    }
                    NavigationLink {
                        TermsAndConditionsView()
                    } label: {
                        AccountRowView(title: "Terms and conditions")
                    }
                    NavigationLink {
                        OpenSourceLicensesView()
                    } label: {
                        AccountRowView(title: "Open source licenses")
                    }
                }

//                Section() {
//                    Button(action: {
//                        // Restore purchases
//                    }) {
//                        Text("Restore Purchases")
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                }

                Section {
                    Button(action: onLogout) {
                        Text("Logout")
                            .foregroundColor(.red)
                            .background(Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .sheet(
                whatsNew: self.$whatsNew
            )
            .navigationTitle("Account")
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView {
            
        }
    }
}
