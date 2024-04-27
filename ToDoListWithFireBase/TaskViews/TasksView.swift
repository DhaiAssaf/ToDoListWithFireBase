//
//  TasksView.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 27/04/2024.
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var isShowingAddTaskView = false
    @State private var showingDeleteAllConfirmation = false
    @State private var selectedPriority: ItemPriority? = nil
    let category: Category
    @State private var items: [Item] = []
    var filteredItems: [Item] {
        Task {
            try await firebaseManager.fetchItems(category)
            items =  firebaseManager.items
        }
        if let selectedPriority = selectedPriority {
            return items.filter { $0.priority == selectedPriority }
        } else {
         
            return items
        }
    }
    var body: some View {
        NavigationStack {
            if  !items.isEmpty {
                Picker("Priority", selection: $selectedPriority) {
                    Text("All").tag(ItemPriority?.none)
                    ForEach(ItemPriority.allCases) { priority in
                        Text(priority.rawValue).tag(priority as ItemPriority?)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
            List(filteredItems, id: \.id) { item in
                NavigationLink {
                    UpdateTask(item: item, category: category)
                } label: {
                    HStack{
                        Circle()
                                .frame(width: 15, height: 15)
                                .foregroundColor(item.priority.rawValue == "High" ? .red : (item.priority.rawValue == "Medium" ? .yellow : .green))
                        VStack(alignment: .leading) {
                            Text(item.title)
                            Text(item.info)
                            Text(item.dueDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                        }
                        Spacer()
                        Button(action: {
                            let updatedItem = Item(id: item.id, title: item.title, info: item.info, isDone: !item.isDone, dueDate: item.dueDate, timestamp: item.timestamp, priority: item.priority)
                            Task{
                                firebaseManager.updateItem(updatedItem, category)
                                try? await firebaseManager.fetchItems(category)
                            }
                        }) {
                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isDone ? .green : .gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            do {
                                try await firebaseManager.deleteItem(item, category)
                                firebaseManager.updateCategory(Category(id: category.id, name: category.name, itemsCounter: (category.itemsCounter - 1)))
                                try? await firebaseManager.fetchItems(category)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Items")
            .toolbar {
                if  !items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingDeleteAllConfirmation.toggle()
                        } label: {
                            Image(systemName: "trash")
                                .tint(.red)
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isShowingAddTaskView.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .font(.title2)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }            .confirmationDialog("Are you sure you want to delete all items?", isPresented: $showingDeleteAllConfirmation, titleVisibility: .visible) {
                Button("Delete All", role: .destructive) {
                    Task {
                        do {
                            
                            try await firebaseManager.deleteAllItem(category)
                            firebaseManager.updateCategory(Category(id: category.id, name: category.name, itemsCounter: 0))
                            try? await firebaseManager.fetchItems(category)
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            
            .sheet(isPresented: $isShowingAddTaskView) {
                AddTask(category: category)
            }

        }
    }
}


