//
//  FirebaseManager.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 27/04/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

enum ItemPriority: String, CaseIterable, Identifiable, Codable {
    case high = "High" //red
    case medium = "Medium" //yellow
    case low = "Low" //green
    
    var id: String { self.rawValue }
    
}
struct Item: Codable , Identifiable{
    var id: String
    var title : String
    var info : String
    var isDone: Bool = false
    var dueDate: Date
    var timestamp: Date = .now
    var priority: ItemPriority = ItemPriority.medium
}

struct Category: Codable, Identifiable {
    var id: String
    var name: String
    var itemsCounter: Int
}
class FirebaseManager: NSObject , ObservableObject {
    @Published var items: [Item] = []
    @Published var categories: [Category] = []
    let firestore: Firestore
    
    override init() {
        self.firestore = Firestore.firestore()
        super.init()
    }
    // MARK: - Create new item in the DB
    func createItem(_ item: Item,_ category: Category) async throws {
        do {
            try firestore.collection("category").document(category.id).collection("items").document(item.id).setData(from: item)
            print("Item created in category.")
        } catch {
            print("Failed to create item: \(error)")
            throw error
        }
    }

    // MARK: - Create new category in the DB
    func createCategory(_ category: Category) async throws {
        do{
            try  firestore.collection("category").document(category.id).setData(from: category)
            print("Succesfull category creation")
        }
        catch{
            print("Failed to create category: \(error)")
            throw error
            
        }
    }
    // MARK: - fetch data from DB
    func fetchItems(_ category: Category) async throws {
        let querySnapshot = try await firestore.collection("category").document(category.id).collection("items").getDocuments()
        let items = querySnapshot.documents.compactMap({try? $0.data(as: Item.self)})
        DispatchQueue.main.sync {
            self.items = items
       }
    }

    // MARK: - fetch data in category from DB
    func fetchCategory() async throws {
        let querySnapshot = try await firestore.collection("category").getDocuments()
        let categories = querySnapshot.documents.compactMap({try? $0.data(as: Category.self)})
        DispatchQueue.main.sync {
            self.categories = categories
       }
    }
    // MARK: - delete data from DB
    func deleteItem(_ item : Item, _ category: Category) async throws {
        let documentRef = firestore.collection("category").document(category.id).collection("items").document(item.id)
           try await documentRef.delete()
    }
    // MARK: - delete category from DB
    func deleteCategory(_ category: Category) async throws {
        let documentRef = firestore.collection("category").document(category.id)
           try await documentRef.delete()
    }
    // MARK: - delete all items
   
    func deleteAllCategory() async throws {
        let collectionRef = firestore.collection("category")
        let querySnapshot = try await collectionRef.getDocuments()
        for document in querySnapshot.documents {
            let docRef = document.reference
            do {
                try await docRef.delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    // MARK: - delete all categories
    func deleteAllItem(_ category: Category) async throws {
        let collectionRef = firestore.collection("category").document(category.id).collection("items")
        let querySnapshot = try await collectionRef.getDocuments()
        for document in querySnapshot.documents {
            let docRef = document.reference
            do {
                try await docRef.delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - update item in the DB
    func updateItem(_ item: Item, _ category: Category){
        do {
            try firestore.collection("category")
                              .document(category.id)
                              .collection("items")
                              .document(item.id)
                              .setData(from: item)
        } catch {
            print(error.localizedDescription)
        }
    }
    // MARK: - update category in the DB
    func updateCategory( _ category: Category){
        do {
            try  firestore.collection("category").document(category.id).setData(from: category)
        } catch {
            print(error.localizedDescription)
        }
    }

}
