//
//  Recipe.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var name: String
    var imageName: String
    var ingredients: [String]
    var kitchenware: [String]
    var recipeDescription: String
    var servings: Int
    var isFavorite: Bool
    var createdAt: Date
    
    init(name: String, imageName: String, ingredients: [String], kitchenware: [String], description: String, servings: Int = 4) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.ingredients = ingredients
        self.kitchenware = kitchenware
        self.recipeDescription = description
        self.servings = servings
        self.isFavorite = false
        self.createdAt = Date()
    }
}

@Model
final class Ingredient {
    var id: UUID
    var name: String
    var categoryName: String
    var isSelected: Bool
    
    init(name: String, category: IngredientCategory) {
        self.id = UUID()
        self.name = name
        self.categoryName = category.rawValue
        self.isSelected = false
    }
    
    var category: IngredientCategory {
        return IngredientCategory(rawValue: categoryName) ?? .vegetables
    }
}

enum IngredientCategory: String, CaseIterable {
    case vegetables = "vegetables"
    case meats = "meats"
    case stapleFoods = "staple_foods"
    
    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

@Model
final class Kitchenware {
    var id: UUID
    var name: String
    var isSelected: Bool
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.isSelected = false
    }
}