//
//  CredentialStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

actor CredentialStorage: ItemStorage {
    private let storageMedium: DataStorageMedium
    private var userCredential: ParraFeedbackCredential?

    init(storageMedium: DataStorageMedium) {
        self.storageMedium = storageMedium
    }
    
    func loadData() async {
        do {
            userCredential = try await storageMedium.read(
                name: ParraFeedbackDataManager.Key.userCredentialsKey
            )
        } catch let error {
            let dataError = ParraFeedbackError.dataLoadingError(error)
            parraLog("Error loading credentials: \(dataError)", level: .error)
        }
    }
        
    func updateCredential(credential: ParraFeedbackCredential?) {
        userCredential = credential
        
        Task {
            try await storageMedium.write(
                name: ParraFeedbackDataManager.Key.userCredentialsKey,
                value: credential
            )
        }
    }
    
    func currentCredential() -> ParraFeedbackCredential? {
        return userCredential
    }
    
    private func loadCredential() async throws -> ParraFeedbackCredential? {
        guard let data = UserDefaults.standard.value(
            forKey: ParraFeedbackDataManager.Key.userCredentialsKey
        ) as? Data else {
            return nil
        }
        
        return try JSONDecoder.parraDecoder.decode(ParraFeedbackCredential.self, from: data)
    }
}
