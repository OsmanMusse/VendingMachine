//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Mezut on 15/10/2018.
//  Copyright © 2018 Treehouse Island, Inc. All rights reserved.
//

import Foundation

import UIKit




enum VendingSelection: String {
    case soda
    case dietSoda
    case chips
    case cookie
    case sandwich
    case wrap
    case candyBar
    case popTart
    case water
    case fruitJuice
    case sportsDrink
    case gum
    
    func getImage() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return #imageLiteral(resourceName: "default")
        }
    }
    
    }





protocol VendingItem {
    var price: Double { get }
    var quantity: Int { get set }
}



protocol VendingMachine {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: VendingItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection: VendingItem])
    
    func vend(_ quantity: Int, _ selection: VendingSelection) throws
    
    func deposit(_ amount: Double)
    
}


struct Item: VendingItem {
    var price: Double
    var quantity: Int
}

enum InvertoryError: Error {
    case invalidResource
    case contentFailure
    case invalidSelection
}

class PlistConverter {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
     // Possibility of the path not existing
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InvertoryError.invalidResource
        }
        
        guard let dictData = NSDictionary(contentsOfFile: path) as? [String : AnyObject]  else {
            throw InvertoryError.contentFailure
        }
        
        return dictData

    }
}


class InventoryUnarchiver {
    static func vendingInventory(fromDictionary dictionary: [String: AnyObject]) throws ->  [VendingSelection: VendingItem] {
        var inventory: [VendingSelection: VendingItem] = [:]
        
        for (key, value) in dictionary {
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int {
                let item = Item(price: price, quantity: quantity)
                guard let selection = VendingSelection(rawValue: key) else {
                    throw InvertoryError.invalidSelection
                }
                
                inventory.updateValue(item, forKey: selection)
            }
            
        }
        return inventory
      
    }
}




enum VendingMachineError:Error {
   case invalidSelection
   case outOfStock
   case insufficientFund(required: Double)
}


class FoodVendingMachine: VendingMachine {
    var selection: [VendingSelection] = [.soda, .dietSoda, .chips, .cookie, .sandwich, .wrap, .candyBar, .popTart, .water,
                                         .fruitJuice, .sportsDrink, .gum]
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.0
    
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(_ quantity: Int, _ selection: VendingSelection) throws {
        guard var itemsSelected = inventory[selection] else {
            throw VendingMachineError.invalidSelection
        }
        
        guard itemsSelected.quantity >= quantity else {
            throw VendingMachineError.outOfStock
        }
        
        let totalPrice = itemsSelected.price * Double(quantity)
        
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
            itemsSelected.quantity -= quantity
            
            inventory.updateValue(itemsSelected, forKey: selection)
        } else {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufficientFund(required: amountRequired)
        }
    }
    
    func deposit(_ amount: Double) {}
    
   
}



















