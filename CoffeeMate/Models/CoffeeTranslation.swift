//
//  CoffeeTranslation.swift
//  CoffeeMate
//
//  Created by Duy on 6/1/26.
//

import Foundation

struct CoffeeTranslation: Identifiable {
    let id = UUID()
    let countryName: String
    let countryCode: String
    let translation: String
    let pronunciation: String?
}
