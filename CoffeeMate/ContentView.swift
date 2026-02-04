//
//  ContentView.swift
//  CoffeeMate
//
//  Created by Duy on 5/1/26.
//
import SwiftUI

// MARK: - Coffee List View
struct CoffeeListView: View {
    @StateObject private var viewModel = CoffeeListViewModel()
    @Binding var selectedCoffee: Coffee?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        listView
            .onAppear {
                viewModel.loadCoffees()
            }
    }
    
    private var listView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading coffees...")
            } else if viewModel.coffees.isEmpty {
                ContentUnavailableView(
                    "No Coffees Found",
                    systemImage: "cup.and.saucer",
                    description: Text(viewModel.errorMessage ?? "Make sure the database file is added to the app bundle")
                )
            } else {
                Group {
                    if horizontalSizeClass == .regular {
                        List(viewModel.filteredCoffees, selection: $selectedCoffee) { coffee in
                            NavigationLink(value: coffee) {
                                CoffeeRow(coffee: coffee)
                            }
                        }
                    } else {
                        List(viewModel.filteredCoffees) { coffee in
                            NavigationLink(value: coffee) {
                                CoffeeRow(coffee: coffee)
                            }
                        }
                    }
                }
                .navigationDestination(for: Coffee.self) { coffee in
                    CoffeeTranslationView(coffee: coffee)
                }
            }
        }
        .navigationTitle("Coffee List")
        .searchable(text: $viewModel.searchText, prompt: "Search coffee...")
    }
}

// MARK: - Coffee Row Component
struct CoffeeRow: View {
    let coffee: Coffee
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(coffee.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(coffee.tasteNotes)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Composition indicators - always show all components
            HStack(spacing: 12) {
                Label("\(coffee.pctCoffee)%", systemImage: "leaf.fill")
                    .font(.caption)
                    .foregroundColor(.brown)
                
                Label("\(coffee.pctMilk)%", systemImage: "waterbottle.fill")
                    .font(.caption)
                    .foregroundColor(.pink)
                
                Label("\(coffee.pctWater)%", systemImage: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Translation Detail View
struct CoffeeTranslationView: View {
    let coffee: Coffee
    @StateObject private var viewModel: CoffeeTranslationViewModel
    
    init(coffee: Coffee) {
        self.coffee = coffee
        _viewModel = StateObject(wrappedValue: CoffeeTranslationViewModel(coffee: coffee))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading translations...")
            } else if viewModel.equivalents.isEmpty {
                ContentUnavailableView(
                    "No Translations Found",
                    systemImage: "globe.badge.chevron.backward",
                    description: Text(viewModel.errorMessage ?? "This coffee doesn't have international equivalents yet")
                )
            } else {
                List(viewModel.equivalents, id: \.equivalent.id) { item in
                    TranslationRow(equivalent: item.equivalent, country: item.country)
                }
            }
        }
        .navigationTitle(coffee.name)
        .navigationBarTitleDisplayMode(.large)
        .task(id: coffee.id) {
            viewModel.loadEquivalents()
        }
    }
}

// MARK: - Translation Row Component
struct TranslationRow: View {
    let equivalent: CoffeeEquivalent
    let country: Country
    
    var body: some View {
        HStack(spacing: 16) {
            // Flag
            Text(flagEmoji(for: country.code))
                .font(.system(size: 40))
                .frame(width: 50)
            
            // Country and Translation
            VStack(alignment: .leading, spacing: 6) {
                Text(country.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(equivalent.localName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Culture type and confidence
                HStack(spacing: 8) {
                    // Culture type badge
                    Text(equivalent.cultureType == "modern_espresso" ? "Modern" : "Traditional")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(equivalent.cultureType == "modern_espresso" ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(equivalent.cultureType == "modern_espresso" ? .blue : .orange)
                        .cornerRadius(4)
                    
                    // Confidence indicator
                    Text(confidenceEmoji(for: equivalent.confidence))
                        .font(.caption)
                    Text(equivalent.confidence)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let notes = equivalent.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flag.append(String(scalarValue))
            }
        }
        return flag
    }
    
    private func confidenceEmoji(for confidence: String) -> String {
        switch confidence {
        case "Exact": return "✅"
        case "High": return "🟢"
        case "Medium": return "🟡"
        case "Low": return "🟠"
        default: return "❓"
        }
    }
}

// MARK: - Preview
#Preview {
    CoffeeListView(selectedCoffee: .constant(nil))
}
