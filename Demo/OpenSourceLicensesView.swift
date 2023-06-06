//
//  OpenSourceLicensesView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/21/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI

struct OpenSourceLicensesView: View {
    var projects = [
        "Alamofire",
        "SDWebImage",
        "Kingfisher",
        "SnapKit",
        "Realm",
        "RxSwift",
        "CryptoSwift",
        "SwiftyJSON"
    ]
    
    var body: some View {
        List(projects, id: \.self) { project in
            NavigationLink {
                LicenseView()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project)
                        .font(.headline)
                    Text("A powerful library for network requests")
                        .font(.subheadline)
                }
            }
        }
        .navigationBarTitle("Licenses", displayMode: .inline)
    }
}

struct OpenSourceLicensesView_Previews: PreviewProvider {
    static var previews: some View {
        OpenSourceLicensesView()
    }
}
