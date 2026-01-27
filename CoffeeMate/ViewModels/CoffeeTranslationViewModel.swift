//
//  CoffeeTranslationViewModel.swift
//  CoffeeMate
//
//  Created by Duy on 5/1/26.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class CoffeeTranslationViewModel: ObservableObject {
    @Published var equivalents: [(equivalent: CoffeeEquivalent, country: Country)] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    let coffee: Coffee
    
    init(coffee: Coffee) {
        self.coffee = coffee
    }
    
    func loadEquivalents() {
        isLoading = true
        errorMessage = nil
        
        Task {
            let fetchedEquivalents = await DatabaseManager.shared.fetchEquivalents(forCoffeeId: coffee.id)
            self.equivalents = fetchedEquivalents
            self.isLoading = false
            
            if fetchedEquivalents.isEmpty {
                self.errorMessage = "This coffee doesn't have international equivalents yet"
            }
        }
    }
}
