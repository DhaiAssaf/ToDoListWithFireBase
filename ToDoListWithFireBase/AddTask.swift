//
//  AddTask.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 28/04/2024.
//

import SwiftUI

struct AddTask: View {
    @State private var title = ""
    @State private var info = ""
    @State private var dueDate = Date()
    @State private var showingError = false
    @State private var itemPriority: ItemPriority = .medium
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    var category: Category
    var body: some View {
        NavigationStack {
            Form {
                    Section(footer: Text(showingError ? "Title and details must be filled in" : "Title your task to spotlight your priorities.")
                        .foregroundStyle(showingError ? .red : .gray)){
                    TextField("Task title" , text: $title)
                    TextField("Task details" , text: $info)
                        Picker("Priority", selection: $itemPriority) {
                            ForEach(ItemPriority.allCases) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())


                    DatePicker("Date", selection: $dueDate, in: Date()...)
                }

                Section() {
                    Button("Add Task") {
                        if !title.isEmpty && !info.isEmpty {
                            let item =  Item(id: UUID().uuidString, title: title, info: info, dueDate: dueDate, priority: itemPriority)
                            Task {
                                try await firebaseManager.createItem(item, category)
                                 firebaseManager.updateCategory(Category(id: category.id, name: category.name, itemsCounter: (category.itemsCounter + 1)))
                                try? await firebaseManager.fetchItems(category)                            }
                        dismiss()
                            Task{
                                try? await firebaseManager.fetchItems(category)
                            }
                        } else {
                            showingError = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }.navigationTitle("Add Task")
        }
    }
}

#Preview {
    AddTask(category: Category(id: "", name: "", itemsCounter: 0))
        .environmentObject(FirebaseManager())
}
