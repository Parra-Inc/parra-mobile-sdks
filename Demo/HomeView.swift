//
//  HomeView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/19/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI
import ParraFeedback
import ParraCore

struct WrappedParraCardView: UIViewRepresentable {
    let cards: [ParraCardItem]
    let onDismiss: () -> Void
    
    func makeUIView(context: Context) -> ParraCardView {
        var config = ParraCardViewConfig.default
        config.backgroundColor = .white
        config.accessoryTintColor = .blue
        
        
        let view = ParraCardView(config: .default)

        view.containerView.layer.borderColor = UIColor(hex: 0xe3e4e6).cgColor
        view.containerView.layer.borderWidth = 1
        view.delegate = context.coordinator
        
        return view
    }

    func updateUIView(_ uiView: ParraCardView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator {
            onDismiss()
        }
    }

    class Coordinator: NSObject, ParraCardViewDelegate {
        let onDismiss: () -> Void
        
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
            self.onDismiss()
        }
    }
}


struct HomeView: View {
    @State var cardsHidden = false
    @State var cards: [ParraCardItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if !cardsHidden && !cards.isEmpty {
                    WrappedParraCardView(cards: cards) {
                        cardsHidden = true
                    }.frame(maxWidth: .infinity)
                }

            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Home")
        }
        .onAppear {
            ParraFeedback.fetchFeedbackCards { [self] response in
                switch response {
                case .success(let cards):
                    print(cards)
                    self.cards = cards
                case .failure(let error):
                    print(error)
                    
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
