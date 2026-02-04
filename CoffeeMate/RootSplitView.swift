//
//  RootSplitView.swift
//  CoffeeMate
//
//  Created by Duy on 2026-01-29.
//

import SwiftUI

struct RootSplitView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedCoffee: Coffee?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad / Mac layout
            NavigationSplitView(columnVisibility: $columnVisibility) {
                CoffeeListView(selectedCoffee: $selectedCoffee)
            } detail: {
                NavigationStack {
                    if let coffee = selectedCoffee {
                        CoffeeTranslationView(coffee: coffee)
                            .id(coffee.id)
                    } else {
                        ContentUnavailableView(
                            "Select a Coffee",
                            systemImage: "cup.and.saucer",
                            description: Text("Choose a coffee from the list to see its international equivalents.")
                        )
                    }
                }
            }
        } else {
            // iPhone layout
            NavigationStack {
                CoffeeListView(selectedCoffee: $selectedCoffee)
            }
        }
    }
}

#Preview {
    RootSplitView()
}
