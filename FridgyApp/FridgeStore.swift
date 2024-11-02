//
//  FridgeStore.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-11-02.
//
import UIKit
import Foundation

class InventoryStore{
    private var fridgeItems = [FridgeItem]()
    
    init(){
        getItems()
    }
    
    var numItems: Int{
        return fridgeItems.count
    }
    
    var allItems: [FridgeItem]{
        return fridgeItems
    }
    
    
    
    
    
    //MARK: - Get Document Directory Location
    
    var documentDirectory: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths[0])
        return paths[0]
    }

    func alreadyInList(item: FridgeItem) -> Bool {
        if fridgeItems.contains(item){
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Adding and Deleting
    
    func addToFridgeItems(item: FridgeItem){
        fridgeItems.append(item)
        saveItems()
    }
    
    func addNewItem(item: FridgeItem){
        fridgeItems.append(item)
        saveItems()
    }
    
    func removeItem(item: FridgeItem){
        for (index, storedItem) in fridgeItems.enumerated(){
            if storedItem.id == item.id {
                fridgeItems.remove(at: index)
                saveItems()
                return
            }
        }
    }
    
    
    // MARK: - Persistence
   
    //encodes to json and writes to url
    func save(to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(fridgeItems)
            try jsonData.write(to: url)
            print("Items saved successfully.")
        } catch {
            print("Error encoding the JSON - \(error.localizedDescription)")
        }
    }

    //decodes items from json puts them in fridgeitmes
    func retrieve(from url: URL) {
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = try Data(contentsOf: url)
            fridgeItems = try jsonDecoder.decode([FridgeItem].self, from: jsonData)
            print("Items retrieved successfully.")
        } catch {
            print("Error decoding the JSON - \(error.localizedDescription)")
        }
    }

    
    //sets save directory
    func saveItems(){
        guard let documentDirectory = documentDirectory else { return }
        let fileName = documentDirectory.appendingPathComponent("fridgeStore.json")
        
        save(to: fileName)
    }
    
    //sets url for retrieval
    func getItems(){
        guard let documentDirectory = documentDirectory else { return }
        let fileURL = documentDirectory.appendingPathComponent("fridgeStore.json")
        print("Retrieving items from: \(fileURL)")
        retrieve(from: fileURL)
    }
    
    //deletes item based on index
    func deleteItem(item:FridgeItem){
        if let index=fridgeItems.firstIndex(where: {$0.id == item.id}){
            fridgeItems.remove(at: index)
        }
    }
    
    //MARK: - Removing, fetching and adding images
    func saveImage(image: UIImage, withIdentifier id: String){
        //this saves the image with the same id
        if let imagePath = documentDirectory?.appendingPathComponent(id){
            if let data = image.jpegData(compressionQuality: 0.8){
                do{
                    try data.write(to: imagePath)
                } catch{
                    print("Error saving image to file - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchImage(withIdentifier id: String) -> UIImage?{
        if let imagePath = documentDirectory?.appendingPathComponent(id), let imageFromDisk = UIImage(contentsOfFile: imagePath.path){
            return imageFromDisk
        }
         return nil
    }
    
    func deleteImage(withIdentifier id: String){
        guard let documentDirectory = documentDirectory else {
            return
        }
        
        let fileName = documentDirectory.appendingPathComponent(id)
        do{
            try FileManager.default.removeItem(at: fileName)
        } catch{
            print("Error deleting - \(error.localizedDescription)")
        }
    }
    

    
}
