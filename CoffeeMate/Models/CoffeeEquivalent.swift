//
//  CoffeeEquivalent.swift
//  CoffeeMate
//
//  Created by Duy on 6/1/26.
//

struct CoffeeEquivalent: Identifiable {
    let id: Int // equiv_id
    let countryId: Int
    let coffeeId: Int
    let localName: String
    let cultureType: String // "modern_espresso" or "traditional"
    let confidence: String // "Exact", "High", "Medium", "Low"
    let notes: String?
}
