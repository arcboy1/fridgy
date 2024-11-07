//
//  FridgeItem.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-11-01.
//

import Foundation

class FridgeItem: Codable, Hashable, Equatable {
    static func == (lhs: FridgeItem, rhs: FridgeItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var name: String
    var quantity: Int
    var currentDate: Date
    var expirationDate: Date
    var details: String?
    var type: FridgeType
    
    init(id: String = UUID().uuidString, name: String, quantity: Int, currentDate: Date=Date(), expirationDate: Date, details: String, type: FridgeType) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.currentDate = currentDate
        self.expirationDate = expirationDate
        self.details = details
        self.type = type
    }
}

enum FridgeType: String, Codable {
    case allItems = "All Items"
    case drinks = "Drinks"
    case condiments = "Condiments"
    case food = "Food"
    case snacks = "Snacks"
    case fruit = "Fruit"
    case vegetable = "Vegetable"
    case meat = "Meat"
    case dairy = "Dairy"
    case dessert = "Dessert"
    case other = "Other"
}
