//
//  DatabaseManager.swift
//  CoffeeMate
//
//  Created by Duy on 6/1/26.
//
import Foundation
import SQLite

// MARK: - Database Manager
class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?
    
    // Table references
    private let canonicalCoffeeTable = Table("canonical_coffee")
    private let coffeeEquivalentTable = Table("coffee_equivalent")
    private let countryTable = Table("country")
    
    // canonical_coffee columns
    private let coffee_id = Expression<Int>("coffee_id")
    private let us_name = Expression<String>("us_name")
    private let taste_notes = Expression<String>("taste_notes")
    private let pct_coffee = Expression<Int>("pct_coffee")
    private let pct_milk = Expression<Int>("pct_milk")
    private let pct_water = Expression<Int>("pct_water")
    
    // coffee_equivalent columns
    private let equiv_id = Expression<Int>("equiv_id")
    private let country_id = Expression<Int>("country_id")
    private let coffee_id_fk = Expression<Int>("coffee_id")
    private let local_name = Expression<String>("local_name")
    private let culture_type = Expression<String>("culture_type")
    private let confidence = Expression<String>("confidence")
    private let notes = Expression<String?>("notes")
    
    // country columns
    private let country_id_pk = Expression<Int>("country_id")
    private let country_code = Expression<String>("country_code")
    private let country_name = Expression<String>("country_name")
    
    private init() {
        connectToDatabase()
    }
    
    private func connectToDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "coffee_guide_db", ofType: "db") else {
            print("❌ Database file not found in bundle")
            return
        }
        
        do {
            db = try Connection(dbPath, readonly: true)
            print("✅ Database connected successfully at: \(dbPath)")
        } catch {
            print("❌ Failed to connect to database: \(error)")
        }
    }
    
    // MARK: - Fetch All Coffees
    func fetchAllCoffees() async -> [Coffee] {
        guard let db = db else {
            print("❌ Database not connected")
            return []
        }
        
        let table = canonicalCoffeeTable
        let coffeeId = coffee_id
        let usName = us_name
        let tasteNotes = taste_notes
        let pctCoffee = pct_coffee
        let pctMilk = pct_milk
        let pctWater = pct_water
        
        return await Task.detached(priority: .userInitiated) {
            var coffees: [Coffee] = []
            
            do {
                for row in try db.prepare(table) {
                    let coffee = Coffee(
                        id: row[coffeeId],
                        name: row[usName],
                        tasteNotes: row[tasteNotes],
                        pctCoffee: row[pctCoffee],
                        pctMilk: row[pctMilk],
                        pctWater: row[pctWater]
                    )
                    coffees.append(coffee)
                }
                print("✅ Fetched \(coffees.count) coffees")
            } catch {
                print("❌ Failed to fetch coffees: \(error)")
            }
            
            return coffees
        }.value
    }
    
    // MARK: - Fetch Equivalents for Coffee
    func fetchEquivalents(forCoffeeId coffeeId: Int) async -> [(equivalent: CoffeeEquivalent, country: Country)] {
        guard let db = db else {
            print("❌ Database not connected")
            return []
        }
        
        let equivTable = coffeeEquivalentTable
        let ctryTable = countryTable
        let countryId = country_id
        let countryIdPk = country_id_pk
        let coffeeIdFk = coffee_id_fk
        let countryName = country_name
        let equivId = equiv_id
        let localName = local_name
        let cultureType = culture_type
        let confidence = confidence
        let notes = notes
        let countryCode = country_code
        
        return await Task.detached(priority: .userInitiated) {
            var results: [(CoffeeEquivalent, Country)] = []
            
            do {
                let query = equivTable
                    .join(ctryTable, on: equivTable[countryId] == ctryTable[countryIdPk])
                    .filter(equivTable[coffeeIdFk] == coffeeId)
                    .order(ctryTable[countryName].asc)
                
                for row in try db.prepare(query) {
                    let equivalent = CoffeeEquivalent(
                        id: row[equivTable[equivId]],
                        countryId: row[equivTable[countryId]],
                        coffeeId: row[equivTable[coffeeIdFk]],
                        localName: row[equivTable[localName]],
                        cultureType: row[equivTable[cultureType]],
                        confidence: row[equivTable[confidence]],
                        notes: row[equivTable[notes]]
                    )
                    
                    let country = Country(
                        id: row[ctryTable[countryIdPk]],
                        code: row[ctryTable[countryCode]],
                        name: row[ctryTable[countryName]]
                    )
                    
                    results.append((equivalent, country))
                }
                print("✅ Fetched \(results.count) equivalents for coffee ID \(coffeeId)")
            } catch {
                print("❌ Failed to fetch equivalents: \(error)")
            }
            
            return results
        }.value
    }
}
