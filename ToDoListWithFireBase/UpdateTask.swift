//
//  UpdateTask.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 28/04/2024.
//

import SwiftUI

struct UpdateTask: View {
    @State private var title = ""
    @State private var info = ""
    @State private var dueDate = Date()
    @State private var isDone = false
    @State private var showingError = false
    @State private var itemPriority: ItemPriority = .medium
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    var item: Item
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
                        
                        Toggle(isOn: $isDone) {
                            Text("Is Done")
                        }
                        DatePicker("Date", selection: $dueDate, in: Date()...)
                    }
                
                Section() {
                    Button("Update Task") {
                        if !title.isEmpty && !info.isEmpty {
                        let item =  Item(id: item.id,title: title, info: info,isDone: isDone, dueDate: dueDate, priority: itemPriority)
                            Task {
                                firebaseManager.updateItem(item, category)
                                try? await firebaseManager.fetchItems(category)
                                //try await firebaseManager.fetchItems(for: category)

                            }
                            dismiss()
                            
                        } else {
                            showingError = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
            }.navigationTitle("Edit Task")
                .onAppear {
                    title = item.title
                    info = item.info
                    dueDate = item.dueDate
                    isDone = item.isDone
                    
                }
            
        }
    }
}


#Preview {
    UpdateTask(item: Item(id: "", title: "", info: "", dueDate: Date()), category: Category(id: "", name: "", itemsCounter: 0))
        .environmentObject(FirebaseManager())
}

