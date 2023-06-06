//
//  AgreementView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/21/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AgreementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("End User Agreement")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Pellentesque in libero condimentum, rutrum nulla sed, efficitur justo. In nec semper ligula, vel rhoncus velit. Nunc maximus ultricies enim, sed efficitur odio tempor non. Suspendisse ut odio vitae lectus rutrum fringilla. Praesent eu felis ut nunc luctus tincidunt id sed tellus. Ut id placerat arcu. Nullam convallis tristique est. Sed semper felis id ante interdum, at lacinia felis varius. Aenean eget placerat tellus. Nam convallis scelerisque enim ut ullamcorper.")
                    .font(.body)
                Text("Pellentesque in libero condimentum, rutrum nulla sed, efficitur justo. In nec semper ligula, vel rhoncus velit. Nunc maximus ultricies enim, sed efficitur odio tempor non. Suspendisse ut odio vitae lectus rutrum fringilla. Praesent eu felis ut nunc luctus tincidunt id sed tellus. Ut id placerat arcu. Nullam convallis tristique est. Sed semper felis id ante interdum, at lacinia felis varius. Aenean eget placerat tellus. Nam convallis scelerisque enim ut ullamcorper.")
                    .font(.body)
                Text("Pellentesque in libero condimentum, rutrum nulla sed, efficitur justo. In nec semper ligula, vel rhoncus velit. Nunc maximus ultricies enim, sed efficitur odio tempor non. Suspendisse ut odio vitae lectus rutrum fringilla. Praesent eu felis ut nunc luctus tincidunt id sed tellus. Ut id placerat arcu. Nullam convallis tristique est. Sed semper felis id ante interdum, at lacinia felis varius. Aenean eget placerat tellus. Nam convallis scelerisque enim ut ullamcorper.")
                    .font(.body)
            }
            .padding()
        }
    }
}

struct AgreementView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView()
    }
}
