//
//  TermsAndConditionsView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/21/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TermsAndConditionsView: View {
    var agreements = [
        Agreement(name: "End user agreement", accepted: true, acceptedDate: Date()),
        Agreement(name: "Merchant agreement", accepted: false, acceptedDate: nil),
    ]
    
    var body: some View {
        List(agreements) { agreement in
            NavigationLink {
                AgreementView()
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if agreement.accepted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                        
                        Text(agreement.name)
                            .font(.headline)
                    }
                    
                    if agreement.accepted {
                        Text("Accepted on \(formattedDate(agreement.acceptedDate))")
                            .foregroundColor(.gray)
                    } else {
                        Text("Not accepted")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationBarTitle("Terms and Conditions", displayMode: .inline)
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}

struct Agreement: Identifiable {
    let id = UUID()
    let name: String
    let accepted: Bool
    let acceptedDate: Date?
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}
