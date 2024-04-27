//
//  ContentView.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 27/04/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var isShowingAddCategory = false
    @State private var showingDeleteAllConfirmation = false
    @State private var selectedCategory: Category?
    @State private var showError: Bool = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(firebaseManager.categories) { category in
                    HStack {
                        NavigationLink(destination: TasksView()) {
                            HStack() {
                                Text(category.name)
                                    .frame(alignment: .leading)
                                Text("(\(category.itemsCounter))")
                                
                            }
                        }
                        Spacer()
                        Menu {
                            Button {
                                selectedCategory = category
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .foregroundColor(.blue)
                            }
                            
                            Button(role: .destructive){
                                Task {
                                    do {
                                        try await firebaseManager.deleteCategory(category)
                                        try? await firebaseManager.fetchCategory()
                                    } catch {
                                        print("Error deleting category: \(error)")
                                    }
                                }
                            }label: {
                                Text("Delete")
                                
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                if !firebaseManager.categories.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingDeleteAllConfirmation.toggle()
                        } label: {
                            Image(systemName: "trash")
                                .tint(.red)
                        }
                    }}
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isShowingAddCategory.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .font(.title2)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            .confirmationDialog("Are you sure you want to delete all categories?", isPresented: $showingDeleteAllConfirmation, titleVisibility: .visible) {
                Button("Delete All", role: .destructive) {
                    Task {
                        do {
                            
                            try await firebaseManager.deleteAllCategory()
                            try? await firebaseManager.fetchCategory()
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $selectedCategory) { category in
               UpdateCategory(category: category)
            }
            .sheet(isPresented: $isShowingAddCategory) {
                AddCategory()
            }
            .onAppear {
                Task {
                    do {
                        try await firebaseManager.fetchCategory()
                    } catch {
                       
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FirebaseManager())
}
