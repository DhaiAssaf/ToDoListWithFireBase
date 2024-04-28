//
//  AddCategory.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 27/04/2024.
//


import SwiftUI

struct AddCategory: View {
    @State private var categoryTitle = ""
    @State private var showingError = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    var body: some View {
        NavigationStack {
            Form {
                Section{
                    TextField("Category" , text: $categoryTitle)
                } footer: {
                    Text(showingError ? "Title can not be empty!" :"Add Category title").foregroundStyle(showingError ? .red : .gray)
                }
                
                Section() {
                    Button("Add Category") {
                        if !categoryTitle.isEmpty {
                            let cat = Category(id: UUID().uuidString, name: categoryTitle, itemsCounter: 0)
                            Task {
                                try await firebaseManager.createCategory(cat)
                                try? await firebaseManager.fetchCategory()
                            }
                            dismiss()
                        }else{
                            showingError.toggle()
                        }
                    }
                    
                    .frame(maxWidth: .infinity)
                    
                   
                }}
            .navigationTitle("Add Category")
            Spacer()
        }
    }
}

#Preview {
    AddCategory()
        .environmentObject(FirebaseManager())
}
