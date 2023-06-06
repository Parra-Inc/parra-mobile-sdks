//
//  PrivacyPolicy.swift
//  Demo
//
//  Created by Ian MacCallum on 5/21/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce eleifend placerat lectus at convallis. Ut aliquam diam vitae odio accumsan, a pharetra nibh ultricies. Vestibulum id orci sed urna convallis tincidunt. Quisque a tristique nisl, id semper felis. In hac habitasse platea dictumst. Suspendisse rhoncus dui non tortor interdum, in tempus mauris euismod.")
                
                SectionHeader(text: "Data Collection and Usage")
                
                Text("Vestibulum vestibulum commodo tincidunt. Morbi eget nulla sed tellus volutpat tristique in eget urna. Nam id bibendum risus, id facilisis elit. Sed hendrerit sem ut nisi elementum, vel rutrum sem bibendum. Aliquam finibus mauris urna, id ultrices nunc tristique ut. Curabitur eget tellus urna. Mauris egestas lectus quis ipsum rhoncus lacinia. Mauris posuere bibendum efficitur. Duis tincidunt augue sit amet luctus ultricies.")
                
                Text("Pellentesque in libero condimentum, rutrum nulla sed, efficitur justo. In nec semper ligula, vel rhoncus velit. Nunc maximus ultricies enim, sed efficitur odio tempor non. Suspendisse ut odio vitae lectus rutrum fringilla. Praesent eu felis ut nunc luctus tincidunt id sed tellus. Ut id placerat arcu. Nullam convallis tristique est. Sed semper felis id ante interdum, at lacinia felis varius. Aenean eget placerat tellus. Nam convallis scelerisque enim ut ullamcorper.")
                
                SectionHeader(text: "Data Security")
                
                Text("Sed non sapien massa. Curabitur blandit sollicitudin bibendum. Suspendisse potenti. Sed vel quam a purus luctus interdum in a turpis. Duis ultrices neque eu turpis egestas convallis. Integer eu ligula urna. Mauris finibus nunc eget fermentum dignissim. Donec eget nisi id orci aliquet vestibulum in a quam. Mauris aliquam mi non ex posuere, id facilisis orci rhoncus.")
            }
            .padding()
        }
        .navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
}

struct SectionHeader: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.title)
            .fontWeight(.bold)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
