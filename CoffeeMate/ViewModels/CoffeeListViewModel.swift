//
//  CoffeeListViewModel.swift
//  CoffeeMate
//
//  Created by Duy on 5/1/26.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class CoffeeListViewModel: ObservableObject {
    @Published var coffees: [Coffee] = []
    @Published var searchText = ""
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    var filteredCoffees: [Coffee] {
        if searchText.isEmpty {
            return coffees
        } else {
            return coffees.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func loadCoffees() {
        isLoading = true
        errorMessage = nil
        
        Task {
            let fetchedCoffees = await DatabaseManager.shared.fetchAllCoffees()
            self.coffees = fetchedCoffees
            self.isLoading = false
            
            if fetchedCoffees.isEmpty {
                self.errorMessage = "No coffees found. Make sure the database file is added to the app bundle."
            }
        }
    }
}
